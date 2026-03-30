# Fittin Web Public Deployment

This guide publishes the Flutter Web client to:

```text
https://fittin.yimelo.cc/
```

The deployment model is:

```text
Flutter Web release build
  -> local Caddy static server on 127.0.0.1:4173
  -> Cloudflare Tunnel ingress
  -> https://fittin.yimelo.cc/
```

This repository does not deploy a separate custom backend. The web app is a static bundle and still talks directly to Supabase with `SUPABASE_URL` and `SUPABASE_ANON_KEY`.

Current public host split:

```text
https://fittin.yimelo.cc/     -> Flutter Web frontend
https://supabase.yimelo.cc/   -> local Supabase API exposed through Cloudflare Tunnel
```

## Prerequisites

- Flutter SDK installed and available in `PATH`
- Caddy installed on the host machine
- An existing Cloudflare Tunnel that can route `fittin.yimelo.cc`
- A reachable Supabase project URL and anon key for the public web client

Do not rely on the app's debug-only local Supabase fallback for public deployment. Release builds must pass explicit `dart-define` values.

## 1. Build The Web App

From the repository root:

```bash
flutter build web --release \
  --dart-define=SUPABASE_URL=https://supabase.yimelo.cc \
  --dart-define=SUPABASE_ANON_KEY=<your-anon-key>
```

Expected output:

- Generated files under `build/web/`
- A release-ready static bundle that can be served from the subdomain root

Notes:

- This app is deployed at the domain root, so do not add a subpath `--base-href`.
- If you need to verify the bundle locally before exposing it publicly, finish the Caddy step below first.

## 2. Serve `build/web` Locally With Caddy

This repo includes a Caddy config template at:

- `deploy/caddy/fittin.Caddyfile`
- `deploy/launchd/com.yimelo.fittin-web.plist`
- `tool/run_fittin_caddy.sh`

Run Caddy from the repo root:

```bash
caddy run --config deploy/caddy/fittin.Caddyfile
```

Expected local origin:

```text
http://127.0.0.1:4173
```

Quick local check:

```bash
curl -I http://127.0.0.1:4173
```

You should receive an HTTP success response and be able to open the app in a browser through the local origin.

### Optional: Keep Caddy Resident With `launchd`

On this macOS host, the recommended long-running setup is `launchd`.

Prepare the log directory:

```bash
mkdir -p .deploy
```

Install the user agent:

```bash
REPO_ROOT="$(pwd)"
sed "s|__REPO_ROOT__|$REPO_ROOT|g" deploy/launchd/com.yimelo.fittin-web.plist \
  > ~/Library/LaunchAgents/com.yimelo.fittin-web.plist
launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/com.yimelo.fittin-web.plist 2>/dev/null || true
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.yimelo.fittin-web.plist
launchctl kickstart -k gui/$(id -u)/com.yimelo.fittin-web
```

Check status:

```bash
launchctl list | grep com.yimelo.fittin-web
curl -I http://127.0.0.1:4173
```

Logs:

```text
.deploy/fittin-web.out.log
.deploy/fittin-web.err.log
```

## 3. Route `fittin.yimelo.cc` Through Cloudflare Tunnel

Update the existing tunnel ingress so the frontend and Supabase hostnames point to the correct local origins.

Example ingress shape:

```yaml
ingress:
  - hostname: fittin.yimelo.cc
    service: http://127.0.0.1:4173
  - hostname: supabase.yimelo.cc
    service: http://127.0.0.1:55321
  - service: http_status:404
```

Important:

- The hostname must be `fittin.yimelo.cc`
- The frontend origin must match the Caddy listener exactly: `127.0.0.1:4173`
- The Supabase hostname must be `supabase.yimelo.cc`
- The Supabase origin must match the local API gateway exactly: `127.0.0.1:55321`
- Keep the fallback `http_status:404` rule last

After changing the tunnel config, reload or restart the tunnel using your normal Cloudflare Tunnel operational command.

If the host already runs `cloudflared` through `launchd`, reload it after updating `~/.cloudflared/config.yml`:

```bash
launchctl kickstart -k gui/$(id -u)/com.yimelo.cloudflared
```

or, if the Homebrew service label is the active one:

```bash
launchctl kickstart -k gui/$(id -u)/homebrew.mxcl.cloudflared
```

## 4. Public Smoke Checks

After the build, Caddy, and Tunnel are active, verify:

1. Open `https://fittin.yimelo.cc/` and confirm the first frame renders.
2. Refresh the page and confirm it does not fail with a blank screen or 404.
3. Open browser dev tools and confirm core assets such as `flutter_bootstrap.js`, `main.dart.js`, icons, and manifest load successfully.
4. Confirm the app reaches the intended Supabase environment rather than the local debug fallback.
5. If account features are expected to be live, sign in and confirm auth/bootstrap succeeds.
6. Create or edit a small piece of browser-local data and refresh to confirm IndexedDB-backed local persistence still restores state.
7. Confirm `https://supabase.yimelo.cc/auth/v1/settings` responds publicly and allows requests from `https://fittin.yimelo.cc`.

## 5. Update Procedure

For every new public release:

1. Pull the latest repository changes.
2. Rebuild the web app with the correct public Supabase `dart-define` values.
3. Restart Caddy if needed so it serves the newly generated `build/web`.
4. Confirm the tunnel is still routing to `127.0.0.1:4173`.
5. Re-run the public smoke checks.

## 6. Rollback Procedure

If the new release is not acceptable:

1. Stop public validation traffic if needed.
2. Restore the previous known-good `build/web` contents from your backup or previous checkout.
3. Re-run Caddy against the restored build.
4. Confirm `https://fittin.yimelo.cc/` is back on the previous known-good version.
5. Record what failed before attempting the next release.

If the issue is Tunnel-related rather than app-related, first verify the local origin at `http://127.0.0.1:4173` before rebuilding the app.

## 7. Common Failure Checks

- `Missing SUPABASE_URL or SUPABASE_ANON_KEY`: rebuild with explicit `--dart-define` values.
- Local origin does not respond: confirm Caddy is running and `build/web` exists.
- Public URL fails but local origin works: inspect Cloudflare Tunnel ingress and tunnel process status.
- App boots but auth/sync is unavailable: confirm the configured Supabase URL and anon key belong to the intended public project.

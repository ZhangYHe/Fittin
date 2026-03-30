## Why

Fittin now has a usable Flutter Web client, but there is no repeatable way to publish it on a stable public URL. Since `yimelo.cc` is already exposed through Cloudflare Tunnel, the next step is to make the web app reachable at `fittin.yimelo.cc` with a documented release flow instead of relying on ad hoc local runs.

## What Changes

- Add a new public deployment capability for serving the Flutter Web build at `https://fittin.yimelo.cc/`.
- Define a repeatable release flow that builds the web app in release mode with explicit Supabase `dart-define` values.
- Add project-owned deployment artifacts for local static hosting with Caddy and for documenting the Cloudflare Tunnel routing setup.
- Document verification, update, and rollback steps so the published web app can be maintained without rediscovering the process.

## Capabilities

### New Capabilities
- `web-public-deployment`: Define how the Flutter Web app is built, locally hosted, exposed through Cloudflare Tunnel, and verified on the public subdomain.

### Modified Capabilities

## Impact

- Affected systems: Flutter Web build/release workflow, local static hosting, Cloudflare Tunnel routing, and Supabase runtime configuration for the public web client
- Affected repo areas: deployment documentation and deployment config templates for the web app
- Affected operations: release builds, public smoke checks, and rollback/redeploy procedure

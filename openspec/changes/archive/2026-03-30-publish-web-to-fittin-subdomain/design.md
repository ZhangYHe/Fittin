## Context

Fittin already has a Flutter Web client, and the repository now includes a browser-persistent local datastore path plus Supabase-backed authentication and sync. What is still missing is a repeatable public deployment contract: how to build the app for release, how to host the generated static assets locally, and how to expose that local service through the existing Cloudflare Tunnel at `fittin.yimelo.cc`.

The app has no separate backend to deploy. The runtime shape is a static Flutter Web bundle that talks directly to Supabase using `SUPABASE_URL` and `SUPABASE_ANON_KEY` passed via `dart-define`. Because the user already exposes `yimelo.cc` through Cloudflare Tunnel, the narrowest viable solution is to add a project-owned static hosting configuration and deployment guide rather than introducing containers, a custom API, or CI/CD in the same change.

## Goals / Non-Goals

**Goals:**
- Define a repeatable release build flow for the public Flutter Web app.
- Add repository-owned deployment artifacts for locally serving `build/web`.
- Document how `fittin.yimelo.cc` maps through Cloudflare Tunnel to the local static service.
- Document smoke checks, redeploy steps, and rollback steps for maintainers.

**Non-Goals:**
- Introducing a new backend service or changing the current Flutter-to-Supabase architecture.
- Building CI/CD, container deployment, or process-supervision automation in this change.
- Storing production secrets, Cloudflare credentials, or host-specific private values in the repository.

## Decisions

### Use release-mode Flutter Web builds with explicit Supabase defines
Public deployment will use `flutter build web --release` with explicit `SUPABASE_URL` and `SUPABASE_ANON_KEY` values. This keeps production behavior independent from the debug-only local Supabase fallback and matches how the app already reads configuration in `supabase_bootstrap.dart`.

Alternative considered: relying on debug fallback or undocumented shell environment.
Rejected because public deployment must not depend on development-only behavior or hidden host shell state.

### Use Caddy as the local static server
The repository will add a Caddy configuration template that serves the checked-out repository's `build/web` directory on `127.0.0.1:4173`. Caddy is simple to run locally, well-suited to static asset hosting, and easy to point Cloudflare Tunnel at without adding unrelated reverse-proxy complexity.

Alternative considered: a transient command like `python -m http.server`.
Rejected because the change needs a stable, repeatable local origin rather than an ad hoc command with weaker long-running ergonomics.

### Keep Cloudflare Tunnel as an external operator-managed dependency
The repository will document the required Tunnel ingress shape for `fittin.yimelo.cc`, but it will not attempt to manage Cloudflare credentials or tunnel lifecycle from inside the codebase. The project-owned contract is the expected hostname, origin, and verification steps.

Alternative considered: scripting Cloudflare configuration from the repository.
Rejected because it would require credentials handling and deployment coupling that do not belong in this change.

### Prefer documentation plus minimal deployment artifacts over application code changes
The implementation will focus on deployment docs and config templates. Application code changes are only justified if release-mode web serving reveals a concrete blocker. This keeps the change tightly scoped to publishing the already-built web app.

## Risks / Trade-offs

- [Host-specific paths can leak into tracked config] -> Mitigation: use repository-relative examples and placeholders in docs/config templates instead of machine-specific absolute paths.
- [Public deployment can silently use the wrong Supabase project] -> Mitigation: require explicit `dart-define` values in the documented build command and include runtime verification in the smoke checks.
- [Tunnel and local static server can drift out of sync] -> Mitigation: document the exact expected origin (`127.0.0.1:4173`) and include a direct local-origin check before public smoke checks.
- [No process supervisor means manual restarts remain operational work] -> Mitigation: explicitly document that first version is manual-but-repeatable and keep service commands small and deterministic.

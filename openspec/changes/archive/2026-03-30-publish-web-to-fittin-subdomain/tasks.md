## 1. Deployment Documentation

- [x] 1.1 Add a public deployment guide that explains the release build command, required `dart-define` values, and local verification steps for the web app.
- [x] 1.2 Document the expected Cloudflare Tunnel ingress mapping for `fittin.yimelo.cc`, plus public smoke checks and rollback steps.

## 2. Local Static Hosting Artifacts

- [x] 2.1 Add a repository-owned Caddy configuration template that serves `build/web` from `127.0.0.1:4173`.
- [x] 2.2 Add a small helper script or command wrapper for running the documented Flutter Web release build and pointing maintainers to the deployment guide.

## 3. Validation

- [x] 3.1 Verify the documented build flow succeeds locally for Flutter Web release output.
- [x] 3.2 Review the deployment artifacts and docs for consistency with the current Supabase configuration model and the chosen local origin.

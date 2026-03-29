## Why

The current web path only uses an in-memory fallback because `isar 3.1.0+1` cannot run in the browser runtime used by this project. That workaround restores rendering, but all local data disappears on refresh and web sync is effectively disabled, so the browser experience is not usable as a real client.

## What Changes

- Replace the temporary web in-memory persistence path with a browser-persistent local datastore backed by IndexedDB.
- Keep native platforms on the existing Isar 3.x local datastore path.
- Restore web-local persistence for templates, instances, workout logs, body metrics, progress photo metadata, app state, and sync queue records.
- Restore web sync processing so browser-stored records can be claimed, queued, uploaded, and hydrated from Supabase again.

## Capabilities

### New Capabilities

### Modified Capabilities
- `local-datastore-schema`: Require a browser-persistent local datastore implementation for Flutter Web with parity for current repository-backed local entities.
- `user-cloud-sync`: Require Flutter Web to preserve and process local sync metadata and queue state instead of falling back to a no-op sync path.

## Impact

- Affected code: web local persistence backend, repository bootstrap, sync integration, and Supabase row upsert helpers
- Affected platforms: Flutter Web only for new behavior; native/mobile/desktop remain on Isar 3.x
- Affected systems: local datastore, sync queue, app state restoration

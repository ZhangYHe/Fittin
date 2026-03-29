## Context

The project currently boots the web app by swapping to a temporary in-memory repository because Isar 3.x is not usable in this browser runtime. That avoids startup crashes but drops all browser data on refresh and bypasses real sync behavior.

The local repository surface is already stable and broadly used by the application layer, so the safest path is to keep those interfaces intact and replace only the web storage backend.

## Goals

- Persist web-local app data across refreshes and restarts.
- Restore browser sync behavior for queue-driven Supabase synchronization.
- Avoid downgrading native/mobile/desktop storage away from Isar 3.x.
- Minimize churn in UI and application-provider code.

## Non-Goals

- Replacing Isar on native platforms.
- Reworking domain models or presentation flows.
- Introducing a new cross-platform local database abstraction for every platform.

## Approach

1. Add a web-only browser persistence service backed by IndexedDB object stores.
2. Add web-specific database and progress repositories that preserve the current repository method contracts while reading and writing JSON documents in IndexedDB.
3. Bootstrap web startup with those repositories instead of the temporary in-memory fallback.
4. Add a web-specific sync service that reuses the existing sync semantics but reads local queue/entity documents from IndexedDB rather than Isar collections.
5. Keep native startup and native sync on the existing Isar-backed path.

## Data Model

- Use one IndexedDB database with stores for:
  - app state
  - templates
  - instances
  - workout logs
  - body metrics
  - progress photos
  - sync queue
- Store documents keyed by existing business identifiers (`templateId`, `instanceId`, `logId`, `metricId`, `photoId`, `queueKey`, `stateKey`).
- Persist dates as ISO-8601 UTC strings and preserve existing sync metadata fields (`version`, `syncStatusKey`, `lastSyncedAt`, `lastModifiedByDeviceId`, `deletedAt`).

## Risks and Mitigations

- Risk: web and native sync paths diverge behaviorally.
  Mitigation: keep queue semantics, status transitions, and row payloads aligned with the existing sync flow.

- Risk: browser storage introduces serialization drift.
  Mitigation: centralize IndexedDB document conversions in shared web storage model helpers instead of spreading ad hoc maps across repositories.

- Risk: progress photo binary upload is not represented by a native browser file path.
  Mitigation: persist progress photo metadata and local references in web storage, and keep sync metadata aligned even if binary upload remains constrained by existing UI contracts.

## Verification

- Build and run Flutter Web successfully.
- Verify browser-stored templates, instances, logs, body metrics, and app state survive refresh.
- Verify signed-in web sessions enqueue local changes and execute synchronization again.

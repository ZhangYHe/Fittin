## Why

The current workout logger only supports kilogram-based weight entry, fixed tap-only weight adjustments, non-interactive set progress, and no RPE capture. It also leaves some mapped accessory movements without a usable initial load path and provides no reusable conversion or plate-loading assistance in settings or during a session. After a user completes a workout, the data is only queued locally unless they later trigger or happen to hit another sync path, which makes “finished a workout” feel less trustworthy for signed-in users expecting cloud backup.

## What Changes

- Add a reusable weight-unit and plate-calculator capability that supports kg/lb conversion, configurable default bar weights, and barbell plate breakdown guidance from settings and the workout logger.
- Upgrade the active workout logger so each exercise can switch between kg/lb display units, enter weight directly, edit actual RPE, tap set-progress indicators to jump between sets, and show a success animation when logging a set.
- Extend plan, session, and workout-log models to support prescribed and recorded RPE, per-exercise session display units, and the metadata needed for barbell-only plate guidance.
- Expand plan activation and editing so quick-start remains available, while exercises that do not have a usable resolved starting load can be completed later through the plan editor instead of silently defaulting to unusable values.
- Automatically trigger a cloud sync attempt after a signed-in user successfully concludes a workout, without making workout saving depend on the sync succeeding.

## Capabilities

### New Capabilities
- `weight-unit-and-plate-calculator`: Weight conversion, default bar-weight preferences, and barbell plate-loading guidance exposed from settings and the workout logger.

### Modified Capabilities
- `training-log-screen-refactor`: The workout logger gains unit switching, direct weight entry, tappable set progress, RPE editing, and completion feedback.
- `zero-typing-ui`: The logger keeps its fast recording flow while allowing direct numeric weight entry and richer set interaction.
- `plan-template-editor`: Plans can define RPE targets and the metadata needed for unit-aware weight handling and later starting-load correction.
- `training-max-setup`: Plan activation preserves quick start while surfacing a path for exercises that need later load setup.
- `local-datastore-schema`: Session drafts, logs, and preferences persist the new RPE, unit, calculator, and equipment metadata.
- `editable-workout-history`: Edited workout logs preserve and expose target/actual RPE and unit context.
- `user-cloud-sync`: Completing a workout automatically kicks off a cloud sync attempt for signed-in users after the local save succeeds.

## Impact

- Affected code spans the training domain models, local/web persistence, seeded plan metadata, active-session UI/state, workout-log editing, settings/preferences, sync controller integration, localization, and tests.
- Public typed interfaces will gain new RPE, unit, equipment, and bar-weight preference fields.
- Existing browser and native data stores will need backward-compatible persistence updates for the expanded session and workout-log payloads.

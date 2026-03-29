## Why

Flutter Web currently fails during compilation because Isar-generated schema and index identifiers are emitted as integer literals that exceed JavaScript's exact integer range. The app already depends on those generated files at startup, so this blocks Chrome/Web runs entirely and needs a repeatable fix in the repository workflow.

## What Changes

- Add a deterministic normalization step for Isar-generated schema `id` literals that exceed JavaScript's exact integer range.
- Apply the normalization to the checked-in `lib/src/data/models/*.g.dart` files so current web builds compile again.
- Ensure web startup does not depend on native-only local file directory lookup before opening the datastore.
- Define local datastore compatibility requirements for generated schema metadata used by supported Flutter targets.

## Capabilities

### New Capabilities

### Modified Capabilities
- `local-datastore-schema`: Require generated local datastore schema metadata to remain compatible with Flutter Web JavaScript compilation.

## Impact

- Affected code: `lib/main.dart`, `lib/src/data/models/*.g.dart`, `tool/fix_isar_web_schema_ids.dart`
- Affected workflow: Isar code generation / checked-in generated files
- Affected platform: Flutter Web / Chrome builds

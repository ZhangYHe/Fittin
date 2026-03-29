## Context

`isar_generator` emits opaque collection/index identifiers into generated `*.g.dart` schema files. In this project, several emitted values are larger than JavaScript's exact integer range, which makes `flutter run -d chrome` fail before the application starts.

The current codebase checks generated Isar files into source control. Because Flutter Web compiles those files directly, the repository needs a deterministic post-generation normalization step instead of relying on manual edits.

## Goals

- Restore Flutter Web compilation without changing business data models.
- Keep the workaround narrow to generated schema identifier literals.
- Make the fix repeatable after future `build_runner` executions.

## Non-Goals

- Replacing Isar with a different persistence layer.
- Changing persisted business identifiers such as `templateId`, `instanceId`, or `logId`.
- Refactoring sync or repository architecture.

## Approach

1. Add a small Dart tool that scans `lib/src/data/models/*.g.dart`.
2. For each generated `id: <int>` literal, detect values outside JavaScript's exact integer range.
3. Rewrite unsafe values to the nearest exactly representable JavaScript integer using Dart's IEEE-754 double conversion.
4. Open Isar without a native filesystem directory on Web, while retaining the documents directory path for non-Web targets.
5. Run the tool once to update the checked-in generated files.

This keeps the workaround deterministic and easy to re-run after Isar regeneration.

## Risks and Mitigations

- Risk: Editing generated files by hand would be fragile.
  Mitigation: store the normalization logic in `tool/fix_isar_web_schema_ids.dart` and use it to rewrite files.

- Risk: Normalized schema/index identifiers differ numerically from Isar's original opaque hashes.
  Mitigation: only normalize the generated internal metadata values that are already unusable on Web; business identifiers and user data remain unchanged.

- Risk: Web startup can still fail before `runApp()` if native-only directory APIs are called.
  Mitigation: gate the local directory lookup behind a non-Web branch and use Isar's default Web opening path in browsers.

## Verification

- Run the normalization tool and confirm it patches the generated files.
- Run a Flutter Web build/start command and confirm the previous JavaScript integer literal errors disappear.

## ADDED Requirements

### Requirement: Web-Safe Generated Datastore Metadata
The local datastore MUST keep checked-in generated schema metadata compatible with every supported Flutter target, including JavaScript compilation for Flutter Web. Generated collection and index identifier literals that exceed JavaScript's exact integer range MUST be normalized before Web builds consume those files.

#### Scenario: Flutter Web compiles generated datastore schema
- **WHEN** the app is compiled for Chrome or another Flutter Web target
- **THEN** the generated local datastore schema files contain no identifier literal outside JavaScript's exact integer range
- **AND** compilation does not fail with integer precision errors from Isar-generated schema code

#### Scenario: Developers regenerate datastore schema files
- **WHEN** developers rerun Isar code generation and new `*.g.dart` schema files are produced
- **THEN** the repository provides a repeatable normalization step for unsafe identifier literals
- **AND** the generated files can be brought back to a Web-compatible state before commit or build

### Requirement: Web Datastore Startup Compatibility
The app MUST initialize the local datastore on Flutter Web without requiring native filesystem directory APIs before `runApp()`.

#### Scenario: Browser startup opens the datastore
- **WHEN** the app starts in Chrome or another Flutter Web runtime
- **THEN** datastore initialization avoids native-only local directory lookups
- **AND** the app reaches widget rendering instead of stalling on a blank page before first frame

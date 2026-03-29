# user-display-preferences Specification

## Purpose
Define how locally persisted display-name preferences personalize the Home Dashboard greeting for signed-in and signed-out users.

## Requirements
### Requirement: Configurable Home Display Name
The system MUST allow the user to set a custom display name from the settings surface, and the Home Dashboard greeting MUST use that value as the first-choice name source.

#### Scenario: User saves a custom display name
- **WHEN** the user enters a custom display name in settings and saves it
- **THEN** the app persists that preference locally
- **AND** the Home Dashboard greeting reflects the updated name without requiring a hardcoded fallback.

#### Scenario: User clears the custom display name
- **WHEN** the user removes the saved custom display name
- **THEN** the system falls back to the next available identity source
- **AND** the Home Dashboard continues to show a non-empty greeting name.

### Requirement: Local-First Name Resolution
The display-name preference MUST work for both signed-in and signed-out users.

#### Scenario: Signed-out user customizes greeting name
- **WHEN** a local-only user sets a display name in settings
- **THEN** the Home Dashboard uses that value in the greeting
- **AND** the feature does not require account authentication.

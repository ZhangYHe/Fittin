## ADDED Requirements

### Requirement: Session Unit And RPE Persistence
The local datastore MUST persist per-exercise session display units and optional target/actual RPE values in active workout drafts and saved workout logs.

#### Scenario: User refreshes after switching units and editing RPE
- **WHEN** the user changes one exercise to pounds, records an actual RPE, and then refreshes the app mid-session
- **THEN** the restored workout draft keeps the same per-exercise unit choice
- **AND** the restored draft preserves the target and actual RPE values already entered for each set.

### Requirement: Weight Tool Preference Persistence
The local datastore MUST persist the user's default kilogram and pound bar weights for plate calculations.

#### Scenario: User customizes default bar weights
- **WHEN** the user saves custom bar-weight preferences in settings
- **THEN** the datastore restores those values on the next app launch or browser refresh
- **AND** the weight tools surface uses the restored values for future calculations.

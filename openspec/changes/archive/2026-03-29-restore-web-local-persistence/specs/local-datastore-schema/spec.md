## ADDED Requirements

### Requirement: Browser-Persistent Local Datastore
The system MUST provide a browser-persistent local datastore implementation for Flutter Web instead of falling back to a session-only in-memory repository. The web datastore MUST preserve the same local entity categories required by the current application flow, including templates, active instances, workout logs, body metrics, progress photo metadata, app state, and sync queue records.

#### Scenario: User refreshes the web app
- **WHEN** a user creates or updates supported local records in the browser and then refreshes the page
- **THEN** the web app restores those records from browser-persistent local storage
- **AND** the user does not lose the local working set because of a page reload

#### Scenario: User reopens the web app later
- **WHEN** the same browser opens the web app again after a prior session stored local records
- **THEN** the app restores the prior local templates, instances, progress records, and app state
- **AND** the user can resume from the previously active local context

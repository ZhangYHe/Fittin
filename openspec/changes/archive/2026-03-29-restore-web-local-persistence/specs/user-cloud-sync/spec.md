## ADDED Requirements

### Requirement: Web Local Sync Queue Persistence
Flutter Web MUST persist local sync metadata and queue records in browser storage so user-owned local changes can survive refreshes and later synchronize with Supabase.

#### Scenario: Signed-in web user edits data offline
- **WHEN** a signed-in browser session creates or edits a sync-eligible local record without a successful cloud write yet
- **THEN** the browser persists the local sync status and queue entry across refreshes
- **AND** a later sync run can still detect and upload that pending change

#### Scenario: Signed-in web user resumes after refresh
- **WHEN** the browser reloads while it still has pending sync work for the authenticated user
- **THEN** the app restores the local sync queue and metadata from browser storage
- **AND** the next sync run continues processing those pending operations instead of treating them as lost

### Requirement: Web Cloud Hydration
Flutter Web MUST hydrate synchronized user-owned records from Supabase back into browser-local storage using the same entity coverage as supported native clients.

#### Scenario: Signed-in web user opens the app on an existing account
- **WHEN** a signed-in user with cloud-backed plans and logs opens the browser client
- **THEN** the web app restores those synchronized records into browser-local storage
- **AND** the browser client can continue from the synchronized local state after hydration completes

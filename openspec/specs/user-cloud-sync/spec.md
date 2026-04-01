## Purpose

Define how user-owned workout data synchronizes between the local datastore and Supabase-backed cloud storage.

## Requirements

### Requirement: User-Scoped Cloud Synchronization
The system MUST synchronize user-owned training data between the local datastore and Supabase under the authenticated user's identity. Synchronization MUST cover plans, active training instances, workout logs, body metrics, and progress photo metadata so the same signed-in user can recover a consistent state across launches and devices.

#### Scenario: Signed-in user launches the app on another device
- **WHEN** the same authenticated user opens the app on a different device
- **THEN** the app restores that user's cloud-backed plans, active training instances, workout logs, and progress records into local storage
- **AND** the user can continue from the previously synchronized state.

#### Scenario: User edits a personal plan while signed in
- **WHEN** a signed-in user saves changes to a user-owned training plan
- **THEN** the updated plan persists locally first
- **AND** the change is queued for Supabase synchronization under that user account.

#### Scenario: Signed-in user completes a workout
- **WHEN** a signed-in user successfully concludes a workout session
- **THEN** the workout log and updated training instance are saved locally first
- **AND** the app automatically starts a cloud sync attempt for that user without requiring a manual tap on the account screen.

#### Scenario: User completes a workout while offline
- **WHEN** a signed-in user finishes a workout without network access
- **THEN** the workout result is saved locally without blocking the training flow
- **AND** the result is uploaded to Supabase after connectivity and sync are restored.

#### Scenario: Signed-in user resumes after a pending sync failure
- **WHEN** the app has user-owned records that previously failed to upload or download
- **THEN** a later sync run retries the affected operations without duplicating the records
- **AND** the account surface exposes that a retry or recovery occurred.

#### Scenario: Auto sync fails after workout save
- **WHEN** the post-workout cloud sync attempt cannot finish successfully
- **THEN** the workout still remains saved locally
- **AND** the sync controller moves into its retry/recovery state instead of reporting the workout conclusion itself as failed.

### Requirement: First Login Merge
The system MUST merge or attach existing local data into the authenticated user's cloud scope when a local-only user signs in for the first time on a device. The merge flow MUST preserve the local working set and avoid destructive overwrites when equivalent cloud-backed records already exist.

#### Scenario: Local-only user signs in after using the app offline
- **WHEN** a user with existing local plans and workout history signs in on that device for the first time
- **THEN** the app preserves the existing local data
- **AND** it performs a first-login merge into the authenticated user's synchronized dataset instead of deleting or blindly overwriting that data.

#### Scenario: Signed-in user already has cloud-backed data
- **WHEN** the device contains local-only records and the authenticated account also already has synchronized plans or logs
- **THEN** the sync flow reconciles ownership and version metadata for each record type
- **AND** the app keeps conflicting records recoverable instead of silently losing either side.

### Requirement: Progress Photo Cloud Backup
The system MUST back up progress photo metadata and associated files in a way that preserves local viewing while enabling cross-device recovery.

#### Scenario: User backs up a progress photo
- **WHEN** a signed-in user saves a progress photo record
- **THEN** the app keeps a local reference for offline viewing
- **AND** uploads the photo file and metadata to Supabase-backed cloud storage for future restore.

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

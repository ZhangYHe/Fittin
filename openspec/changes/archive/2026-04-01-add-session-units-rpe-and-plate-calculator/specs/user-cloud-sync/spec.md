## MODIFIED Requirements

### Requirement: User-Scoped Cloud Synchronization
The system MUST synchronize user-owned training data between the local datastore and Supabase under the authenticated user's identity. Synchronization MUST cover plans, active training instances, workout logs, body metrics, and progress photo metadata so the same signed-in user can recover a consistent state across launches and devices.

#### Scenario: Signed-in user completes a workout
- **WHEN** a signed-in user successfully concludes a workout session
- **THEN** the workout log and updated training instance are saved locally first
- **AND** the app automatically starts a cloud sync attempt for that user without requiring a manual tap on the account screen.

#### Scenario: Auto sync fails after workout save
- **WHEN** the post-workout cloud sync attempt cannot finish successfully
- **THEN** the workout still remains saved locally
- **AND** the sync controller moves into its retry/recovery state instead of reporting the workout conclusion itself as failed.

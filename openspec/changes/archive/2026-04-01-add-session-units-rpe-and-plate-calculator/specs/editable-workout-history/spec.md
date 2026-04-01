## MODIFIED Requirements

### Requirement: Editable Recorded Set Values
The workout-log editor MUST allow the user to change recorded set values, including completed reps, recorded weight, recorded RPE, completion flags, and the workout completion timestamp for the selected workout log.

#### Scenario: User corrects logged set data
- **WHEN** the user changes set reps, set weight, or the completion time in the workout-log editor and saves
- **THEN** the stored workout log reflects the corrected values on the next load
- **AND** the record detail and analytics views render the updated workout data.

#### Scenario: User corrects recorded RPE and unit context
- **WHEN** the user edits a saved workout log that includes target or actual RPE and a chosen display unit
- **THEN** the editor preserves those fields during load
- **AND** saving the edit updates the same workout log with the corrected RPE and unit context instead of dropping them.

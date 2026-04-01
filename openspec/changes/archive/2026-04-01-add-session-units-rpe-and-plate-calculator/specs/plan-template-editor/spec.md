## MODIFIED Requirements

### Requirement: Exercise and Set Customization
The system MUST allow users to create, edit, duplicate, reorder, and delete exercises, stages, and sets within a workout template, including all core runtime fields.

When editing a set, the system MUST expose a structured set type selector instead of a boolean AMRAP toggle.

When editing an exercise, the system MUST allow selecting a load unit from the supported unit system, including `kg`, `lbs`, `bodyweight`, `cable_stack`, and `%1RM`.

When editing an exercise, the system MUST also allow defining the equipment context needed for runtime weight tools and the starting-load metadata needed for later correction.

#### Scenario: User customizes exercise prescription
- **WHEN** a user edits an exercise
- **THEN** they can modify the exercise name, tier, rest time, starting weight, stage names, set count, target reps, set types, load unit, and warmup vs working set roles before saving.

#### Scenario: User changes a set from straight work to AMRAP
- **WHEN** a user edits a set inside the plan editor
- **THEN** they choose from supported set types such as `straight_set`, `top_set`, `backoff_set`, or `amrap_set`
- **AND** the editor does not represent AMRAP as a simple on/off switch.

#### Scenario: User adds a custom accessory movement
- **WHEN** a user adds a new exercise to a workout
- **THEN** the editor creates a new ordered exercise entry with editable stages, sets, set types, and unit configuration that becomes part of the saved template.

#### Scenario: User defines target RPE and barbell metadata
- **WHEN** a user edits a set or exercise in the plan editor
- **THEN** they can define an optional target RPE for the set
- **AND** they can classify the exercise as barbell or non-barbell so the runtime logger knows whether plate guidance should appear.

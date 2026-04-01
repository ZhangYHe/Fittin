## Purpose

Define how training-max-driven programs collect, store, and use canonical training max values before an instance is created.

## Requirements

### Requirement: Program-Specific Training Max Setup
The system MUST require a training-max setup step before creating the first instance of a training-max-driven built-in plan.

The activation flow MUST still allow a quick-start path for exercises whose usable initial load will be completed later through plan editing, rather than blocking the entire plan start on a full per-exercise setup pass.

#### Scenario: User activates a built-in plan without an instance
- **WHEN** the user selects GZCLP or Jacked & Tan from the plan library and no existing instance is available for that template
- **THEN** the app prompts for the training max values required by that program before creating and activating the instance.

#### Scenario: User starts with quick start
- **WHEN** the plan still contains accessory exercises that do not yet have a complete independent starting-load setup
- **THEN** the app still lets the user activate the plan after the required canonical training max values are entered
- **AND** those unresolved exercises remain editable later from the plan editing flow instead of forcing an all-exercise setup upfront.

### Requirement: Canonical Lift Mapping
The system MUST store training max values by canonical lift keys and use template-defined mappings to derive exercise prescriptions from those values.

#### Scenario: User enters primary lift training maxes
- **WHEN** the user saves training max values for squat, bench, deadlift, and overhead press
- **THEN** the app stores those values as the instance's training-max profile
- **AND** exercises such as close-grip bench, slingshot bench, auxiliary squat, push press, and deadlift variations resolve their prescribed weights from the mapped primary lift key defined by the template.

#### Scenario: Built-in accessory movement has bench mapping
- **WHEN** a built-in accessory such as close-grip or narrow bench declares the bench training-max mapping
- **THEN** the first generated session resolves a usable starting load from the stored bench training max instead of defaulting to zero.

### Requirement: Derived Weight Calculation
The system MUST calculate prescribed working weights from training max plus template metadata instead of requiring users to enter fixed per-exercise working weights.

#### Scenario: Session weights are resolved after setup
- **WHEN** the user finishes training-max setup and opens the first scheduled workout
- **THEN** the session shows prescribed set weights that were calculated from the stored training max values, the template's percentage/increment metadata, and the program engine state.

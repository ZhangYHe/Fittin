## MODIFIED Requirements

### Requirement: Gesture-First Set Logging
The workout logger MUST preserve a gesture-first, low-friction flow for reps and weights without requiring keyboard input during a normal workout.

On the refactored training log screen, the primary visible controls MUST be limited to increment reps, decrement reps, weight adjustment, and set completion.

#### Scenario: Completing a working set
- **WHEN** the user records a set
- **THEN** they can adjust reps and weight using large touch targets or gestures instead of opening a text field.

### Requirement: Focused Single-Set Interaction
The active workout screen MUST prioritize the current set interaction over the full set list, presenting one dominant logging interaction for the active set.

The refactored logger MUST integrate exercise switching into the compact exercise preview rather than dedicating a separate full-width exercise rail in the default layout.

#### Scenario: Advancing through a workout
- **WHEN** the user moves from one set to the next
- **THEN** the screen keeps the current set control as the main interaction focal point and updates surrounding progress context accordingly.

### Requirement: No Rest Timer Dependency in Primary Layout
The redesigned workout logger MUST NOT require a visible rest timer module as part of its primary layout composition.

The refactored logger MUST also NOT expose a visible reset-reps action in the primary layout.

#### Scenario: Using the redesigned logger
- **WHEN** the user logs reps and completes sets
- **THEN** the main screen remains focused on set interaction and set progression without a rest timer surface or reset-reps control occupying prime space.

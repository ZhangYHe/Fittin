## MODIFIED Requirements

### Requirement: Correct Set Recording Controls
The current-set control area MUST expose valid and useful actions for set recording while supporting faster direct editing.

The screen MUST include:
- increment reps
- decrement reps
- adjust current recorded weight
- direct numeric weight entry from the current weight display
- edit recorded RPE
- complete/log current set

The screen MUST NOT include a reset-reps action.

#### Scenario: Adjusting reps during a set
- **WHEN** the user taps the decrement control
- **THEN** completed reps decrease by one but never below zero.

#### Scenario: Logging the current set
- **WHEN** the user taps the set completion action
- **THEN** the current set is marked complete and the session advances to the next logical set or exercise state.

#### Scenario: Entering weight directly
- **WHEN** the user long-presses the current weight display
- **THEN** the logger opens a direct numeric entry path for the current set's weight
- **AND** saving the value updates the same set without requiring repeated plus/minus taps.

#### Scenario: Recording actual RPE
- **WHEN** the current set includes a target RPE or the user wants to record exertion
- **THEN** the logger shows an editable actual RPE control for that set
- **AND** the user can save the set with reps, weight, and RPE together.

### Requirement: Lightweight Progress Indicator
The logger MUST represent set progress in a compact visual indicator rather than relying on an expanded scrolling set list.

#### Scenario: Seeing current progress
- **WHEN** the user is on set 3 of 6
- **THEN** the progress strip clearly shows completed sets, the active set, and remaining sets in a compressed layout.

#### Scenario: Jumping to a set from the progress strip
- **WHEN** the user taps a set marker in the progress strip
- **THEN** the logger focuses that set for editing
- **AND** the current-set controls update to the tapped set instead of remaining locked to the previous position.

### Requirement: Compact Exercise Preview
The top exercise preview MUST be reduced in height and only show information needed for the current recording decision.

The preview MUST include:
- current exercise name
- current set index and total set count
- tier
- target weight and reps or AMRAP marker
- target RPE when present
- the active display unit for the exercise

The preview MUST NOT show:
- scheme / stage identifier as a visible field
- completed set count summary text
- previous set weight x reps summary text
- extra explanatory subtitle text

#### Scenario: Viewing the active exercise
- **WHEN** the user opens the workout logger
- **THEN** the top preview is visually compact and does not include scheme, previous-set summary, or redundant helper copy.

#### Scenario: Switching exercise unit display
- **WHEN** the user changes the active exercise between kg and lb
- **THEN** the preview and current-set controls update the displayed target and actual weight values to the selected unit
- **AND** the choice applies only to that exercise inside the current workout session.

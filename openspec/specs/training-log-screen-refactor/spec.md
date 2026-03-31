## Purpose

Define the compact single-screen workout logger layout, controls, and interaction model for mobile-first set logging.

## Requirements

### Requirement: Single-Screen Mobile Workout Logger
The training log screen MUST present its core recording workflow within a single mobile viewport for common phone sizes, without requiring vertical scrolling during normal set logging.

The visible primary layout MUST include:
- workout context header
- compact exercise preview
- current-set controls
- set progress
- conclude workout action

#### Scenario: Recording a normal working set on mobile
- **WHEN** the user opens an active workout on a typical phone-sized viewport
- **THEN** they can see and use the current exercise preview, current-set controls, progress indicator, and conclude action without scrolling the page vertically.

### Requirement: Compact Exercise Preview
The top exercise preview MUST be reduced in height and only show information needed for the current recording decision.

The preview MUST include:
- current exercise name
- current set index and total set count
- tier
- target weight and reps or AMRAP marker

The preview MUST NOT show:
- scheme / stage identifier as a visible field
- completed set count summary text
- previous set weight x reps summary text
- extra explanatory subtitle text

#### Scenario: Viewing the active exercise
- **WHEN** the user opens the workout logger
- **THEN** the top preview is visually compact and does not include scheme, previous-set summary, or redundant helper copy.

### Requirement: Exercise Switching Inside Preview
Exercise switching MUST be integrated into the exercise preview via a compact icon action that opens a premium dropdown or anchored menu.

The menu MUST:
- list all exercises in the current workout
- highlight the active exercise
- allow switching with one tap
- animate with restrained premium motion

#### Scenario: Switching exercises from the preview
- **WHEN** the user taps the exercise switch icon in the preview card
- **THEN** the app opens a compact animated menu from that control and lets the user switch to another exercise without using a separate full-width rail.

### Requirement: Workout Context Title Format
The workout header MUST combine week/day context and workout name into a single compact title string.

The preferred format MUST be `WnDn-Workout Name`.

#### Scenario: Opening the first workout of week one
- **WHEN** the user opens the first workout in week one
- **THEN** the header title is shown in a compact combined form such as `W1D1-Squat & Pull`.

### Requirement: Correct Set Recording Controls
The current-set control area MUST expose only valid and useful actions for set recording.

The screen MUST include:
- increment reps
- decrement reps
- adjust current recorded weight
- complete/log current set

The screen MUST NOT include a reset-reps action.

#### Scenario: Adjusting reps during a set
- **WHEN** the user taps the decrement control
- **THEN** completed reps decrease by one but never below zero.

#### Scenario: Logging the current set
- **WHEN** the user taps the set completion action
- **THEN** the current set is marked complete and the session advances to the next logical set or exercise state.

### Requirement: Lightweight Progress Indicator
The logger MUST represent set progress in a compact visual indicator rather than relying on an expanded scrolling set list.

#### Scenario: Seeing current progress
- **WHEN** the user is on set 3 of 6
- **THEN** the progress strip clearly shows completed sets, the active set, and remaining sets in a compressed layout.

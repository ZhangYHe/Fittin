## MODIFIED Requirements

### Requirement: Focused Workout Console Composition
The active workout experience MUST present the current exercise and current set as the dominant focal element in a console-style layout.

For the compact logger refactor, this composition MUST be compressed enough to fit the essential recording flow within a single mobile viewport and MUST avoid oversized preview modules that push controls below the fold.

#### Scenario: Logging a working set on mobile
- **WHEN** the user opens the refactored workout logger
- **THEN** the exercise preview is compact, the current-set controls remain above the fold, and the page reads as one coherent console instead of a long stacked screen.

### Requirement: Reference-Inspired but App-Native Workout Interaction
The workout console MAY draw interaction inspiration from focused gym logging apps, but it MUST remain consistent with the app's own data model, bilingual support, and current training flow.

The refactor MUST use a compact exercise-switch action with premium dropdown animation rather than reproducing a large separate exercise rail from earlier iterations.

#### Scenario: Switching to another exercise
- **WHEN** the user invokes the compact exercise-switch control
- **THEN** the transition feels polished and premium, but the result still uses the app's existing workout/session model and localized exercise names.

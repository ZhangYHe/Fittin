## 1. Layout Refactor

- [x] 1.1 Compress the workout header into a single `WnDn-Workout Name` title and remove the extra helper subtitle.
- [x] 1.2 Reduce the exercise preview card height and remove the visible scheme field, completed summary text, and previous set summary text.
- [x] 1.3 Move tier and target into the compact preview metadata row and verify the screen fits within a common mobile viewport without normal vertical scrolling.

## 2. Exercise Switching

- [x] 2.1 Remove the dedicated full-width exercise switch rail from the default layout.
- [x] 2.2 Add a compact icon trigger inside the exercise preview that opens a premium anchored menu or dropdown for exercise switching.
- [x] 2.3 Show localized exercise names, active state, and progress context inside the switch menu.

## 3. Current Set Controls

- [x] 3.1 Remove the reset-reps action from the current-set control area.
- [x] 3.2 Verify decrement, increment, weight adjustment, and log-set actions all map to the correct current-set behavior.
- [x] 3.3 Add a dedicated current-set completion action that correctly advances through set/exercise progression.

## 4. Progress And Finish Flow

- [x] 4.1 Keep a compact set progress indicator that fits the one-screen layout.
- [x] 4.2 Ensure the conclude-workout action remains visible in the compact composition and does not require scrolling in typical mobile cases.

## 5. Verification

- [x] 5.1 Update training log widget tests for the compact header, compact preview, integrated switch control, and revised current-set actions.
- [x] 5.2 Run targeted tests and analyze output for the training log flow.

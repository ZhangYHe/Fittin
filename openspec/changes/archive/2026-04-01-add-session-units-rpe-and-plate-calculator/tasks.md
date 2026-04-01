## 1. OpenSpec And Model Foundations

- [x] 1.1 Add change artifacts for weight tools, unit switching, RPE, and quick-start load behavior.
- [x] 1.2 Extend training-plan, session, and workout-log domain models with equipment, unit, and RPE fields.
- [x] 1.3 Update persistence layers and preference APIs for bar-weight defaults plus backward-compatible draft/log decoding.

## 2. Logger Interaction Upgrades

- [x] 2.1 Add per-exercise kg/lb switching and canonical kg conversion in the active-session notifier.
- [x] 2.2 Add direct weight entry, editable RPE, and tappable set-progress navigation to the active workout screen.
- [x] 2.3 Add completion animation feedback and barbell plate guidance to the active workout flow.

## 3. Settings And Weight Tools

- [x] 3.1 Add bilingual weight tools UI in settings with kg/lb conversion and editable default bar weights.
- [x] 3.2 Add a reusable calculator sheet that can also be launched from the workout logger with current-set context.

## 4. Plan And Log Integration

- [x] 4.1 Extend the plan editor to support target RPE, equipment classification, and later starting-load correction metadata.
- [x] 4.2 Update plan activation and seed metadata so mapped accessory lifts resolve usable starting loads while quick start remains available.
- [x] 4.3 Update workout-log save/edit flows so recorded RPE and unit context round-trip correctly.
- [x] 4.4 Trigger automatic cloud sync after workout completion for signed-in users without blocking local workout save success.

## 5. Verification

- [x] 5.1 Add model, provider, and UI tests for unit switching, direct weight entry, set jumping, and set-complete feedback.
- [x] 5.2 Add tests for calculator preferences, plate breakdown logic, and accessory-load initialization behavior.
- [x] 5.3 Add regression coverage for post-workout auto sync, including signed-in and signed-out behavior.

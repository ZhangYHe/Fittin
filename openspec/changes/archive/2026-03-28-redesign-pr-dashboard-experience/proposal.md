## Why

The current PR Dashboard ships as a good-looking prototype, but it still behaves like a thin demo instead of a production analytics destination. The headline 1RM cards become visually inconsistent when a lift has no previous record to compare against, the progression chart combines multiple lifts into one low-information graph, the milestone section dumps too many entries into the main page, and the whole surface still ignores the app's bilingual language setting.

## What Changes

- Redesign the top summary cards so Squat, Bench, and Deadlift always share the same visual footprint regardless of whether a delta is available.
- Add a single compact control that lets the user switch the top summary cards between estimated 1RM and actual PR mode.
- Replace the combined progression chart with a per-lift chart viewer that supports switching the displayed lift and shows explicit x/y axes.
- Limit the dashboard's recent milestone preview to the two newest items and add a dedicated milestone history screen with filters for lift, date range, and PR type.
- Localize the PR Dashboard and its milestone browser so all visible copy follows the selected app language.

## Capabilities

### Modified Capabilities
- `pr-dashboard`: rebuild the PR Dashboard into a bilingual, per-lift analytics surface with a focused summary, richer charting, and navigable milestone history.

## Impact

- Affected code will likely include the PR dashboard provider, the PR dashboard screen, chart widgets, navigation to a new milestone history screen, and localization strings.
- The milestone model may need richer metadata so the UI can filter by exercise, time, and PR type.
- Existing PR dashboard tests will need to be expanded to cover mode toggles, chart switching, milestone navigation, filtering, and Chinese copy.

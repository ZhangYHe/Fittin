## 1. Home Data Composition

- [x] 1.1 Add a local-first display-name preference model and resolution logic with fallback order for signed-in and signed-out users.
- [x] 1.2 Extend the today-workout summary/composition layer to expose active plan `week` and `day` metadata for the home hero card.
- [x] 1.3 Create a home dashboard provider/view model that combines greeting context, progress metrics, big-three E1RM sparkline data, and recent milestone inbox data.

## 2. Home Screen UI Refresh

- [x] 2.1 Replace the hardcoded home header with a live time-of-day greeting, resolved display name, and a single milestone notification action.
- [x] 2.2 Refactor the workout hero card to emphasize current plan `week` and `day` while preserving real workout title, lead lift, exercise count, and session launch behavior.
- [x] 2.3 Replace the placeholder overview cards with a tappable nested-ring progress card that routes to Trends & Analytics and a swipeable big-three E1RM sparkline card that routes to the PR Dashboard.

## 3. Settings and Milestone Flows

- [x] 3.1 Add a settings UI control that lets the user create, edit, and clear the custom display name used on the home screen.
- [x] 3.2 Implement the milestone notification surface from the home header, including unread-indicator behavior and recent milestone rendering from real data.

## 4. Verification

- [x] 4.1 Add or update provider and widget tests covering greeting resolution, week/day hero content, nested progress metrics, sparkline lift paging, milestone notification behavior, and display-name editing.
- [x] 4.2 Validate the updated OpenSpec change and run the relevant Flutter test suite for the refreshed home experience.

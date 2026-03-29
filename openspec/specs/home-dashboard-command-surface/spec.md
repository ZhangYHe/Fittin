# home-dashboard-command-surface Specification

## Purpose
Define how the Home Dashboard header and overview cards surface live, actionable training information instead of placeholder content.

## Requirements
### Requirement: Live Home Greeting and Header Actions
The Home Dashboard MUST render a greeting that reflects the user's real local time of day and a resolved display name rather than hardcoded placeholder text. The header MUST expose a milestone notification entry point and MUST NOT show an unused avatar action.

#### Scenario: User opens the home dashboard in the morning
- **WHEN** the user opens the Home Dashboard during a morning local time window
- **THEN** the greeting copy reflects the morning period in the active app language
- **AND** the name line uses the resolved user display name rather than a hardcoded placeholder.

#### Scenario: User has no unseen milestones
- **WHEN** the home header loads and there are no unseen milestone entries
- **THEN** the notification icon remains available as the milestone inbox entry point
- **AND** it does not show a false unread indicator.

#### Scenario: User opens the milestone inbox from home
- **WHEN** the user taps the notification icon
- **THEN** the app shows recent training milestone entries sourced from real milestone data
- **AND** the avatar action is absent from the header.

### Requirement: Actionable Home Overview Cards
The Home Dashboard MUST replace placeholder overview widgets with live, navigation-aware cards that summarize training progress and big-three strength momentum.

#### Scenario: User views progress summary card
- **WHEN** the Home Dashboard loads with an active training plan instance
- **THEN** the left overview card shows nested progress rings for current-week completion and overall cycle or block completion
- **AND** tapping the card navigates to the Trends & Analytics destination.

#### Scenario: User views strength sparkline card
- **WHEN** the Home Dashboard loads available big-three progress data
- **THEN** the right overview card shows a compact E1RM line chart for one primary lift at a time
- **AND** the user can swipe between Squat, Bench, and Deadlift within the card
- **AND** tapping the card navigates to the PR Dashboard.

#### Scenario: User has incomplete analytics data
- **WHEN** one or more overview data sources are missing or sparse
- **THEN** the Home Dashboard still renders stable cards with empty-state copy or fallback visuals
- **AND** the overall card layout does not collapse into placeholder demo values.

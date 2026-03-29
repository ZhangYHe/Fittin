## Why

The current Home Dashboard still contains several placeholder surfaces, including a hardcoded greeting, demo overview cards, and disconnected top-right actions. That makes the app's primary landing page feel visually polished but operationally unreliable, especially now that plan progress, PR analytics, and milestone data already exist elsewhere in the product.

Refreshing the home experience now lets the app's first screen reflect real training state: the user's actual time-of-day greeting, active plan position, true weekly and block progress, current big-three strength trend, and recent milestone notifications.

## What Changes

- Replace the hardcoded greeting with a real time-of-day greeting and a user-configurable display name sourced from settings.
- Update the workout hero card so it shows the active plan's current `week` and `day` position instead of the current demo-style `day + minutes` emphasis.
- Replace the placeholder overview cards with live home modules:
- a nested dual-ring progress card showing weekly progress and overall block progress, tappable to open Trends & Analytics
- a compact swipeable big-three E1RM line chart card, tappable to open the PR Dashboard
- Connect the top-right notification affordance to real training milestone data and remove the unused user avatar action from the header.
- Preserve the existing premium visual language while making the home screen behavior data-driven and navigation-aware.

## Capabilities

### New Capabilities
- `home-dashboard-command-surface`: defines the live greeting, actionable overview cards, and milestone notification behavior for the Home Dashboard header and at-a-glance section.
- `user-display-preferences`: defines how the user customizes the display name used in the Home Dashboard greeting from the settings surface.

### Modified Capabilities
- `today-workout-gateway`: the Home Dashboard hero card now emphasizes real active-plan week/day position instead of a placeholder-style duration-focused summary.

## Impact

- Affected presentation surfaces include the Home Dashboard, workout hero card, settings/account area, and notification entry UI.
- Affected application logic likely includes today-workout summary shaping, progress aggregation for weekly/block completion, PR snapshot sourcing, and milestone notification querying.
- New or extended persisted preferences may be needed for the user-defined display name.
- Existing analytics and milestone data sources can be reused; no external API changes are expected.

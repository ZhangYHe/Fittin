## Context

The current Home Dashboard mixes polished visuals with placeholder content. The greeting is hardcoded, the hero card does not emphasize the active plan position the user actually cares about, the overview cards are not backed by real training data, and the top-right actions are decorative rather than functional.

This change cuts across the home screen, workout summary shaping, settings, and analytics/milestone data reuse. The app already has reusable data sources for scheduled workouts, progress analytics, and PR milestones, so the design should prefer composition over adding parallel data pipelines.

## Goals / Non-Goals

**Goals:**
- Drive the home greeting from the real local time and a user-configurable display name.
- Show the active plan's current `week` and `day` position in the workout hero card.
- Replace placeholder overview surfaces with live progress and strength modules that deep-link into existing analytics destinations.
- Wire the notification action to real milestone data and remove the unused avatar action.
- Preserve the current premium home visual language while making the behavior trustworthy.

**Non-Goals:**
- Redesign the Trends & Analytics or PR Dashboard destinations themselves.
- Introduce push notifications, background delivery, or server-side inbox infrastructure.
- Add social/profile management beyond a lightweight display-name preference.
- Rework the bottom navigation structure.

## Decisions

### 1. Store the custom display name as a local-first user preference
The display name will be modeled as a lightweight app preference rather than a required authenticated profile field. The home header resolves the name in this order: custom display name, authenticated profile display name, authenticated email local-part, localized fallback label.

This keeps the feature usable for signed-out users and avoids coupling the home greeting to Supabase profile-edit flows. If cloud sync for preferences is added later, the same value can be mirrored without changing the home-screen contract.

Alternative considered:
- Store the name only in Supabase user metadata. Rejected because it would exclude local-first users and create unnecessary dependency on account state.

### 2. Extend the today-workout summary with active plan position metadata
The `TodayWorkoutGateway` summary should expose the active plan cursor needed by the hero card, specifically current week/block position and day position. The home hero should still show workout name, lead lift, and exercise count, but the secondary emphasis changes from `day + minutes` to `week + day`.

This keeps one source of truth for the home workout surface and avoids making the widget reconstruct progression state from lower-level plan data.

Alternative considered:
- Compute week/day entirely inside the widget from repository state. Rejected because it duplicates plan-engine knowledge inside presentation code.

### 3. Use a dedicated home-dashboard view model that composes existing providers
The home screen should read from a single composition provider that merges:
- the today-workout summary
- progress/block completion derived from the active instance and workout plan structure
- big-three E1RM snapshots derived from progress analytics
- recent milestone data reused from PR analytics or a shared milestone builder
- display-name preference and current locale/time context

This keeps the screen declarative and prevents multiple nested async states from leaking into the widget tree.

Alternative considered:
- Let each card fetch its own provider independently. Rejected because it complicates loading/error states and makes the home screen harder to reason about.

### 4. Represent the progress card as nested weekly/block completion rings
The left overview card should show two concentric progress rings:
- inner ring: current week completion
- outer ring: overall block or cycle completion

The card should also expose readable labels/percentages so the visualization remains interpretable. Tapping the card navigates to Trends & Analytics.

Alternative considered:
- Replace the ring with numeric stats only. Rejected because the user explicitly wants progress to read at a glance and the nested-ring metaphor matches that requirement.

### 5. Replace the placeholder activity card with a swipeable lift sparkline card
The right overview card should become a compact horizontally swipeable big-three E1RM chart. Each page shows one lift at a time with a small line graph and latest value, while the card as a whole remains a simple dashboard object rather than a full analytics chart. Tapping the card navigates to the PR Dashboard.

This keeps the home surface lightweight while still reflecting real strength momentum.

Alternative considered:
- Show three tiny charts at once. Rejected because it would reduce legibility and increase visual clutter in the small card footprint.

### 6. Treat the notification icon as a milestone inbox entry point
The bell action should surface recent training milestones from the same milestone source used by the PR Dashboard. A small indicator appears only when there are unseen milestone entries newer than the last viewed timestamp stored locally. Opening the milestone panel marks the feed as seen.

Alternative considered:
- Reuse the PR Dashboard screen directly when tapping the bell. Rejected because the bell should act like a lightweight inbox rather than a full destination switch.

## Risks / Trade-offs

- [Progress semantics may be ambiguous across program engines] → Define week completion from the current visible week/workout slice and block completion from total scheduled workouts completed within the active template or phase.
- [Display-name preference can drift from cloud account identity] → Resolve local custom name first and treat it as presentation-only, not auth identity.
- [Milestone inbox may duplicate PR dashboard information] → Keep the bell surface concise and recent-item-focused so it complements rather than replaces the PR Dashboard.
- [Home composition provider could become too broad] → Limit it to values needed for first-screen rendering and navigation, while delegating detailed analytics to existing destinations.

## Migration Plan

- Add the new display-name preference with a safe default fallback path so existing users see no migration prompt.
- Extend the home/dashboard composition layer and hero summary model without changing active session launch behavior.
- Ship the new home cards and bell sheet behind the same home route; rollback is simply reverting to the previous widgets because no destructive data migration is required.

## Open Questions

- Whether block progress should be based on the entire template length or the currently active phase when a template has multiple phases.
- Whether the milestone bell should open a modal sheet, full page, or anchored panel from the header.
- Whether the display-name editing control belongs on the main account screen or a nested profile preferences section.

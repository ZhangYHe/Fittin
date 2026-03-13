## ADDED Requirements

### Requirement: Premium Minimal Dark Material Language
The system MUST present the active workout, progress analytics, and profile/settings screens using a premium minimal dark material language rather than flat black surfaces.

This presentation MUST include:
- tonal separation between page background and surfaces
- layered cards or modules with soft edge treatment
- restrained highlight or glow on the primary focus area
- premium, high-contrast typography for the most important values
- a secondary text color system that clearly separates metadata from primary content
- controlled accent usage so primary CTA color does not feel disconnected from the rest of the screen

#### Scenario: Opening a non-home primary screen
- **WHEN** the user opens the workout logger, analytics page, or profile/settings page
- **THEN** the screen should feel intentionally layered and premium instead of appearing as a single flat black slab.

#### Scenario: Comparing page background and cards
- **WHEN** a user looks at plan library, analytics, profile, or workout surfaces
- **THEN** cards and page background should be visibly different in tone or material so the UI does not collapse into one undifferentiated black mass.

### Requirement: Focused Workout Console Composition
The active workout experience MUST present the current exercise and current set as the dominant focal element in a console-style layout.

The screen MUST prioritize:
- current exercise identity
- set progress
- current reps and weight
- a dominant set-logging interaction

Non-current exercises MUST be secondary to the active set context.

#### Scenario: Logging a working set
- **WHEN** the user is in an active workout session
- **THEN** the screen centers attention on the current exercise and current set instead of distributing equal emphasis across the full workout list.

### Requirement: Premium Management Screens
The plan library and plan editor MUST also adopt the premium minimal material language so plan management does not visually regress relative to workout, analytics, and profile screens.

Plan management surfaces MUST include:
- stronger title/description hierarchy
- premium metadata chips or badges
- CTA emphasis that clearly distinguishes primary vs secondary actions
- grouped editor modules instead of raw form-like vertical stacks

#### Scenario: Browsing templates in the plan library
- **WHEN** the user views available plans
- **THEN** each plan card feels like a designed premium object with clear hierarchy and not just a large dark form block.

### Requirement: Avoid Flat Black UI
The redesign MUST explicitly avoid screens where background, surface modules, and control tiles collapse into the same near-black appearance.

#### Scenario: Scanning a premium page quickly
- **WHEN** the user glances at a redesigned screen
- **THEN** they can immediately distinguish background, hero module, secondary modules, chips, and CTA areas without relying only on text to find structure.

### Requirement: Reference-Inspired but App-Native Workout Interaction
The workout console MAY draw interaction inspiration from focused gym logging apps, but it MUST remain consistent with the app's own data model, bilingual support, and current training flow.

#### Scenario: Comparing the redesigned workout screen with the current app
- **WHEN** the user uses the redesigned logger
- **THEN** it should feel more concentrated and premium while still fitting the app's program/session structure rather than behaving like a copied external interface.

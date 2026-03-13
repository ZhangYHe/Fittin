## Context

The previous `frontend-unification` change improved consistency, but it still treated the problem as a layout normalization exercise. The user's updated direction is stricter: the app should feel simple, dark, and premium, with depth and restraint instead of flat black pages. The homepage is currently the strongest reference in the codebase because it already uses spacing, soft surfaces, and a more intentional hierarchy.

The most important redesign target is the active workout screen. It is currently structured like a scrolling form, while the desired experience is closer to a focused training console: one active exercise, one active set, one dominant rep action, and supporting controls around it. The provided reference is useful for interaction emphasis and hierarchy, but we should not copy it literally. We will adapt its focused control model into the app's existing data model and bilingual requirements.

The latest screenshots also make the current shortcomings more concrete:
- most screens are using black backgrounds plus dark cards, but the tonal difference is too small to create real depth
- large cards still behave like default form containers rather than premium modules with intent
- plan library and analytics cards feel oversized but not luxurious because they lack focal lighting, rhythm, and differentiated secondary text treatment
- the active workout page still reads like a list of sections instead of a performance console
- the bottom navigation bar has glow, but the pages above it do not carry the same material language, so the product feels visually split
- action colors are currently too binary, especially the bright cyan CTA against otherwise flat black cards, which makes screens feel utilitarian rather than premium
- plan editor uses raw text fields, outline dividers, and icon rows in a way that reads like an admin tool instead of a crafted product surface
- analytics summary tiles repeat one card recipe too many times, which removes hierarchy and visual tension

## Goals / Non-Goals

**Goals:**
- Establish a premium minimal dark visual system for non-home primary screens.
- Convert the active workout page from a stacked list to a focused console centered on the current exercise and current set.
- Make analytics and profile/settings feel intentionally designed, layered, and premium rather than plain black lists.
- Preserve fast logging, bilingual text, current data flows, and existing navigation destinations.

**Non-Goals:**
- Do not redesign the home dashboard itself.
- Do not introduce a full custom design system framework or remote token pipeline.
- Do not change workout logic, analytics calculations, or program rules.
- Do not add a rest timer module to the redesigned active workout screen.

## Decisions

### 1. Move from “soft dashboard cards” to “premium dark layered surfaces”
The new visual language should still inherit the homepage's spacing and composure, but it needs a stronger dark identity:
- near-black background with subtle tonal separation
- translucent or satin-like surface cards with soft inner highlights
- restrained edge glow around primary controls
- larger contrast between primary focal module and secondary modules
- fewer generic list rows and more sculpted grouped blocks
- content-specific interior hierarchy so cards contain bright focal content, quieter metadata, and deliberate empty space

This creates a more premium impression without becoming visually noisy.

To achieve this, cards need stronger internal art direction:
- brighter hero headline/value area
- lower-contrast descriptive copy
- metadata chips that sit in their own dim material layer
- action rows that feel anchored rather than appended

### 2. Make the active session a focused console, not a scrolled form
The active session will pivot around the current exercise and current set:
- top brand/title strip and lightweight exit/navigation affordance
- hero card for current exercise, set progress, and previous performance
- one dominant central action for rep adjustment or set confirmation
- nearby controls for weight and set navigation
- compact set history/log indicator below
- persistent log/complete CTA at the bottom

The broader workout still exists, but non-current exercises move to a secondary selector rather than sharing equal visual weight with the active set content.

### 3. Remove rest time from the visual center of the workout redesign
The user's latest instruction explicitly says the redesign does not need rest time. We will therefore:
- remove rest from primary workout controls
- avoid large timer UI in the redesigned active workout console
- keep workout flow focused on logging and moving through sets

Any existing timer behavior can remain functionally available in code if needed later, but it should not shape the new primary layout.

### 4. Use premium restraint rather than decoration overload
Premium should come from proportion, lighting, and hierarchy, not from heavy gradients everywhere. The design rules are:
- one hero glow area per screen
- one dominant primary action area
- secondary controls use dimmer materials and lower contrast
- typography stays bold and crisp, not playful
- motion remains short and tactile
- borders should be soft and light-catching, not thick outline strokes
- muted copy should use warmer gray values instead of raw low-opacity white
- brand accents should be controlled and desaturated enough to feel premium, avoiding overly electric CTA treatments

### 5. Fix the current “flat black UI” failure mode explicitly
The screenshots show that simply placing rounded dark cards on a black background is not enough. The redesign must explicitly avoid:
- same-tone black background and card surfaces
- cards where title, body, metadata, and controls all share one contrast level
- form-like text field stacks presented as premium content
- random neon accents without broader material consistency

Instead, each premium screen should establish:
- a visible hero module
- at least one clear secondary module style
- one consistent control-tile style
- one consistent large CTA style
- one clear rule for accent color usage so the eye knows what is primary

### 6. Separate screen-specific composition from shared visual primitives
We still need shared building blocks, but they should support the new art direction:
- premium page background
- layered surface card
- glow CTA surface
- compact dim control tile
- section eyebrow / screen title combo
- richer chip/badge styles for plan metadata and selection states

The console-specific workout layout should remain local to the active session screen, because it is a distinct interaction environment rather than a generic dashboard section.

### 7. Analytics and profile should echo the same material language, not the same layout
The redesign should not force all screens into a single composition:
- analytics remains a vertical reading experience with grouped insight modules
- profile/settings remains a stacked preferences page with premium grouped controls
- both should share the same background, surfaces, typography, and motion language as the workout console
- plan library and plan editor should also inherit the same premium material system, because the screenshots show they are currently major offenders

Specific screen adjustments guided by the screenshots:
- plan library should move from large informational slabs to more editorial plan cards with a better relationship between title, description, badges, and actions
- plan editor should stop looking like a generic CRUD tool and instead treat each workout/exercise block like a premium composition module
- analytics should stop stacking near-identical stat blocks and instead use one hero metric zone plus calmer secondary cards
- profile/settings should keep the current grouped approach but gain more deliberate highlight, tile selection, and vertical rhythm

### 8. Extend the redesign scope to plan library and plan editor
The screenshots reveal that plan management screens are also visually weak and highly visible in the product flow. The redesign scope should therefore cover:
- plan library cards
- plan editor form/group blocks
- plan action buttons and metadata chips

This is still presentational work, but it must be part of the same premium system to avoid immediately reintroducing inconsistency.

## Risks / Trade-offs

- [Focused workout console may hide multi-exercise context] -> Keep a compact exercise selector and visible set/workout progress so users do not lose orientation.
- [Dark premium treatment may reduce legibility] -> Reserve the brightest contrast for current set values, primary actions, and key labels.
- [Reference-inspired redesign may drift from current app style] -> Use the homepage's spacing and restraint as the base layer, then add premium dark material treatment on top.
- [Bilingual strings may break tighter premium layouts] -> Require large enough control widths and flexible text wrapping for Chinese labels.

## Implementation Approach

1. Create a stronger presentation layer for dark premium backgrounds, layered cards, and glow CTA surfaces.
2. Recompose active session into a focused console:
   - current exercise hero
   - current set progress
   - dominant rep interaction module
   - supporting weight/reset controls
   - set log strip
   - bottom CTA
3. Recompose analytics into premium grouped insight modules with stronger hero hierarchy.
4. Recompose profile/settings into richer grouped sections with premium preference tiles.
5. Recompose plan library and plan editor into premium management surfaces with improved hierarchy.
6. Update widget tests to validate navigation, bilingual labels, and basic redesigned-screen rendering.

## Wireframe

```text
Active Session
┌──────────────────────────────────────┐
│ minimal top bar / brand / close      │
├──────────────────────────────────────┤
│ current exercise hero                │
│ exercise name / set 2 of 4 / prev    │
├──────────────────────────────────────┤
│          large central rep action    │
│     side controls / reset / weight   │
├──────────────────────────────────────┤
│ current reps + target / current kg   │
├──────────────────────────────────────┤
│ compact set log progression strip    │
├──────────────────────────────────────┤
│ primary log / complete CTA           │
│ secondary workout navigation         │
└──────────────────────────────────────┘

Progress Analytics
┌──────────────────────────────────────┐
│ screen title / formula control       │
├──────────────────────────────────────┤
│ premium highlight summary module     │
│ mixed card sizes, stronger focal row │
├──────────────────────────────────────┤
│ grouped exercise insight cards       │
│ with softer secondary contrast       │
└──────────────────────────────────────┘

Profile / Settings
┌──────────────────────────────────────┐
│ profile hero / app settings intro    │
├──────────────────────────────────────┤
│ language group                       │
│ premium selection tiles              │
├──────────────────────────────────────┤
│ future settings slots / info cards   │
└──────────────────────────────────────┘

Plan Library / Editor
┌──────────────────────────────────────┐
│ stronger title / subtitle hierarchy  │
├──────────────────────────────────────┤
│ premium template cards with          │
│ metadata chips + clear CTA weight    │
├──────────────────────────────────────┤
│ editor sections as grouped modules   │
│ not raw stacked text fields          │
└──────────────────────────────────────┘
```

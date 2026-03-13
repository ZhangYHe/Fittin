## Why

The current non-home screens are visually flatter and harsher than the home dashboard, so the app still feels inconsistent and cheap instead of simple and premium. This change is needed now because the workout logger, analytics page, and profile page are high-frequency surfaces, and their current black-on-black treatment does not deliver the intended brand quality.

## What Changes

- Redesign the active workout, progress analytics, and profile/settings screens around a premium minimal visual language rather than a generic unified layout.
- Introduce a darker layered material system with controlled glow, translucent surfaces, restrained highlights, and clearer hierarchy so non-home screens no longer read as a flat black slab.
- Rework the active workout screen into a focused single-exercise control console inspired by the provided reference, emphasizing rep logging speed, large central interaction targets, and set progression visibility.
- Restage analytics and profile/settings into calmer premium sections that preserve bilingual support while feeling closer to a designed product than a utility dashboard.
- Update existing design-system and zero-typing specs so this stronger art direction becomes the new contract for these screens.

## Capabilities

### New Capabilities
- `premium-minimal-frontend-redesign`: defines the premium minimal visual language, the focused workout console layout, and the higher-end presentation rules for non-home primary screens.

### Modified Capabilities
- `minimalist-layout-system`: upgrade layout rules from generic whitespace consistency to intentional luxury spacing, layered framing, and stronger focal hierarchy.
- `premium-micro-animations`: extend motion rules to cover glow, soft press states, selected control transitions, and premium console feedback.
- `zero-typing-ui`: preserve rapid workout logging while changing the active session structure to a more concentrated single-exercise control surface.
- `progress-analytics`: update analytics presentation requirements so the third navigation page adopts the new premium minimal language instead of dashboard-lite cards.
- `app-language-settings`: ensure the redesigned profile/settings surface preserves bilingual clarity inside the denser premium treatment.

## Impact

- Affected code: active workout screen, progress analytics screen, profile/settings screen, shared presentation widgets, app shell styling, and related widget tests.
- Affected UX: visual hierarchy, material treatment, dark-theme layering, action emphasis, and workout logging presentation.
- Affected specs: design-system-related main specs and one new premium redesign capability spec.

## Overview

This change keeps the PR Dashboard as a premium analytics destination, but it shifts the experience from a visually merged overview into a more legible per-lift workflow. The screen should answer three questions quickly:

1. What is my latest benchmark for squat, bench, and deadlift?
2. How is one selected lift trending over time?
3. What recent milestones matter, and how can I inspect the full milestone history?

## Key Decisions

### 1. Use a single metric mode toggle for the top summary

The top cards should not each own their own metric switch. A shared compact segmented control keeps the row visually clean and guarantees that the three cards remain directly comparable. The control switches all three cards together between:

- estimated 1RM
- actual PR

When a lift has no previous comparable record, the card still keeps the same height and width. The delta slot should remain reserved so the grid does not collapse or misalign.

### 2. Show one lift at a time in the main chart

The current combined chart trades clarity for compactness. The redesign should focus the main chart on one selected lift at a time, with a small lift switcher above or inside the chart header. This makes it possible to add:

- a meaningful y-axis with weight labels
- a meaningful x-axis with date labels
- richer context for the selected lift without color overload

The chart should also respect the same metric mode concept where appropriate, but the primary redesign requirement is that the user can clearly switch which lift is being visualized.

### 3. Split milestone preview from milestone history

The dashboard should stay skimmable, so the main page only shows the two newest milestone entries. A dedicated milestone history screen handles depth and filtering. This keeps the landing page lightweight while still supporting exploration.

Recommended filters for the milestone history screen:

- lift or exercise
- time range
- PR type: actual PR vs estimated 1RM

### 4. Fold localization into the redesign instead of treating it as follow-up

The PR Dashboard currently contains hard-coded English strings, so the redesign should move all user-facing copy into the existing localization layer during the same change. That includes:

- header text
- metric mode labels
- chart labels and axis descriptors
- milestone labels, filter labels, and empty states

## Resulting UX Contract

- Three top cards always share a consistent size and layout.
- One shared toggle controls whether the cards show estimated 1RM or actual PR.
- The chart shows one selected lift at a time and includes readable axes.
- The dashboard shows only the two newest milestones.
- Users can navigate to a dedicated milestone history page and filter results.
- The full experience respects the selected app language.

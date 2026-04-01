## Context

The current workout logger is compact and fast, but it assumes kilogram-only display, tap-only weight adjustments, non-interactive set progress, and no RPE capture in plans or logs. The plan model already contains unit and load metadata on exercises, while active session and workout-log models still flatten everything into simple reps/weight fields.

This change crosses domain models, persistence, seeded plan metadata, the active-session UI, the settings area, and workout-log editing. The implementation needs to remain backward compatible with existing saved instances and browser-persisted drafts.
It also needs to connect workout completion to the existing sync controller so signed-in users get an immediate post-save cloud sync attempt without introducing a second sync pathway.

## Goals / Non-Goals

**Goals:**
- Add a reusable kg/lb conversion and plate-calculator tool that works from settings and the workout logger.
- Support per-exercise display units in the active logger while preserving canonical stored weights in kg.
- Support optional target and recorded RPE in plans, active sessions, and workout logs.
- Let users jump between sets from the set-progress strip and get clear feedback when they complete a set.
- Keep the current fast-start plan activation flow while providing a path to fix missing accessory starting loads later.
- Automatically start a recovery-safe sync after workout conclusion for signed-in users.

**Non-Goals:**
- Do not redesign analytics to natively chart lb values; analytics remain kg-backed.
- Do not require full per-exercise 1RM entry before a user can start a plan.
- Do not add a custom plate inventory system or custom per-gym plate catalog in v1.
- Do not block workout completion on cloud reachability or successful sync acknowledgment.

## Decisions

### Canonical weight storage stays in kg
All persisted weights remain kg-based in plan execution, drafts, and logs. The logger converts to lb only for display and user input, then converts back to kg on save. This avoids reworking engine calculations and analytics.

### Session unit choice is per exercise, not global
Each `ExerciseSessionState` stores its current display unit so users can log one movement in kg and another in lb in the same session. That state is persisted in drafts and carried into workout logs.

### RPE is explicit typed data
Target and actual RPE are added as optional numeric fields on set definitions, session sets, and workout-log sets. This keeps prescribed RPE and recorded RPE testable and editable instead of hiding them in generic metadata maps.

### Plate guidance is barbell-only and preference-backed
Exercises gain explicit equipment metadata. Plate breakdown only appears for barbell exercises using kg or lb units. The breakdown uses user-configurable default bar weights from settings and fixed plate denominations for kg/lb.

### Quick start remains the default activation path
The existing canonical training-max setup remains required only for templates that already declare required lift keys. Exercises without a usable resolved starting load can still be started, but the plan editor must expose enough metadata to fix those exercises later.

### Direct weight entry augments, not replaces, fast controls
The logger keeps the visible +/- weight buttons. Long-pressing the central weight display opens direct numeric entry via keyboard so users can jump to exact weights without losing the current compact workflow.

### Post-workout sync reuses the existing sync controller
The workout completion flow should call the existing `SyncController.synchronizeWithRecovery()` after the workout log and updated instance are persisted locally. This keeps sync policy in one place, preserves retry handling, and avoids throwing away a successfully saved workout just because the network or Supabase is unavailable.

## Risks / Trade-offs

- [More model fields increase migration surface] → Add backward-compatible optional fields and preserve defaults when decoding older drafts/logs.
- [Per-exercise unit display can confuse users if not obvious] → Keep the unit toggle directly adjacent to the current-set controls and show the active unit in weight and plate UI.
- [Plate math can feel wrong if bar weight assumptions are hidden] → Surface default bar weights in settings and show the chosen bar weight in the calculator sheet.
- [Quick start may still leave some accessories underspecified] → Make unresolved-load exercises editable later in the plan editor and avoid blocking initial use.
- [Auto sync might make workout completion feel flaky if the network is bad] → Trigger sync only after local save succeeds and use the recovery path so workout completion remains successful even when sync moves the account state to retry-needed.

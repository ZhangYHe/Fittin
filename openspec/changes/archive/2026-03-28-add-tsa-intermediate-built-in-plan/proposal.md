## Why

The app's built-in plan catalog currently documents GZCLP and Jacked & Tan, but the newly added TSA Intermediate Approach 2.0 seed was implemented directly in code without a matching OpenSpec change. That leaves the built-in-plan contract incomplete: the repository now ships a third TM-driven built-in plan, yet the specification layer does not explain what gets seeded, how it appears in the plan library, or what portions of the workbook were normalized into the app's runtime model.

## What Changes

- Add an OpenSpec change that records TSA Intermediate Approach 2.0 as a first-class built-in program derived from the checked-in LiftVault workbook.
- Specify the normalized scope of the built-in TSA seed, including its 4-day structure, 8-week main block, and training-max-driven main lift prescriptions.
- Clarify that the plan library and built-in seeding flow now expose TSA Intermediate alongside the existing built-in templates.
- Document the intentional normalization choice to stop at the main 8-week block instead of encoding the workbook's separate test/meet week into the current fixed-workout template model.

## Capabilities

### New Capabilities
- `tsa-intermediate-program-template`: seed and expose a normalized TSA Intermediate Approach 2.0 built-in template.

### Modified Capabilities
- `plan-library-switching`: surface the TSA built-in template in the plan library alongside the other built-in plans.

## Impact

- Affected assets include the new built-in JSON seed, seed registration, and plan-library-visible built-in template count.
- The spec layer will once again match the implementation already present in the app.
- Future edits to the TSA built-in plan will have a clear spec anchor instead of living only in code and workbook-derived JSON.

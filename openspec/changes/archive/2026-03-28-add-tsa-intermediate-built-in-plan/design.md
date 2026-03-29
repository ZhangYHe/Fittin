## Overview

This change is a spec backfill for code that is already implemented. The implementation adds a new built-in plan asset, `tsa_intermediate_approach_2_0.json`, and registers it through the same seed path used by GZCLP and Jacked & Tan. The spec should therefore describe the normalized product contract rather than propose a different architecture.

## Key Decisions

### 1. Treat TSA Intermediate as a dedicated built-in capability

The app now has enough built-in program-specific behavior that TSA Intermediate should be documented as its own capability instead of being folded into generic plan-library language. This mirrors the existing structure for GZCLP and Jacked & Tan and makes workbook fidelity decisions auditable.

### 2. Normalize the workbook into the current periodized template model

The workbook contains nine visible weekly columns, but the ninth week behaves like a testing or meet block with a materially different structure from the earlier weeks. The current app template model expects each workout slot to preserve a stable exercise lineup across stages. To keep the seed compatible with the existing periodized engine and plan library preview behavior, the implementation keeps the main 8-week block and omits the separate test week from the built-in asset.

### 3. Reuse existing TM-driven infrastructure

No new engine family or storage model is needed. The TSA template rides on the existing `periodized_tm` path, uses the existing training-max setup flow, and requires only the three lift keys that appear in the workbook-derived main prescriptions: squat, bench, and deadlift.

## Resulting Contract

- The app seeds TSA Intermediate Approach 2.0 as a built-in template on bootstrap.
- The plan is shown in the plan library together with the other built-in templates.
- The template exposes a 4-day weekly structure and an 8-week main block.
- Main barbell prescriptions are derived from training max values at runtime.
- Accessory rows preserve the normalized workbook exercise lineup used in the shipped JSON asset.

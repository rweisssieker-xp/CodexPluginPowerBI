# Power BI Refactoring Plan

Schema: `codex.powerbi.refactorPlan.v1`
Root: `D:\temp\CodexPluginPowerBI\powerbi-live-instance-test\live-auto-review`
Risk: **Low** (3)

## Stabilize

### [High] No text-based model artifacts

- Category: Inspectability
- Source: `.`
- Effort: Large
- Action: Create a text-based project export before requesting semantic refactors.
- Acceptance criteria:
  - Change is traceable to a finding or business requirement.
  - Report opens successfully in Power BI Desktop.
  - Affected measures or queries have been reviewed against expected results.
  - Rollback path is documented before publishing.

## Govern

No items in this phase.

## Polish

No items in this phase.



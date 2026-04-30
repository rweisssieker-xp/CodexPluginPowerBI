# Power BI Refactoring Plan

Schema: `codex.powerbi.refactorPlan.v1`
Root: `D:\temp\CodexPluginPowerBI\plugins\powerbi-desktop\examples\sample-model`
Risk: **Medium** (8)

## Stabilize

### [High] FILTER over ALL pattern

- Category: DAX Performance
- Source: `Risky.Measures.dax`
- Effort: Medium
- Action: Review the measure filter shape, benchmark alternatives, and prefer narrower filter expressions where business logic allows.
- Acceptance criteria:
  - Change is traceable to a finding or business requirement.
  - Report opens successfully in Power BI Desktop.
  - Affected measures or queries have been reviewed against expected results.
  - Rollback path is documented before publishing.

## Govern

### [Medium] Volatile date/time function

- Category: Refresh Determinism
- Source: `Risky.Measures.dax`
- Effort: Small
- Action: Replace volatile date logic with a governed date table, parameter, or documented refresh-date measure.
- Acceptance criteria:
  - Change is traceable to a finding or business requirement.
  - Report opens successfully in Power BI Desktop.
  - Affected measures or queries have been reviewed against expected results.
  - Rollback path is documented before publishing.

### [Medium] Local file dependency

- Category: Data Source Governance
- Source: `SalesQuery.pq`
- Effort: Medium
- Action: Move the source to governed storage or parameterize the path for gateway-compatible refresh.
- Acceptance criteria:
  - Change is traceable to a finding or business requirement.
  - Report opens successfully in Power BI Desktop.
  - Affected measures or queries have been reviewed against expected results.
  - Rollback path is documented before publishing.

## Polish

### [Low] Text artifacts without PBIP file

- Category: Project Format
- Source: `.`
- Effort: Small
- Action: Add or regenerate the PBIP entry point for round-tripping in Power BI Desktop.
- Acceptance criteria:
  - Change is traceable to a finding or business requirement.
  - Report opens successfully in Power BI Desktop.
  - Affected measures or queries have been reviewed against expected results.
  - Rollback path is documented before publishing.



# Power BI Report Blueprint

Schema: `codex.powerbi.reportBlueprint.v1`
Root: `D:\temp\CodexPluginPowerBI\powerbi-live-instance-test\live-auto-review`
Metrics considered: 0

## Design Principles

- Use dense, scannable executive pages with clear metric ownership.
- Keep diagnostic and governance content separate from business-consumption pages.
- Surface unresolved metric risks visibly until owners sign off.
- Avoid ambiguous KPI titles; use business definitions from the metric catalog.

## Pages

### Executive Overview

- Purpose: Give leadership a fast read on the most important governed metrics.
- Visuals:
  - KPI row for primary finance metrics
  - Trend line for time-intelligence metrics
  - Variance callout for metrics tagged as ratio or YoY
  - Risk banner if review metrics remain unresolved
  - Date slicer with explicit latest refresh date label
- Measures: derived from scan and governance outputs

### Metric Diagnostics

- Purpose: Expose measure definitions, owners, and validation state for analysts.
- Visuals:
  - Metric catalog table with owner, business definition, and risk level
  - DAX review queue filtered to riskLevel = review
  - Validation checklist slicer by source file
- Measures: derived from scan and governance outputs

### Model Governance

- Purpose: Track project readiness, source-control posture, and refresh dependencies.
- Visuals:
  - Finding count by severity
  - Power Query dependency list
  - PBIP/TMDL readiness status
  - Next-action backlog
- Measures: derived from scan and governance outputs



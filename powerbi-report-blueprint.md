# Power BI Report Blueprint

Schema: `codex.powerbi.reportBlueprint.v1`
Root: `D:\temp\CodexPluginPowerBI\plugins\powerbi-desktop\examples\sample-model`
Metrics considered: 5

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
- Measures: All Customer Sales, Refresh Sensitive Sales, Total Sales, Sales YoY %, Total Sales Prior Year

### Metric Diagnostics

- Purpose: Expose measure definitions, owners, and validation state for analysts.
- Visuals:
  - Metric catalog table with owner, business definition, and risk level
  - DAX review queue filtered to riskLevel = review
  - Validation checklist slicer by source file
- Measures: All Customer Sales, Refresh Sensitive Sales

### Model Governance

- Purpose: Track project readiness, source-control posture, and refresh dependencies.
- Visuals:
  - Finding count by severity
  - Power Query dependency list
  - PBIP/TMDL readiness status
  - Next-action backlog
- Measures: derived from scan and governance outputs



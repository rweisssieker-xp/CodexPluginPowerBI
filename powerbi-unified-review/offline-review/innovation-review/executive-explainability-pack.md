# Power BI Executive Explainability Pack

The model exposes 5 metrics; 2 have review findings.

## Trustworthy Metrics
- `Total Sales`: Does `Total Sales` reconcile to the accepted business source for the selected filter context?
- `Sales YoY %`: Does `Sales YoY %` reconcile to the accepted business source for the selected filter context?
- `Total Sales Prior Year`: Does `Total Sales Prior Year` reconcile to the accepted business source for the selected filter context?

## Risky Metrics
- `All Customer Sales`: performance: FILTER over ALL
- `Refresh Sensitive Sales`: determinism: volatile date/time

## Decision Guidance
- Use trusted metrics for routine reporting after owner sign-off.
- Treat risky or high-impact metrics as provisional until validated.
- Do not publish refactored measures without before/after comparison.


# Power BI DAX Fix Simulation

## All Customer Sales
- Risk: performance: FILTER over ALL
- Expected effect: Narrower filter clearing or deterministic behavior, subject to business validation.
- Rollback: Restore original DAX expression if before/after validation exceeds tolerance.

## Refresh Sensitive Sales
- Risk: determinism: volatile date/time
- Expected effect: Narrower filter clearing or deterministic behavior, subject to business validation.
- Rollback: Restore original DAX expression if before/after validation exceeds tolerance.



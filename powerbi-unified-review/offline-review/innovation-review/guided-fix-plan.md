# Power BI Guided Fix Plan

Fixes: 6

## [P0] Risky.Measures.dax
- Theme: DAX Performance
- Problem: 
- Guided step: Inspect the cited file or measure, apply the suggested rewrite, then rerun scan and measure tests.
- Validation: Run Invoke-PowerBIInsightScan.ps1 and New-PowerBIMeasureTestPlan.ps1 for the affected model.
- Status: Open

## [P1] All Customer Sales
- Theme: DAX Refactoring
- Problem: performance: FILTER over ALL
- Guided step: Rewrite the measure with narrower filters or deterministic logic, preserving accepted business totals.
- Validation: Run generated tests for `All Customer Sales` and validate downstream count 0.
- Status: Open

## [P1] Refresh Sensitive Sales
- Theme: DAX Refactoring
- Problem: determinism: volatile date/time
- Guided step: Rewrite the measure with narrower filters or deterministic logic, preserving accepted business totals.
- Validation: Run generated tests for `Refresh Sensitive Sales` and validate downstream count 0.
- Status: Open

## [P1] Risky.Measures.dax
- Theme: Refresh Determinism
- Problem: 
- Guided step: Inspect the cited file or measure, apply the suggested rewrite, then rerun scan and measure tests.
- Validation: Run Invoke-PowerBIInsightScan.ps1 and New-PowerBIMeasureTestPlan.ps1 for the affected model.
- Status: Open

## [P1] SalesQuery.pq
- Theme: Data Source Governance
- Problem: 
- Guided step: Inspect the cited file or measure, apply the suggested rewrite, then rerun scan and measure tests.
- Validation: Run Invoke-PowerBIInsightScan.ps1 and New-PowerBIMeasureTestPlan.ps1 for the affected model.
- Status: Open

## [P2] .
- Theme: Project Format
- Problem: 
- Guided step: Inspect the cited file or measure, apply the suggested rewrite, then rerun scan and measure tests.
- Validation: Run Invoke-PowerBIInsightScan.ps1 and New-PowerBIMeasureTestPlan.ps1 for the affected model.
- Status: Open



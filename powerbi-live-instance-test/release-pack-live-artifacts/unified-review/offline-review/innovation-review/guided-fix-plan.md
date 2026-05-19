# Power BI Guided Fix Plan

Fixes: 1

## [P0] .
- Theme: Inspectability
- Problem: Codex can inventory binary files, but deep semantic review needs PBIP, TMDL, model.bim, DAX, or Power Query exports.
- Guided step: Inspect the cited file or measure, prepare a reviewed change plan, then rerun scan and measure tests.
- Next script: Invoke-PowerBIInsightScan.ps1
- Validation: Run Invoke-PowerBIInsightScan.ps1 and New-PowerBIMeasureTestPlan.ps1 for the affected model.
- Release gate: Blocks release until closed or explicitly waived.
- Status: Open



# Max AI Review

The Max AI review is the complete 12-USP Codex workflow for Power BI Desktop and Fabric engineering.

Run it with:

```powershell
.\plugins\powerbi-desktop\scripts\Invoke-PowerBIMaxAIReview.ps1 -Path .\plugins\powerbi-desktop\examples\sample-model -OutputDirectory .\powerbi-max-ai-review
```

It creates these artifacts:

- `fix-until-green.md`: iterative fix loop status.
- `semantic-copilot-evaluator.md`: local Copilot-style semantic question coverage.
- `data-contract.md`: KPI/data contracts.
- `fabric-deployment-risk.md`: Fabric deployment risk simulation.
- `visual-intent.md`: report/page intent analysis.
- `root-cause-graph.md`: broken/risky measure root cause graph.
- `kpi-trust-twin.json`: KPI trust twin records.
- `review-memory.json`: review memory update result.
- `natural-language-authoring.json`: PBIP authoring draft from business intent.
- `governance-rule-miner.md`: mined governance rule candidates.
- `explainable-dax-refactoring.md`: explainable DAX refactoring notes.
- `report-decision-simulator.md`: decision-readiness scenarios.

The workflow is local-first. It does not sign in to Fabric, publish content, or write directly to binary PBIX files. PBIP/TMDL write actions remain gated through explicit apply scripts.

# Max AI Review

The Max AI review is the complete 29-artifact Codex workflow for Power BI Desktop and Fabric engineering.

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
- `trust-debt-ledger.json`: persistent KPI trust debt with owner/SLA-style remediation signals.
- `kpi-incident-report.json`: KPI incident dossier with evidence timeline, root-cause candidates, rollback guidance, and validation plan.
- `rls-leakage.json`: RLS leakage test drafts for role-based release validation.
- `fabric-capacity-risk.json`: Fabric capacity, refresh, and query-risk forecast from local model/service/performance evidence.
- `metric-duplicates.json`: cross-model semantic duplicate candidates and canonical KPI recommendations.
- `forecast-exception-board.json`: forecast exceptions with owner hints, due windows, actions, and closure evidence.
- `usage-signals.json`: imported usage/activity export signals or an explicit empty-import contract.
- `usage-trust-matrix.json`: high-usage/low-trust KPI prioritization for governance teams.
- `pbip-rollback-readiness.json`: non-destructive rollback rehearsal checks for PBIP apply workflows.
- `agentic-remediation-plan.json`: ranked remediation backlog that combines release gates, guided fixes, DAX simulations, lineage impact, usage trust, and service findings.
- `business-outcome-simulation.json`: decision-risk scenarios that translate KPI trust and report intent into possible business outcome risk.
- `semantic-layer-autopilot.json`: semantic improvement plan for display names, descriptions, synonyms, owner gaps, KPI contracts, and Copilot readiness.
- `ai-governance-evidence-pack/summary.json`: audit-style evidence package with AI suggestions, sign-off gaps, residual risks, and release evidence.
- `human-override-learning.json`: override-learning status, capture template, learning signals, and bias findings from human overrides.
- `cross-report-kpi-conflicts.json`: cross-report KPI definition conflicts and canonical metric recommendations.
- `executive-narrative-quality.json`: executive story quality checks across narrative, visual intent, KPI trust, and release gates.
- `autonomous-qa-lab/summary.json`: QA lab summary with generated questions, semantic expectations, visual readiness, and regression risk.

The workflow is local-first. It does not sign in to Fabric, publish content, or write directly to binary PBIX files. PBIP/TMDL write actions remain gated through explicit apply scripts.

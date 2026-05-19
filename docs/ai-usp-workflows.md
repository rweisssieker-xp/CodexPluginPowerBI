# AI USP Workflows

The Max AI/KI layer is designed to make Codex useful beyond static linting. It turns model signals into fix loops, contracts, simulations, and explainable change plans.

## Run The Full Package

```powershell
.\plugins\powerbi-desktop\scripts\Invoke-PowerBIMaxAIReview.ps1 `
  -Path .\plugins\powerbi-desktop\examples\sample-model `
  -OutputDirectory .\powerbi-max-ai-review
```

## The 28 USP Workflows

1. Fix-until-green loop

   `Invoke-PowerBIFixUntilGreenLoop.ps1` creates a structured loop from failing checks to proposed fixes and next validation steps.

2. Semantic model Copilot evaluator

   `Test-PowerBISemanticModelCopilotEvaluator.ps1` checks whether model names, descriptions, relationships, and metrics are friendly for Copilot-like use.

3. Data contract generator

   `New-PowerBIDataContract.ps1` creates a contract for measures, assumptions, owners, and operational expectations.

4. Fabric deployment risk simulator

   `New-PowerBIFabricDeploymentRiskSimulator.ps1` estimates deployment risk before tenant-side work.

5. Visual intent analyzer

   `New-PowerBIVisualIntentAnalyzer.ps1` checks whether report visuals match metric intent and decision needs.

6. Broken measure root-cause graph

   `New-PowerBIBrokenMeasureRootCauseGraph.ps1` maps likely root causes for broken or suspicious measures.

7. KPI trust twin

   `New-PowerBIKpiTrustTwin.ps1` creates a trust representation for KPI reliability and governance review.

8. Review memory

   `Update-PowerBIReviewMemory.ps1` stores local review context and repeated findings.

9. Natural-language PBIP authoring

   `New-PowerBINaturalLanguagePBIPAuthoring.ps1` turns a human intent into structured PBIP change drafts.

10. Governance rule miner

   `New-PowerBIGovernanceRuleMiner.ps1` proposes rules from observed findings.

11. Explainable DAX refactoring

   `New-PowerBIExplainableDaxRefactoring.ps1` proposes refactors with rationale, risk, and validation notes.

12. Report decision simulator

   `New-PowerBIReportDecisionSimulator.ps1` simulates how report issues can affect business decisions.

13. KPI trust debt ledger

   `New-PowerBITrustDebtLedger.ps1` turns low-trust KPIs, release blockers, and guided fixes into owner/SLA-style trust debt.

14. KPI incident recorder

   `New-PowerBIKpiIncidentReport.ps1` creates an incident dossier with evidence timeline, probable root causes, rollback guidance, and validation steps.

15. RLS leakage simulator

   `Test-PowerBIRlsLeakage.ps1` drafts role-level DAX validation queries and release-gate impact for row-level-security leakage checks.

16. Fabric capacity risk forecaster

   `New-PowerBIFabricCapacityRiskForecast.ps1` combines model, service, storage, and trace signals into capacity, refresh, and query-risk forecasts.

17. Semantic duplicate merger

   `Find-PowerBIMetricDuplicates.ps1` finds semantically similar measures across local models and recommends a canonical KPI candidate for review.

18. Forecast exception board

   `New-PowerBIForecastExceptionBoard.ps1` turns AI forecast deltas and quality findings into owner-linked exception cases with closure evidence.

19. Usage-vs-trust scanner

   `Import-PowerBIUsageSignals.ps1` and `New-PowerBIUsageTrustMatrix.ps1` prioritize governance work by combining usage/activity exports with KPI trust.

20. PBIP rollback rehearsal gate

   `Test-PowerBIPBIPRollbackReadiness.ps1` checks whether PBIP apply workflows have enough structure, manifests, and backup hints for a reproducible rollback.

21. Agentic remediation prioritization

   `New-PowerBIAgenticRemediationPlan.ps1` ranks release blockers, guided fixes, DAX simulations, lineage impact, usage trust, and service findings into a remediation backlog.

22. Business outcome simulation

   `New-PowerBIBusinessOutcomeSimulator.ps1` maps KPI trust and report intent to likely business decision risk, affected audiences, confidence bands, and required evidence.

23. Semantic layer autopilot

   `New-PowerBISemanticLayerAutopilot.ps1` combines metric catalog, Copilot optimization, KPI trust contracts, semantic layer evidence, and readiness checks into one improvement plan.

24. AI governance evidence pack

   `New-PowerBIAIGovernanceEvidencePack.ps1` creates audit-style local evidence with AI suggestions, sign-off gaps, residual risks, and release evidence.

25. Human override learning

   `New-PowerBIHumanOverrideLearning.ps1` reads human override evidence or emits a capture template so teams can learn from accepted and rejected AI recommendations.

26. Cross-report KPI conflict detection

   `New-PowerBICrossReportKpiConflictDetector.ps1` detects conflicting KPI definitions across report roots and proposes canonical KPI decisions.

27. Executive narrative quality agent

   `New-PowerBIExecutiveNarrativeQualityAgent.ps1` checks whether executive narratives are supported by visual intent, KPI trust, and release evidence.

28. Autonomous Power BI QA Lab

   `New-PowerBIAutonomousQALab.ps1` packages generated QA questions, semantic expectations, visual readiness, and regression-risk evidence.

## How To Use The Outputs

- Attach summaries to PRs with `New-PowerBIPRReleaseComment.ps1`.
- Convert repeated findings into rule JSON after review.
- Use PBIP draft/apply scripts for approved model changes.
- Validate live measures in Desktop before release.
- Use trust gates to make Go/Warn/No-Go decisions explicit.

## Boundary

These workflows generate local artifacts and recommendations. They do not replace domain-owner review, data-owner signoff, or tenant deployment controls.

# Next-Generation Power BI And Fabric USPs

Run the complete local pack:

```powershell
.\plugins\powerbi-desktop\scripts\Invoke-PowerBINextGenUspPack.ps1 -Path .\your-model -OutputDirectory .\powerbi-nextgen-usp-pack
```

The pack creates six JSON artifacts. It reads local model files and existing local evidence; it does not sign in, publish, refresh, or change Fabric.

For a release package, add `-IncludeNextGenUspQa` to `New-PowerBIReleaseCandidatePack.ps1`. The generated six-artifact summary is then included under `nextgen-usps/summary.json`.

## Capacity evidence import

Export Capacity Metrics data as JSON (`value` or `rows`) or CSV, then create a versioned local snapshot:

```powershell
.\plugins\powerbi-desktop\scripts\Import-PowerBIFabricCapacityMetricsSnapshot.ps1 -InputPath .\capacity-export.csv -Label before-change
```

The normalized snapshot records capacity, workspace, item, operation, CU, utilization, and throttling. It is the evidence input for future cost attribution and before/after verification; importing it never calls Fabric.

## KPI SLO actions

`rules/powerbi-kpi-slos.json` assigns owners and SLO targets per KPI. Run `New-PowerBIKpiSloActionList.ps1 -Path .\your-model -Json` to create a local, advisory action list. Add `-IncludeKpiSloActions` to the release candidate pack to include it without changing the release decision.

| Artifact | Purpose | Evidence needed for a final decision |
| --- | --- | --- |
| Fabric FinOps Copilot | Links KPI trust, capacity risk, ownership, and optimization actions. | Capacity/CU and cost snapshots, plus owner confirmation. |
| Copilot Answer Regression Lab | Creates priority business questions and expected evidence for answer testing. | Captured, approved answers from Copilot or live-model validation. |
| Direct Lake/OneLake Readiness | Detects local architecture signals and lists Direct Lake review checks. | Workspace metadata, OneLake shortcut and Delta/schema evidence. |
| Data Product SLO Manager | Turns freshness, ownership, and SLA evidence into a release policy. | Agreed KPI SLOs and monitored breach evidence. |
| Capacity Change Verifier | Defines a before/after CU, throttling, latency, and cost verification. | Comparable Capacity Metrics snapshots. |
| Executive Decision Trace | Maps lower-trust KPIs to decision caveats and owner review. | Business-owner sign-off and validated KPI evidence. |

Use the output as decision support. Local and heuristic signals are labelled in each artifact and must not be represented as Fabric live validation.

## Enterprise operations pack: eight production gaps

Run the eight integrated operating features locally:

```powershell
.\plugins\powerbi-desktop\scripts\Invoke-PowerBIEnterpriseOperationsPack.ps1 -Path .\your-model -OutputDirectory .\powerbi-enterprise-operations-pack
```

It creates eight separately labelled evidence artifacts: Copilot answer quality monitoring, Capacity FinOps comparison, Direct Lake/OneLake evidence, KPI SLO history and escalation, governance-drift checks, a hash-based release evidence bundle, role-based onboarding status, and a transparent plugin quality gate. It does not sign in, call Fabric, publish content, or modify a model.

For release evidence, add `-IncludeEnterpriseOperationsQa` to `New-PowerBIReleaseCandidatePack.ps1`. Add `-CapacityBeforePath`, `-CapacityAfterPath`, `-GovernanceBaselinePath`, `-CopilotAnswersPath`, or `-SloHistoryPath` when invoking the operations pack directly to strengthen its local evidence.

## Decision intelligence: eight differentiation USPs

```powershell
.\plugins\powerbi-desktop\scripts\Invoke-PowerBIDecisionIntelligencePack.ps1 -Path .\your-model
```

This local-only pack creates eight decision artifacts: Copilot Reliability Score, KPI change explanation, business-impact scenario, semantic-model team contract, decision memory, owner-approved exception workflow, multi-workspace benchmark, and screenshot regression evidence. Optional JSON inputs provide approved answer captures, KPI baselines, scenarios, decisions, and portfolio exports. Screenshot comparison uses supplied local files only.

Add `-IncludeDecisionIntelligenceQa` to `New-PowerBIReleaseCandidatePack.ps1` to attach the eight artifacts to a release candidate. The workflow neither publishes changes nor signs in to Fabric.

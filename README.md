# Power BI Desktop Codex Plugin

This workspace contains a Codex plugin for Microsoft Power BI Desktop workflows.

## Install

Use the plugin from this repository by pointing Codex at `plugins/powerbi-desktop`.
Generated review outputs are intentionally ignored by Git; rerun the scripts below to recreate them locally.

Start with the full [documentation index](docs/index.md). Key guides: [getting started](docs/getting-started.md), [workflows](docs/workflows.md), [script catalog](docs/script-catalog.md), [architecture](docs/architecture.md), [unified review](docs/unified-review.md), [Max AI review](docs/max-ai-review.md), [AI USP workflows](docs/ai-usp-workflows.md), [live Desktop](docs/live-desktop.md), [PBIP Apply Engine](docs/pbip-apply-engine.md), [Fabric planning](docs/fabric.md), [governance](docs/governance.md), [External Tool installation](docs/external-tool-installation.md), [golden baselines](docs/golden-baselines.md), [testing](docs/testing.md), [privacy](docs/privacy.md), and [troubleshooting](docs/troubleshooting.md).

## What It Adds

- A `powerbi-desktop` skill for PBIX/PBIT/PBIP, DAX, Power Query, and semantic model work.
- A local inventory script for Power BI file discovery.
- A local environment check script for Power BI Desktop, Tabular Editor, DAX Studio, pbi-tools, and .NET.
- A model summary script for text-based Power BI assets such as TMDL, DAX, Power Query, and `model.bim`.
- An insight scan that scores report inspectability, source-control readiness, DAX risk patterns, and Power Query dependencies.
- A metric catalog generator that turns measures into a semantic contract starter.
- A refactoring plan generator that turns scan findings into phased work.
- A report blueprint generator that turns metrics into a page-level UX plan.
- A DAX dependency graph generator for impact analysis.
- An AI prompt pack generator with `context-pack.json` and focused review/refactor/narrative prompts.
- A deterministic executive narrative generator for report-owner communication.
- Configurable DAX and Power Query governance rules.
- PBIP/TMDL/report metadata readiness scoring.
- A one-command auto-review orchestrator.
- Live read-only access helpers for the currently open Power BI Desktop model via the local XMLA/ADOMD endpoint.
- Live DAX query validation, metadata governance checks, fix backlogs, DAX fix drafts, and refactor suggestions.
- Innovation review package with guided fixes, semantic diff support, measure lineage impact, generated DAX test plans, performance advice, report UX critique, executive explainability, governance scorecards, Copilot readiness, and release checklists.
- Trust and release assistant with business semantic layers, KPI trust scores, decision-risk analysis, flight-recorder history, before/after behavior comparison, narrative critique, Copilot optimization, DAX fix simulation, visual-to-measure impact mapping, and Go/Warn/No-Go release gates.
- Safe PBIP/TMDL authoring drafts for new measures and calculated columns.
- Safe PBIP report page and visual drafts, with optional PBIP report-page file generation and PBIP-to-PBIX compile workflow guidance.
- Model best-practice checks driven by configurable trust rules.
- Native tool-parity layer for BPA rules, model compare, model documentation, DAX performance heuristics, report layout checks, theme audit, and PBIP source-control planning.
- Real-feature layer for visual schema checks, render-readiness, live DAX benchmarks, live DMV/VertiPaq-style analysis, calculation groups, relationships, RLS roles, Power Query drafts, service planning, incremental refresh, aggregations, and schema-aware visual planning.
- PBIP Apply Engine for measure, calculated column, Power Query, generic TMDL, and report-page drafts with manifests and rollback guidance.
- Unified review runner that combines offline project review, live Desktop review when available, and External Tools registration in one index.
- Power BI External Tools registration generator for a `Codex Power BI Workbench` `.pbitool.json`.
- Golden baseline tests for sample-model semantic regression checks.
- AI/KI engineering workflows for autonomous PBIP fix plans, live-vs-repo reconciliation, measure expectations, PR release comments, KPI trust contracts, local model Q&A, and Fabric readiness.
- Max AI review with 12 USP workflows: fix-until-green, Copilot evaluator, data contracts, Fabric deployment risk, visual intent, root-cause graph, KPI trust twin, review memory, natural-language PBIP authoring, governance rule mining, explainable DAX refactoring, and report decision simulation.
- Optional external-tool awareness for Tabular Editor, DAX Studio, ALM Toolkit, Power BI Helper, Model Documenter, PBI.tips tools, and pbi-tools validation workflows.
- A theme generator for governed report styling.
- A review prompt template for high-signal Codex report reviews.
- Marketplace metadata for installing the plugin from this repo.

## Quick Checks

```powershell
.\plugins\powerbi-desktop\scripts\Test-PowerBIEnvironment.ps1
.\plugins\powerbi-desktop\scripts\Invoke-PowerBIUnifiedReview.ps1 -Path .\plugins\powerbi-desktop\examples\sample-model -OutputDirectory .\powerbi-unified-review
.\plugins\powerbi-desktop\scripts\New-PowerBIExternalToolRegistration.ps1 -OutputPath .\powerbi-external-tool\CodexPowerBIWorkbench.pbitool.json
.\plugins\powerbi-desktop\scripts\Install-PowerBIExternalTool.ps1
.\plugins\powerbi-desktop\scripts\Uninstall-PowerBIExternalTool.ps1
.\plugins\powerbi-desktop\scripts\Test-PowerBIGoldenBaselines.ps1
.\plugins\powerbi-desktop\scripts\Invoke-PowerBIAutonomousFixAgent.ps1 -Path .\plugins\powerbi-desktop\examples\sample-model -OutputPath .\powerbi-autonomous-fix-agent.md
.\plugins\powerbi-desktop\scripts\Compare-PowerBILiveRepoModel.ps1 -Path .\plugins\powerbi-desktop\examples\sample-model -OutputPath .\powerbi-live-repo-reconciliation.md
.\plugins\powerbi-desktop\scripts\Test-PowerBIMeasureExpectations.ps1 -Path .\plugins\powerbi-desktop\examples\sample-model
.\plugins\powerbi-desktop\scripts\New-PowerBIPRReleaseComment.ps1 -Path .\plugins\powerbi-desktop\examples\sample-model -OutputPath .\powerbi-pr-comment.md
.\plugins\powerbi-desktop\scripts\New-PowerBIKpiTrustContract.ps1 -Path .\plugins\powerbi-desktop\examples\sample-model -OutputPath .\powerbi-kpi-trust-contract.md
.\plugins\powerbi-desktop\scripts\Invoke-PowerBIAskModel.ps1 -Path .\plugins\powerbi-desktop\examples\sample-model -Question "Which sales measures drive release risk?"
.\plugins\powerbi-desktop\scripts\New-PowerBIFabricReadinessPlan.ps1 -Path .\plugins\powerbi-desktop\examples\sample-model -OutputPath .\powerbi-fabric-readiness.md
.\plugins\powerbi-desktop\scripts\Invoke-PowerBIMaxAIReview.ps1 -Path .\plugins\powerbi-desktop\examples\sample-model -OutputDirectory .\powerbi-max-ai-review
.\plugins\powerbi-desktop\scripts\Get-PowerBIExternalToolInventory.ps1
.\plugins\powerbi-desktop\scripts\Invoke-PowerBINativeToolParityReview.ps1 -Path .\plugins\powerbi-desktop\examples\sample-model -OutputDirectory .\powerbi-native-tool-parity
.\plugins\powerbi-desktop\scripts\Invoke-PowerBIRealFeatureReview.ps1 -Path .\plugins\powerbi-desktop\examples\sample-model -OutputDirectory .\powerbi-real-feature-review
.\plugins\powerbi-desktop\scripts\Invoke-PowerBIExternalToolsReview.ps1 -Path .\plugins\powerbi-desktop\examples\sample-model -OutputDirectory .\powerbi-external-tools-review
.\plugins\powerbi-desktop\scripts\Get-PowerBIDesktopLiveConnection.ps1
.\plugins\powerbi-desktop\scripts\Invoke-PowerBILiveAutoReview.ps1 -OutputDirectory .\powerbi-live-auto-review
.\plugins\powerbi-desktop\scripts\Invoke-PowerBIInnovationReview.ps1 -Path .\plugins\powerbi-desktop\examples\sample-model -OutputDirectory .\powerbi-innovation-review
.\plugins\powerbi-desktop\scripts\New-PowerBITrustReleaseGate.ps1 -Path .\plugins\powerbi-desktop\examples\sample-model -OutputPath .\powerbi-trust-release-gate.md
.\plugins\powerbi-desktop\scripts\New-PowerBIMeasureDraft.ps1 -TableName Sales -MeasureName "Average Sales" -Expression "DIVIDE([Total Sales], COUNTROWS('Sales'))"
.\plugins\powerbi-desktop\scripts\Apply-PowerBIPBIPMeasureDraft.ps1 -PbipPath .\MyReport -TableName Sales -MeasureName "Average Sales" -Expression "DIVIDE([Total Sales], COUNTROWS('Sales'))" -Apply
.\plugins\powerbi-desktop\scripts\Invoke-PowerBIPBIPApplyPlan.ps1 -PbipPath .\MyReport -OutputPath .\powerbi-apply-plan\apply-plan.json
.\plugins\powerbi-desktop\scripts\Add-PowerBIPBIPReportPage.ps1 -PbipPath .\MyReport -PageName "Executive Overview" -Measures "Total Sales","Sales YoY %" -Apply
.\plugins\powerbi-desktop\scripts\New-PowerBIPBIXCompileWorkflow.ps1 -PbipPath .\MyReport -OutputPbix .\MyReport.pbix
.\plugins\powerbi-desktop\scripts\Test-PowerBIModelBestPractices.ps1 -Path .\plugins\powerbi-desktop\examples\sample-model -OutputPath .\powerbi-model-best-practices.md
.\plugins\powerbi-desktop\scripts\Get-PowerBIInventory.ps1 -Path .
.\plugins\powerbi-desktop\scripts\Get-PowerBIPBIPStructure.ps1 -Path .\plugins\powerbi-desktop\examples\sample-model -OutputPath .\powerbi-pbip-structure.md
.\plugins\powerbi-desktop\scripts\Invoke-PowerBIAutoReview.ps1 -Path .\plugins\powerbi-desktop\examples\sample-model -OutputDirectory .\powerbi-auto-review
.\plugins\powerbi-desktop\scripts\Invoke-PowerBIInsightScan.ps1 -Path .\plugins\powerbi-desktop\examples\sample-model -OutputPath .\powerbi-insight-scan.md
.\plugins\powerbi-desktop\scripts\New-PowerBIMetricCatalog.ps1 -Path .\plugins\powerbi-desktop\examples\sample-model -OutputPath .\powerbi-metric-catalog.md
.\plugins\powerbi-desktop\scripts\New-PowerBIDependencyGraph.ps1 -Path .\plugins\powerbi-desktop\examples\sample-model -OutputPath .\powerbi-dependency-graph.md
.\plugins\powerbi-desktop\scripts\New-PowerBIDependencyGraph.ps1 -Path .\plugins\powerbi-desktop\examples\sample-model -Mermaid -OutputPath .\powerbi-dependency-graph.mmd
.\plugins\powerbi-desktop\scripts\New-PowerBIAIPromptPack.ps1 -Path .\plugins\powerbi-desktop\examples\sample-model -OutputDirectory .\powerbi-ai-pack
.\plugins\powerbi-desktop\scripts\New-PowerBIExecutiveNarrative.ps1 -Path .\plugins\powerbi-desktop\examples\sample-model -OutputPath .\powerbi-executive-narrative.md
.\plugins\powerbi-desktop\scripts\New-PowerBIRefactorPlan.ps1 -Path .\plugins\powerbi-desktop\examples\sample-model -OutputPath .\powerbi-refactor-plan.md
.\plugins\powerbi-desktop\scripts\New-PowerBIReportBlueprint.ps1 -Path .\plugins\powerbi-desktop\examples\sample-model -OutputPath .\powerbi-report-blueprint.md
.\plugins\powerbi-desktop\scripts\New-PowerBIModelSummary.ps1 -Path .\plugins\powerbi-desktop\examples\sample-model -OutputPath .\sample-model-summary.md
.\plugins\powerbi-desktop\scripts\New-PowerBITheme.ps1 -Name "Executive Analytics" -OutputPath .\executive-theme.json
.\plugins\powerbi-desktop\tests\Run-PowerBITests.ps1
```

The plugin intentionally avoids direct binary PBIX editing. Export to PBIP/TMDL or another text-based format before asking Codex to make model or report changes.

## Development

Run the test suite before publishing changes:

```powershell
.\plugins\powerbi-desktop\tests\Run-PowerBITests.ps1
```

The GitHub Actions workflow runs the same test entrypoint plus Pester tests from `plugins/powerbi-desktop/tests/pester`.

## Privacy

The plugin works against local files and the local Power BI Desktop XMLA/ADOMD endpoint. It does not publish reports, sign in to Power BI Service, refresh credentials, or upload model data by itself.

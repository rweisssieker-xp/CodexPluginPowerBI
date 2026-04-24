# Power BI Desktop Codex Plugin

This workspace contains a Codex plugin for Microsoft Power BI Desktop workflows.

## Install

Use the plugin from this repository by pointing Codex at `plugins/powerbi-desktop`.
Generated review outputs are intentionally ignored by Git; rerun the scripts below to recreate them locally.

Start with [docs/getting-started.md](docs/getting-started.md). Privacy details are in [docs/privacy.md](docs/privacy.md).

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
- External-tools integration layer for Tabular Editor, DAX Studio, ALM Toolkit, Power BI Helper, Model Documenter, PBI.tips tools, and pbi-tools workflows.
- A theme generator for governed report styling.
- A review prompt template for high-signal Codex report reviews.
- Marketplace metadata for installing the plugin from this repo.

## Quick Checks

```powershell
.\plugins\powerbi-desktop\scripts\Test-PowerBIEnvironment.ps1
.\plugins\powerbi-desktop\scripts\Get-PowerBIExternalToolInventory.ps1
.\plugins\powerbi-desktop\scripts\Invoke-PowerBIExternalToolsReview.ps1 -Path .\plugins\powerbi-desktop\examples\sample-model -OutputDirectory .\powerbi-external-tools-review
.\plugins\powerbi-desktop\scripts\Get-PowerBIDesktopLiveConnection.ps1
.\plugins\powerbi-desktop\scripts\Invoke-PowerBILiveAutoReview.ps1 -OutputDirectory .\powerbi-live-auto-review
.\plugins\powerbi-desktop\scripts\Invoke-PowerBIInnovationReview.ps1 -Path .\plugins\powerbi-desktop\examples\sample-model -OutputDirectory .\powerbi-innovation-review
.\plugins\powerbi-desktop\scripts\New-PowerBITrustReleaseGate.ps1 -Path .\plugins\powerbi-desktop\examples\sample-model -OutputPath .\powerbi-trust-release-gate.md
.\plugins\powerbi-desktop\scripts\New-PowerBIMeasureDraft.ps1 -TableName Sales -MeasureName "Average Sales" -Expression "DIVIDE([Total Sales], COUNTROWS('Sales'))"
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
.\plugins\powerbi-desktop\scripts\Test-PowerBIPlugin.ps1
```

The plugin intentionally avoids direct binary PBIX editing. Export to PBIP/TMDL or another text-based format before asking Codex to make model or report changes.

## Development

Run the smoke test before publishing changes:

```powershell
.\plugins\powerbi-desktop\scripts\Test-PowerBIPlugin.ps1
```

The GitHub Actions workflow runs the same smoke test on Windows.

## Privacy

The plugin works against local files and the local Power BI Desktop XMLA/ADOMD endpoint. It does not publish reports, sign in to Power BI Service, refresh credentials, or upload model data by itself.

# Power BI Desktop Codex Plugin

This workspace contains a local Codex plugin for Microsoft Power BI Desktop workflows.

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
- A theme generator for governed report styling.
- A review prompt template for high-signal Codex report reviews.
- Marketplace metadata for installing the plugin from this repo.

## Quick Checks

```powershell
.\plugins\powerbi-desktop\scripts\Test-PowerBIEnvironment.ps1
.\plugins\powerbi-desktop\scripts\Get-PowerBIDesktopLiveConnection.ps1
.\plugins\powerbi-desktop\scripts\Invoke-PowerBILiveAutoReview.ps1 -OutputDirectory .\powerbi-live-auto-review
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

# Enterprise AI Features

These features extend the plugin from local model review into enterprise release engineering. Defaults remain local and safe: tenant calls and model writes are not performed implicitly.

## Release Candidate Pack

```powershell
.\plugins\powerbi-desktop\scripts\New-PowerBIReleaseCandidatePack.ps1 `
  -Path .\plugins\powerbi-desktop\examples\sample-model `
  -OutputDirectory .\powerbi-release-candidate-pack `
  -SkipLive
```

Creates one release index with unified review, Max AI review, service scanner, semantic tests, model risk heatmap, and PR release comment.

## Fabric And Service

```powershell
.\plugins\powerbi-desktop\scripts\Get-PowerBIFabricWorkspaceInventory.ps1 -WorkspaceName "Finance BI" -Json
.\plugins\powerbi-desktop\scripts\New-PowerBIServiceScanner.ps1 -Path .\MyModel -WorkspaceName "Finance BI"
```

`Get-PowerBIFabricWorkspaceInventory.ps1` defaults to `OfflinePlan`. REST mode requires explicit `-UseRest` and a token file path. The scanner creates governance findings for ownership, refresh, sensitivity, endorsement, source control, and trust gate status.

## Safe Write Planning

```powershell
.\plugins\powerbi-desktop\scripts\New-PowerBITomWritePlan.ps1 `
  -Operation AddMeasure `
  -TableName Sales `
  -ObjectName "Average Sales" `
  -Expression "DIVIDE([Total Sales], COUNTROWS('Sales'))"
```

The TOM/TMSL plan is dry-run by default. It documents required gates: explicit endpoint, backup, diff, rollback, and confirmation.

## Layout And UX

```powershell
.\plugins\powerbi-desktop\scripts\Optimize-PowerBIReportLayout.ps1 -PageName "Executive Overview" -VisualCount 5
.\plugins\powerbi-desktop\scripts\New-PowerBIReportScreenshotUXReview.ps1 -ImagePath .\report.png
```

The layout optimizer creates governed placement fixes for PBIP/report JSON workflows. Screenshot review gives structured UX, accessibility, and executive-fit checks.

## Semantic Tests And Performance

```powershell
.\plugins\powerbi-desktop\scripts\Invoke-PowerBISemanticTestRunner.ps1 -Path .\MyModel
.\plugins\powerbi-desktop\scripts\Import-PowerBIPerformanceTrace.ps1 -Path .\MyModel -TracePath .\trace.json
.\plugins\powerbi-desktop\scripts\Import-PowerBIVertiPaqAnalyzer.ps1 -Path .\MyModel -VpaxPath .\model.vpax
```

Semantic tests generate measure-level expectations when no expectation file exists. Performance and VertiPaq importers can consume exported traces, but also provide deterministic fallback guidance when exports are not available.

## Governance And Change Control

```powershell
.\plugins\powerbi-desktop\scripts\New-PowerBIGovernancePolicyPack.ps1 -Profile EnterpriseBI
.\plugins\powerbi-desktop\scripts\Update-PowerBIChangeJournal.ps1 -Title "Refactor Total Sales" -Status proposed
.\plugins\powerbi-desktop\scripts\New-PowerBIModelRiskHeatmap.ps1 -Path .\MyModel
```

Policy packs provide profile-specific rule sets for Enterprise BI, Finance, Healthcare, Executive Reporting, Self-Service BI, and Fabric Premium. The AI change journal records proposed, accepted, rejected, applied, and verified decisions. The model risk heatmap aggregates DAX, inspectability, service, storage, and release-readiness risk.

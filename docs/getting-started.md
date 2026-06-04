# Getting Started

Use [docs/index.md](index.md) as the full documentation map. This page is the shortest path from a fresh checkout to a useful Power BI review.

## Prerequisites

Keep external binaries installed on the workstation, not committed to this repository.

| Level | Tool or provider | Needed for |
| --- | --- | --- |
| Required | PowerShell 5.1+ | Running the plugin scripts. |
| Required for Desktop workflows | Power BI Desktop | Opening PBIX/PBIP files and manual PBIP-to-PBIX validation. |
| Recommended for live checks | ADOMD provider (`Microsoft.AnalysisServices.AdomdClient.dll`) from DAX Studio, SSMS, or ADOMD.NET | Live XMLA/DMV/DAX queries against an open Desktop model. |
| Optional | Tabular Editor 2, DAX Studio, ALM Toolkit, Power BI Helper, Model Documenter, PBI.tips tools | External-tool inventory and workflow guidance. |
| Optional | `pbi-tools` | Automated PBIP/PBIX extract and compile workflows. |
| Optional | .NET SDK/runtime | Tooling that shells out to .NET-based utilities. |

Check the local machine before running live or external-tool workflows:

```powershell
.\plugins\powerbi-desktop\scripts\Test-PowerBIEnvironment.ps1
```

The check reports missing optional tools as `not found`. Install `pbi-tools` only when automated PBIP-to-PBIX compile is required; otherwise open the PBIP in Power BI Desktop, validate it, and use Save As PBIX.

Run the local smoke test first:

```powershell
.\plugins\powerbi-desktop\tests\Run-PowerBITests.ps1
```

For the productized end-to-end workflow:

```powershell
.\plugins\powerbi-desktop\scripts\Invoke-PowerBIUnifiedReview.ps1 -Path .\your-model -OutputDirectory .\powerbi-unified-review
```

For the fastest release-oriented path through the new USP stack:

```powershell
.\plugins\powerbi-desktop\scripts\Resolve-PowerBILiveTarget.ps1 -Json
.\plugins\powerbi-desktop\scripts\New-PowerBITomWritePlan.ps1 -Operation AddMeasure -TableName Sales -ObjectName "Average Sales"
.\plugins\powerbi-desktop\scripts\Invoke-PowerBISemanticTestRunner.ps1 -Path .\your-model -Json
.\plugins\powerbi-desktop\scripts\New-PowerBIVisualIntentAnalyzer.ps1 -Path .\your-model -OutputPath .\powerbi-visual-intelligence.md
.\plugins\powerbi-desktop\scripts\New-PowerBIReleaseCandidatePack.ps1 -Path .\your-model -OutputDirectory .\powerbi-release-candidate-pack -SkipLive
```

Read that sequence as a safety funnel:

- Resolve the live target first, or make the unavailable/ambiguous live endpoint explicit.
- Generate a write safety plan before any TOM/TMSL or PBIP mutation.
- Run semantic tests from `measure-expectations.json`, or let the runner create pending placeholders.
- Review visual intelligence against PBIP report metadata when it exists.
- Produce the release candidate pack as the machine-readable handoff for governance and PR review, including gate status, roundtrip readiness, rollback readiness, and live availability.

For a full local review of a PBIP/TMDL folder or exported text model:

```powershell
.\plugins\powerbi-desktop\scripts\Invoke-PowerBIAutoReview.ps1 -Path .\your-model -OutputDirectory .\powerbi-auto-review
```

For the differentiating trust workflow:

```powershell
.\plugins\powerbi-desktop\scripts\New-PowerBITrustReleaseGate.ps1 -Path .\your-model -OutputPath .\powerbi-trust-release-gate.md
```

For safe authoring, generate drafts instead of writing directly to PBIX:

```powershell
.\plugins\powerbi-desktop\scripts\New-PowerBIMeasureDraft.ps1 -TableName Sales -MeasureName "Average Sales" -Expression "DIVIDE([Total Sales], COUNTROWS('Sales'))"
```

To create a PBIP report page with visuals and then return to PBIX:

```powershell
.\plugins\powerbi-desktop\scripts\Add-PowerBIPBIPReportPage.ps1 -PbipPath .\MyReport -PageName "Executive Overview" -Measures "Total Sales","Sales YoY %" -Apply
.\plugins\powerbi-desktop\scripts\New-PowerBIPBIXCompileWorkflow.ps1 -PbipPath .\MyReport -OutputPbix .\MyReport.pbix
```

If `pbi-tools` is installed, use the generated compile command. Otherwise open the PBIP in Power BI Desktop, validate the new page, and use Save As PBIX.

More focused guides:

- [Unified review](unified-review.md)
- [Max AI review](max-ai-review.md)
- [External Tool installation](external-tool-installation.md)
- [Golden baselines](golden-baselines.md)
- [Testing](testing.md)

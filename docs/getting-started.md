# Getting Started

Use [docs/index.md](index.md) as the full documentation map. This page is the shortest path from a fresh checkout to a useful Power BI review.

Run the local smoke test first:

```powershell
.\plugins\powerbi-desktop\tests\Run-PowerBITests.ps1
```

For the productized end-to-end workflow:

```powershell
.\plugins\powerbi-desktop\scripts\Invoke-PowerBIUnifiedReview.ps1 -Path .\your-model -OutputDirectory .\powerbi-unified-review
```

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

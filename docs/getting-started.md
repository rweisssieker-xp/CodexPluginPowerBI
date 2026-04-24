# Getting Started

Run the local smoke test first:

```powershell
.\plugins\powerbi-desktop\scripts\Test-PowerBIPlugin.ps1
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


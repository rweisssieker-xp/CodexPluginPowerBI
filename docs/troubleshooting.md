# Troubleshooting

## Power BI Desktop Is Running But No Live Endpoint Is Found

Wait until the report is fully loaded and rerun:

```powershell
.\plugins\powerbi-desktop\scripts\Get-PowerBIDesktopLiveConnection.ps1
```

If the endpoint is still missing, close and reopen the report. Live mode depends on Desktop exposing the local model endpoint.

## ADOMD Or Provider Errors

Some environments load ADOMD more reliably in Windows PowerShell 5.1 than in PowerShell 7.

Try:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\plugins\powerbi-desktop\scripts\Get-PowerBIDesktopLiveConnection.ps1
```

If that works, run live scripts from Windows PowerShell 5.1.

## Pester Is Missing

Run the smoke tests without Pester:

```powershell
.\plugins\powerbi-desktop\tests\Run-PowerBITests.ps1 -SkipPester
```

Install Pester when you need the full local test set.

## External Tool Does Not Appear In Power BI Desktop

Generate or install the `.pbitool.json`, then restart Power BI Desktop:

```powershell
.\plugins\powerbi-desktop\scripts\New-PowerBIExternalToolRegistration.ps1
.\plugins\powerbi-desktop\scripts\Install-PowerBIExternalTool.ps1
```

Power BI Desktop usually reads External Tools registrations at startup.

## Generated Output Makes Git Look Dirty

Review outputs are reproducible artifacts. The repository ignores many generated review folders, but local experiments may still create files. Confirm whether a file is an intended source change before staging it.

Useful checks:

```powershell
git status --short
rg --files .\powerbi-unified-review .\powerbi-max-ai-review .\plugins\powerbi-desktop\tmp
```

## PBIP Apply Wrote To The Wrong Folder

Do not manually delete broad folders. Inspect the apply plan and use source control to revert the exact generated artifacts.

```powershell
.\plugins\powerbi-desktop\scripts\Invoke-PowerBIPBIPApplyPlan.ps1 -PbipPath .\MyReport
git status --short
```

## DAX Query Fails In Live Mode

Validate the expression in DAX Studio or simplify the query:

```powershell
.\plugins\powerbi-desktop\scripts\Invoke-PowerBILiveDaxQuery.ps1 `
  -Query "EVALUATE ROW(`"Check`", 1)"
```

If the simple query works, the connection is healthy and the issue is in the DAX or model context.

## Offline Review Finds Too Little

The plugin can only inspect available files. For binary PBIX-only reports, export to PBIP/TMDL or use live Desktop mode.

## Fabric Scripts Do Not Publish

That is expected. Fabric scripts produce readiness and risk artifacts only. Tenant publishing, refresh credentials, deployment pipelines, and workspace changes must stay explicit.

# Troubleshooting

## Power BI Desktop Is Running But No Live Endpoint Is Found

Wait until the report is fully loaded and rerun:

```powershell
.\plugins\powerbi-desktop\scripts\Get-PowerBIDesktopLiveConnection.ps1
```

If the endpoint is still missing, close and reopen the report. Live mode depends on Desktop exposing the local model endpoint.

Status guidance:

- `NoLiveTarget`: no listening local Desktop model endpoint was found. Open a PBIX/PBIP in Power BI Desktop, wait for load completion, and rerun discovery.
- `AmbiguousLiveTarget`: more than one compatible local endpoint is visible. Close extra Desktop windows or pass the intended server and database values to the live script that supports explicit targeting.
- `LiveUnavailable`: the workflow attempted live validation but could not connect or query. Treat live-only checks as unavailable, then rerun after Desktop, ADOMD, and permissions are healthy.

## ADOMD Or Provider Errors

Some environments load ADOMD more reliably in Windows PowerShell 5.1 than in PowerShell 7.

First confirm whether the provider is installed:

```powershell
.\plugins\powerbi-desktop\scripts\Test-PowerBIEnvironment.ps1
```

The `AdomdClient` line should point to `Microsoft.AnalysisServices.AdomdClient.dll`. If it is `not found`, install DAX Studio, SSMS, or the Microsoft ADOMD.NET provider. Do not copy the DLL into this repository.

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

## Semantic Tests Are Pending

`PendingLiveDax` means the semantic expectation was generated or discovered, but could not be validated against a live model. This is expected in offline-only CI or when Desktop/ADOMD is unavailable.

For release gates, rerun with live Desktop available and use `-FailOnPending` so unresolved live DAX checks fail the gate:

```powershell
.\plugins\powerbi-desktop\scripts\Invoke-PowerBISemanticTestRunner.ps1 `
  -Path .\plugins\powerbi-desktop\examples\sample-model `
  -FailOnPending
```

## Offline Review Finds Too Little

The plugin can only inspect available files. For binary PBIX-only reports, export to PBIP/TMDL or use live Desktop mode.

## Fabric Live Read-Only Needs Access

`NeedsAccessPlan` means the workflow needs either `-SnapshotDirectory` or explicit Fabric live read parameters:

```powershell
.\plugins\powerbi-desktop\scripts\Get-PowerBIFabricAccessPlan.ps1 -WorkspaceName "Target Workspace" -AccessTokenPath .\token.txt -Json
```

`BlockedUnsafeMethod` is intentional. Fabric live v1 permits GET-only read paths and blocks publish, promote, refresh trigger, rebind, delete, endorsement writes, and other mutations. Missing Fabric fields should be treated as snapshot/API permission gaps, not as plugin crashes.

## PBIP Roundtrip Is Incomplete

PBIP-to-PBIX workflows require enough PBIP structure for Desktop or `pbi-tools` to round-trip safely. If `New-PowerBIPBIXCompileWorkflow.ps1` warns that `pbi-tools` is missing or the PBIP roundtrip status is incomplete, do not treat automated compile as ready.

Run:

```powershell
.\plugins\powerbi-desktop\scripts\Get-PowerBIPBIPStructure.ps1 -Path .\MyReport
.\plugins\powerbi-desktop\scripts\New-PowerBIPBIXCompileWorkflow.ps1 -PbipPath .\MyReport
```

Install `pbi-tools` only when automated compile is required. Otherwise open the PBIP in Power BI Desktop, validate it manually, and save the release candidate PBIX from Desktop.

## Screenshot Review Needs Input

`New-PowerBIReportScreenshotUXReview.ps1` returns `NotAvailable` with `needsInput` when the screenshot path is missing or cannot be read. Export or capture a report page screenshot and rerun the review with a valid `-ImagePath`.

## Fabric Scripts Do Not Publish

That is expected. Fabric scripts produce readiness and risk artifacts only. Tenant publishing, refresh credentials, deployment pipelines, and workspace changes must stay explicit.

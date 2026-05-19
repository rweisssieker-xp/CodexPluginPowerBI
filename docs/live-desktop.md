# Live Power BI Desktop

Live Desktop mode connects to the currently open local Power BI Desktop model through the local XMLA/ADOMD endpoint exposed by Desktop.

## Requirements

- Power BI Desktop is running.
- A report/model is open.
- The local endpoint can be discovered.
- The required ADOMD provider is available. If it is not available in PowerShell 7, use Windows PowerShell 5.1.

Start with:

```powershell
.\plugins\powerbi-desktop\scripts\Get-PowerBIDesktopLiveConnection.ps1
```

The command reports whether Desktop is running and whether an endpoint was found.
When multiple Desktop models are open, no endpoint is selected automatically. Use `-RequireSingle` to fail unless exactly one listening endpoint exists, or pass `-Server "Data Source=localhost:12345"` / `-Port 12345` to select the intended model.

For machine-readable target selection:

```powershell
.\plugins\powerbi-desktop\scripts\Resolve-PowerBILiveTarget.ps1 -RequireSingle -Json
```

Statuses are `TargetResolved`, `AmbiguousLiveTarget`, or `NoLiveTarget`.

## Read-Only Contract

Live scripts query metadata, DMV data, and DAX results. They do not mutate the open model. Durable changes should be drafted into PBIP/TMDL using the PBIP authoring and apply scripts.

## Safety Plan

Mutating live workflows must publish a safety plan before execution:

```powershell
.\plugins\powerbi-desktop\scripts\New-PowerBILiveSafetyPlan.ps1 `
  -ActionName "Update measure" `
  -OperationType Mutating `
  -DryRun `
  -Json
```

The plan is machine-readable (`codex.powerbi.liveSafetyPlan.v1`) and separates:

- `DryRun`: plan only, no mutation.
- `Preview`: resolve target and show intended action, no mutation.
- `Confirm`: explicit opt-in required by any mutating workflow.

Guardrails are fixed: no live `SaveChanges`, no publish, and no credential read/write/prompt/storage.

## Common Commands

```powershell
.\plugins\powerbi-desktop\scripts\Get-PowerBILiveModelSummary.ps1 -OutputPath .\powerbi-live-model-summary.md
.\plugins\powerbi-desktop\scripts\Invoke-PowerBILiveInsightScan.ps1 -OutputPath .\powerbi-live-insight-scan.md
.\plugins\powerbi-desktop\scripts\Test-PowerBILiveMeasures.ps1 -OutputPath .\powerbi-live-measure-validation.md
.\plugins\powerbi-desktop\scripts\Test-PowerBILiveMetadataGovernance.ps1 -OutputPath .\powerbi-live-metadata-governance.md
.\plugins\powerbi-desktop\scripts\New-PowerBILiveFixBacklog.ps1 -OutputPath .\powerbi-live-fix-backlog.md
.\plugins\powerbi-desktop\scripts\New-PowerBILiveDaxFixDrafts.ps1 -OutputPath .\powerbi-live-dax-fix-drafts.md
.\plugins\powerbi-desktop\scripts\Invoke-PowerBILiveAutoReview.ps1 -OutputDirectory .\powerbi-live-auto-review
```

## DAX And DMV Queries

Run a focused DAX query:

```powershell
.\plugins\powerbi-desktop\scripts\Invoke-PowerBILiveDaxQuery.ps1 `
  -Query "EVALUATE ROW(`"Total Sales`", [Total Sales])"
```

Run a DMV query:

```powershell
.\plugins\powerbi-desktop\scripts\Invoke-PowerBILiveDmv.ps1 `
  -Query "SELECT * FROM `$SYSTEM.TMSCHEMA_MEASURES"
```

## Typical Failure Modes

- Desktop is not open: start Desktop and open a report.
- Endpoint not found: wait until the model is fully loaded and rerun discovery.
- ADOMD load failure: run in Windows PowerShell 5.1 or install the local provider.
- Query fails: validate the DAX in DAX Studio, then rerun the plugin command.
- Live and repo differ: run `Compare-PowerBILiveRepoModel.ps1` and decide whether Desktop or source files are authoritative.

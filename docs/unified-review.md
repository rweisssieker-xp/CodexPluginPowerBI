# Unified Review

Run the unified review when you want one folder that ties together the offline project review, the live Desktop review when available, and the Power BI External Tools registration file.

```powershell
.\plugins\powerbi-desktop\scripts\Invoke-PowerBIUnifiedReview.ps1 -Path .\plugins\powerbi-desktop\examples\sample-model -OutputDirectory .\powerbi-unified-review
```

The runner always creates an offline review. It attempts live review only when Power BI Desktop exposes a local XMLA/ADOMD endpoint. If no endpoint is detected, the unified review summary can mark the live review step as `NotAvailable`; that means the offline package is still valid, but live Desktop evidence was not attached.

For live-vs-repo reconciliation, use `Compare-PowerBILiveRepoModel.ps1`. Its `liveStatus` values are more precise:

- `LiveUnavailable`: no live comparison was performed because the Desktop endpoint or ADOMD access was unavailable.
- `NoDrift`: a live endpoint was available and no supported measure/table drift was detected.
- `DriftDetected`: a live endpoint was available and supported measure/table drift was detected.

Use these reconciliation statuses in release notes and governance automation instead of treating every missing live endpoint as a failed offline review.

Primary outputs:

- `README.md`: human-readable entry point.
- `summary.json`: machine-readable status.
- `offline-review\README.md`: project/PBIP/TMDL review.
- `live-review\README.md`: live model review when available.
- `external-tool\Codex Power BI Workbench.pbitool.json`: External Tools registration draft.

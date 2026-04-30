# Unified Review

Run the unified review when you want one folder that ties together the offline project review, the live Desktop review when available, and the Power BI External Tools registration file.

```powershell
.\plugins\powerbi-desktop\scripts\Invoke-PowerBIUnifiedReview.ps1 -Path .\plugins\powerbi-desktop\examples\sample-model -OutputDirectory .\powerbi-unified-review
```

The runner always creates an offline review. It attempts live review only when Power BI Desktop exposes a local XMLA/ADOMD endpoint. If no endpoint is detected, the summary marks live review as `NotAvailable` and keeps the offline package valid.

Primary outputs:

- `README.md`: human-readable entry point.
- `summary.json`: machine-readable status.
- `offline-review\README.md`: project/PBIP/TMDL review.
- `live-review\README.md`: live model review when available.
- `external-tool\Codex Power BI Workbench.pbitool.json`: External Tools registration draft.

# Power BI Executive Narrative

This report is currently rated **Medium** risk with a score of **8**.
The scan found **5** metrics, **1** Power Query file(s), and **4** prioritized finding(s).

## What Matters

- **FILTER over ALL pattern**: This pattern can be expensive on large models. Review whether KEEPFILTERS, REMOVEFILTERS, or a narrower table expression is possible.
- **Volatile date/time function**: TODAY/NOW can make refresh and testing behavior time-dependent. Consider a governed date table or refresh parameter.
- **Local file dependency**: Local file paths can break refresh in shared workspaces. Consider parameters, gateways, SharePoint, OneLake, or governed storage.

## Metrics Needing Sign-Off

- `All Customer Sales` from `Risky.Measures.dax` needs owner and definition review. Risks: performance: FILTER over ALL
- `Refresh Sensitive Sales` from `Risky.Measures.dax` needs owner and definition review. Risks: determinism: volatile date/time

## Dependency Impact

- `Total Sales` has dependency hub score 4; validate downstream impact before changing it.
- `Sales YoY %` has dependency hub score 2; validate downstream impact before changing it.
- `Total Sales Prior Year` has dependency hub score 2; validate downstream impact before changing it.

## First Actions

- Export or maintain the project as PBIP/TMDL before structural changes.
- Assign owners and business definitions for every metric marked for review.
- Validate DAX changes in Power BI Desktop and, where available, DAX Studio or Tabular Editor.


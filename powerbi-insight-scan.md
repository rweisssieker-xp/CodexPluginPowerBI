# Power BI Insight Scan

Root: `D:\temp\CodexPluginPowerBI\plugins\powerbi-desktop\examples\sample-model`
Generated: 2026-04-23T13:07:20

## Executive Signal

- Risk level: **Medium**
- Risk score: **8**
- Power BI files: 4
- Measures detected: 5
- Power Query files detected: 1
- TMDL objects detected: 8

## Findings

### [High] FILTER over ALL pattern

- Category: DAX Performance
- Source: `Risky.Measures.dax`
- Detail: This pattern can be expensive on large models. Review whether KEEPFILTERS, REMOVEFILTERS, or a narrower table expression is possible.

### [Medium] Volatile date/time function

- Category: Refresh Determinism
- Source: `Risky.Measures.dax`
- Detail: TODAY/NOW can make refresh and testing behavior time-dependent. Consider a governed date table or refresh parameter.

### [Medium] Local file dependency

- Category: Data Source Governance
- Source: `SalesQuery.pq`
- Detail: Local file paths can break refresh in shared workspaces. Consider parameters, gateways, SharePoint, OneLake, or governed storage.

### [Low] Text artifacts without PBIP file

- Category: Project Format
- Source: `.`
- Detail: A PBIP entry point improves Power BI Desktop round-tripping and source-control structure.

## Recommended Next Actions

- Export PBIX/PBIT assets to PBIP before structural edits.
- Generate a model summary and attach it to the report documentation.
- Review high and medium findings before optimizing visuals or adding features.
- Use Tabular Editor Best Practice Analyzer when available.


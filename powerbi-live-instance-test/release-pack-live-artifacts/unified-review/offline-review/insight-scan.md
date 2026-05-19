# Power BI Insight Scan

Root: `D:\temp\CodexPluginPowerBI\powerbi-live-instance-test\live-auto-review`
Generated: 2026-05-19T06:56:02

## Executive Signal

- Risk level: **Low**
- Risk score: **3**
- Power BI files: 4
- Measures detected: 0
- Power Query files detected: 0
- TMDL objects detected: 0

## Findings

### [High] No text-based model artifacts

- Category: Inspectability
- Source: `.`
- Detail: Codex can inventory binary files, but deep semantic review needs PBIP, TMDL, model.bim, DAX, or Power Query exports.

## Recommended Next Actions

- Export PBIX/PBIT assets to PBIP before structural edits.
- Generate a model summary and attach it to the report documentation.
- Review high and medium findings before optimizing visuals or adding features.
- Use Tabular Editor Best Practice Analyzer when available.


# Business Process Data Quality

The Business Process Data Quality layer checks standard process data from local Power BI projects and local ERP exports. It is local-first: no ERP login, no database connection, no external API call, no Power BI Service publish, and no PBIX mutation.

## What It Covers

The first process packs are:

- Order-to-Cash
- Procure-to-Pay
- Record-to-Report
- Hire-to-Retire
- Plan-to-Produce
- Forecast-to-Deliver
- Service-to-Cash
- Issue-to-Resolution
- Lead-to-Opportunity
- Quote-to-Order

Each process pack defines canonical business objects, required fields, optional fields, deterministic data-quality rules, KPI impact hints, owner hints, recommended actions, and release impact.

## Inputs

The framework treats both input paths as first-class:

- Power BI model path: PBIP/TMDL/model metadata, metric catalog, KPI trust score, semantic contract drift, and sensitive-data evidence.
- Export data path: local CSV or JSON exports from ERP, CRM, planning, HR, finance, or service systems.

If no mapping is supplied, `New-PowerBIProcessDataMapping.ps1` creates a mapping proposal and the review returns `NeedsMapping` instead of failing.

## Commands

Create a mapping proposal:

```powershell
.\plugins\powerbi-desktop\scripts\New-PowerBIProcessDataMapping.ps1 `
  -Path .\plugins\powerbi-desktop\examples\sample-model `
  -DataPath .\plugins\powerbi-desktop\examples\business-process-data `
  -OutputPath .\process-data-mapping.json `
  -Json
```

Run every process pack:

```powershell
.\plugins\powerbi-desktop\scripts\Invoke-PowerBIBusinessProcessDataQuality.ps1 `
  -Path .\plugins\powerbi-desktop\examples\sample-model `
  -DataPath .\plugins\powerbi-desktop\examples\business-process-data `
  -OutputDirectory .\powerbi-business-process-dq `
  -ProcessPack All
```

Run one process pack:

```powershell
.\plugins\powerbi-desktop\scripts\Invoke-PowerBIBusinessProcessDataQuality.ps1 `
  -Path .\plugins\powerbi-desktop\examples\sample-model `
  -DataPath .\plugins\powerbi-desktop\examples\business-process-data `
  -OutputDirectory .\powerbi-business-process-dq `
  -ProcessPack OrderToCash
```

Create a standalone pack:

```powershell
.\plugins\powerbi-desktop\scripts\New-PowerBIBusinessProcessDQPack.ps1 `
  -Path .\plugins\powerbi-desktop\examples\sample-model `
  -DataPath .\plugins\powerbi-desktop\examples\business-process-data `
  -OutputDirectory .\powerbi-business-process-dq
```

Include process DQ in a release candidate:

```powershell
.\plugins\powerbi-desktop\scripts\New-PowerBIReleaseCandidatePack.ps1 `
  -Path .\plugins\powerbi-desktop\examples\sample-model `
  -OutputDirectory .\powerbi-release-candidate-pack `
  -SkipLive `
  -IncludeBusinessProcessDQ `
  -BusinessProcessDataPath .\plugins\powerbi-desktop\examples\business-process-data
```

## Outputs

`Invoke-PowerBIBusinessProcessDataQuality.ps1` writes:

- `summary.json`
- `process-findings.json`
- `mapping-coverage.json`
- `kpi-impact.json`
- `owner-actions.md`
- one detail folder per process pack

Typical statuses are:

- `Passed`: no high-risk findings and mapping is usable.
- `Review`: medium/low findings need review.
- `HighRisk`: high-severity process issues were detected.
- `NeedsMapping`: mappings are incomplete and should be confirmed.
- `MappingIncomplete`: a required object or field could not be matched.

## Boundaries

The checks find problems visible in local model metadata or local exports: completeness, key integrity, date logic, KPI trust, mapping coverage, owner gaps, and release risk. They are not a full process-mining replacement without event logs, timestamps, case IDs, and activity history, and they cannot detect ERP-internal issues that are not present in the exported data.

# Power BI Desktop Plugin v2.1.0

Release date: 2026-05-20

## Summary

v2.1.0 adds a local Business Process Data Quality layer for standard process checks across Power BI metadata and local CSV/JSON export data. It keeps the existing local-first contract: no service calls, no ERP login, no database connection, no PBIX mutation, and no hidden writes.

## Highlights

- New process DQ orchestrator: `Invoke-PowerBIBusinessProcessDataQuality.ps1`
- New mapping proposal script: `New-PowerBIProcessDataMapping.ps1`
- New standalone pack wrapper: `New-PowerBIBusinessProcessDQPack.ps1`
- Ten extensible process rule packs:
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
- Optional Release Candidate Pack integration with `-IncludeBusinessProcessDQ`
- New documentation, sample ERP-style CSV fixtures, smoke coverage, and Pester coverage

## GitHub Release Text

```markdown
## Power BI Desktop Plugin v2.1.0

This release adds Business Process Data Quality Packs for local Power BI and ERP/CSV/JSON export checks.

### Added

- Local process data quality framework for Power BI metadata plus CSV/JSON exports.
- Ten process packs: Order-to-Cash, Procure-to-Pay, Record-to-Report, Hire-to-Retire, Plan-to-Produce, Forecast-to-Deliver, Service-to-Cash, Issue-to-Resolution, Lead-to-Opportunity, and Quote-to-Order.
- Mapping proposal generation for canonical process objects and fields.
- Deterministic process findings with severity, evidence, KPI impact, owner hints, recommended actions, and release impact.
- Optional release candidate evidence with `-IncludeBusinessProcessDQ`.

### Local-first boundary

- No ERP login.
- No database connection.
- No external API calls.
- No Power BI Service publish.
- No PBIX mutation.
- Not a full process-mining replacement without event logs.

### Verification

- `Test-PowerBIDocumentationCoverage.ps1` passed.
- `Test-PowerBIPlugin.ps1` passed.
- `Run-PowerBITests.ps1` passed.
- `BusinessProcessDQ.Tests.ps1` passed.
- PSScriptAnalyzer passed with no script errors.
```

## Verification

- `Test-PowerBIDocumentationCoverage.ps1` passed.
- `Test-PowerBIPlugin.ps1` passed.
- `Run-PowerBITests.ps1` passed.
- `BusinessProcessDQ.Tests.ps1` passed.
- PSScriptAnalyzer passed with no script errors.

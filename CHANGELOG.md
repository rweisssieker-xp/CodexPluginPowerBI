# Changelog

## v3.0.0 - 2026-06-04

### Added

- Added advanced release USP workflows: evidence graph, DAX change risk classifier, semantic contract test, freshness/lineage gate, executive trust brief, KPI drift watchlist, RLS trust review, UX regression scanner, and migration readiness.
- Added `-IncludeAdvancedUspQa` to release candidate packs so advanced release USP evidence can be generated as part of the local release package.
- Added separated portfolio governance, compliance QA, and operations QA workflows with `-IncludePortfolioGovernanceQa`, `-IncludeComplianceQa`, and `-IncludeOperationsQa`.
- Added Fabric Live Read-Only + Snapshot Intelligence workflows with access plans, GET-only REST guardrails, workspace/tenant snapshots, 25 Fabric USP scripts, and release candidate pack switches for Fabric portfolio, deployment, operations, governance, and executive QA.
- Added analytical release QA workflows: `Test-PowerBIAnalysisMethodology.ps1`, `New-PowerBIMetricChangeDiagnosis.ps1`, and `New-PowerBIAnalyticalReleaseReport.ps1`.
- Added `-IncludeAnalyticalQa` to release candidate packs so methodology validation, metric diagnosis, and stakeholder-ready analytical reports can be included in release evidence.

### Verification

- `Invoke-Pester .\plugins\powerbi-desktop\tests\pester\PowerBIPlugin.Tests.ps1` passed.
- `Test-PowerBIDocumentationCoverage.ps1` passed.
- `Test-PowerBIPlugin.ps1` passed.
- `plugin.json` parse check passed.

## v2.1.0 - 2026-05-20

### Added

- Added local Business Process Data Quality packs for Order-to-Cash, Procure-to-Pay, Record-to-Report, Hire-to-Retire, Plan-to-Produce, Forecast-to-Deliver, Service-to-Cash, Issue-to-Resolution, Lead-to-Opportunity, and Quote-to-Order.
- Added `Invoke-PowerBIBusinessProcessDataQuality.ps1`, `New-PowerBIProcessDataMapping.ps1`, and `New-PowerBIBusinessProcessDQPack.ps1` for local Power BI metadata plus CSV/JSON export validation.
- Added process rule packs, sample ERP-style CSV fixtures, process DQ smoke tests, focused Pester coverage, and dedicated documentation.

### Changed

- Kept Business Process Data Quality separate from the 39-artifact Max AI Review while allowing release candidate packs to include process DQ summary evidence with `-IncludeBusinessProcessDQ`.
- Updated plugin metadata, README positioning, script catalog, value proposition, workflow docs, testing docs, and skill guidance for the new process DQ layer.

### Verification

- `Test-PowerBIDocumentationCoverage.ps1` passed.
- `Test-PowerBIPlugin.ps1` passed.
- `Run-PowerBITests.ps1` passed.
- `BusinessProcessDQ.Tests.ps1` passed.
- PSScriptAnalyzer passed with no script errors.
- Generated/local output patterns are ignored and not staged.

## v2.0.0 - 2026-05-20

### Added

- Expanded the Power BI Desktop plugin into a 38-USP AI Power BI Workbench.
- Added eighteen AI workflows:
  - Agentic Remediation Prioritization
  - Business Outcome Simulation
  - Semantic Layer Autopilot
  - AI Governance Evidence Pack
  - Human Override Learning
  - Cross-Report KPI Conflict Detection
  - Executive Narrative Quality Agent
  - Autonomous Power BI QA Lab
  - PBIP Change Impact Gate
  - Semantic Test Fixture Generator
  - KPI Owner Sign-off Workflow
  - Refresh Blast-Radius Analyzer
  - Sensitive Data Exposure Map
  - Capacity Mitigation Planner
  - Report Retirement Advisor
  - Live Validation Evidence Recorder
  - Semantic Contract Drift Monitor
  - RLS Persona Coverage Matrix
- Extended Max AI Review to produce 39 local artifacts across the 38-USP workflow set.
- Added deterministic local PowerShell scripts for the new AI workflows with JSON and Markdown/default output behavior.
- Added documentation for the expanded USP map, workflows, script catalog entries, Max AI artifacts, and value proposition.
- Added test coverage for new script presence, JSON schemas, sample-model execution, Max AI artifact generation, and documentation coverage.

### Changed

- Updated plugin positioning to a 38-USP AI Power BI Workbench.
- Updated plugin metadata, default prompts, README positioning, and capability descriptions.
- Kept the execution model local-first: no hidden service calls, no PBIX mutation, no implicit publish, and no hidden writes.
- Tightened `.gitignore` so generated local review, live, forecast, incident, QA, and release outputs stay out of Git.

### Removed

- Removed generated local Power BI artifacts, live-model outputs, forecast extracts, incident reports, backup dumps, and local helper scripts from Git tracking.
- Removed Python cache artifacts from Git tracking.

### Verification

- `Test-PowerBIDocumentationCoverage.ps1` passed.
- `Test-PowerBIPlugin.ps1` passed.
- `Run-PowerBITests.ps1` passed.
- PSScriptAnalyzer passed with no script errors.
- Generated/local output patterns are ignored and not staged.

## v1.0.0

- Initial public plugin release baseline.

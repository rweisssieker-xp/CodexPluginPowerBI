# User Changelog

## Unreleased

This update adds advanced release USPs for teams that need traceable Power BI release decisions across metrics, visuals, contracts, security, UX, and migration readiness.

### New Advanced Release USP Workflows

- Release Candidate Packs can include advanced USP evidence through `-IncludeAdvancedUspQa`.
- New local checks cover evidence graphs, visual-to-measure impact, semantic contracts, executive trust briefs, DAX change risk, freshness/lineage, KPI drift watchlists, RLS trust review, UX regression, and migration readiness.
- Release Candidate Packs can now keep portfolio governance, compliance QA, and operations QA separate through `-IncludePortfolioGovernanceQa`, `-IncludeComplianceQa`, and `-IncludeOperationsQa`.
- Fabric Live Read-Only QA can now use token-file access planning or local Fabric snapshots, then generate separate Fabric portfolio, deployment, operations, governance, and executive evidence packs.

This update adds analytical release QA for teams that need stakeholder-ready evidence, not only generated review artifacts.

### New Analytical QA Workflows

- Methodology validation checks metric definitions, grain, denominators, semantic-test coverage, PBIP readiness, and release caveats.
- Metric change diagnosis explains whether a KPI movement is verified, likely, or blocked by missing comparison evidence.
- Analytical release reports turn trust, release-gate, and methodology evidence into a concise Markdown handoff.
- Release Candidate Packs can include analytical QA through `-IncludeAnalyticalQa`.

## v2.1.0 - 2026-05-20

This release adds local Business Process Data Quality packs for standard processes to the Power BI Desktop plugin.

### New Process Data Quality Features

- Order-to-Cash, Procure-to-Pay, Record-to-Report, Hire-to-Retire, Plan-to-Produce, Forecast-to-Deliver, Service-to-Cash, Issue-to-Resolution, Lead-to-Opportunity, and Quote-to-Order.
- Local checks for Power BI model metadata and CSV/JSON export data.
- Mapping proposals for canonical process objects such as SalesOrder, Invoice, Payment, Delivery, PurchaseOrder, Vendor, GLAccount, Employee, and ProductionOrder.
- Process findings with severity, evidence, KPI impact, owner hint, recommended action, and release impact.
- Optional inclusion in Release Candidate Packs through `-IncludeBusinessProcessDQ`.

### Safety And Boundaries

- Keine ERP-Logins.
- No database connections.
- No external API calls.
- No PBIX mutation.
- Not a replacement for full process mining without event logs.

## v2.0.0 - 2026-05-20

This release makes the Power BI Desktop plugin release-ready as a neutral, local AI workbench for Power BI projects.

### New AI Value Areas

- Prioritized remediation plans for release blockers, KPI trust, lineage impact, and governance risks.
- Business Outcome Simulation for decisions, audiences, possible wrong decisions, and required evidence.
- Semantic Layer Autopilot for better metric descriptions, synonyms, ownership, and Copilot readiness.
- AI Governance Evidence Pack for audit evidence, sign-off gaps, residual risks, and release evidence.
- Human Override Learning for structured capture of human corrections and learning signals.
- Cross-Report KPI Conflict Detection for conflicting KPI definitions across reports.
- Executive Narrative Quality Agent for leadership narratives backed by visuals, KPI trust, and release evidence.
- Autonomous Power BI QA Lab for generated QA questions, semantic expectations, visual readiness, and regression risks.
- PBIP Change Impact Gate for release-relevant impact from changed PBIP/TMDL/report files.
- Semantic Test Fixture Generator for reproducible KPI test data and measure expectations.
- KPI Owner Sign-off Workflow for binding approval decisions per metric.
- Refresh Blast-Radius Analyzer for refresh, capacity, and service risk impact.
- Sensitive Data Exposure Map for sensitive fields and review actions.
- Capacity Mitigation Planner for concrete mitigations for capacity and performance risks.
- Report Retirement Advisor for consolidation, review, or retirement of weak reports and KPIs.
- Live Validation Evidence Recorder for local evidence from Power BI Desktop validations.
- Semantic Contract Drift Monitor for stale ownership, missing contracts, and expectation drift.
- RLS Persona Coverage Matrix for security roles, personas, and coverage gaps.

### Improved Review Packages

- Max AI Review now creates 39 local artifacts across 38 AI USP workflows.
- Release Candidate Packs combine gate decision, service scanner, semantic tests, risk heatmap, and PR comment.
- Documentation, script catalog, and value proposition were updated for the 38-USP positioning.

### Safety And Neutrality

- Workflows remain local-first.
- Reports are not published.
- Power BI Service logins and credentials are not required.
- PBIX files are not changed automatically.
- Generated local review, live, forecast, incident, and QA outputs are no longer tracked in Git.

## v1.0.0

- Initial public plugin baseline.

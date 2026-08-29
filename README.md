# Power BI Desktop Codex Plugin

This workspace contains a Codex plugin for Microsoft Power BI Desktop workflows.

## From Data Sources To Decision-Ready Power BI

Give the plugin your local files or declare the Power BI Desktop connectors you use. The **Power BI Model Wizard** turns that starting point into a governed build plan: source and data-contract drafts, a proposed star schema, KPI and RLS checkpoints, report-page plan, and a validation path.

```powershell
# Local CSV or JSON sources are profiled automatically.
.\plugins\powerbi-desktop\scripts\New-PowerBIModelWizard.ps1 `
  -ProjectName ContosoSales `
  -DataSourcePaths .\sales.csv, .\customers.json `
  -BusinessPurpose "Manage sales performance" `
  -Initialize

# Any connector in the user's Power BI Desktop Get Data experience can be declared.
.\plugins\powerbi-desktop\scripts\New-PowerBIModelWizard.ps1 `
  -ProjectName ContosoEnterprise `
  -DataSourceConfigPath .\templates\powerbi-data-sources.example.json `
  -BusinessPurpose "Run the executive operating review" `
  -Initialize
```

**The USP:** analysts start with data, executives get decision-ready KPIs, and developers receive a source-controlled PBIP-first implementation plan instead of a blank canvas. Credentials remain in Power BI Desktop or an approved gateway; the plugin never stores them, creates PBIX binaries, or publishes content.

## Why It Matters

The plugin turns Codex into a local Power BI engineering workbench. It helps teams review models faster, create safer PBIP/TMDL changes, produce release evidence, improve KPI trust, and plan Fabric/service readiness without uploading report data by default.

For a concise benefit and USP overview, start with [Value Proposition And USPs](docs/value-proposition.md).

## Start By Role

Choose the outcome you need rather than a technical feature. The same project can be reviewed from several perspectives.

| Role | Start here | Result |
| --- | --- | --- |
| Analyst | "Explain the KPI definitions, highlight data-quality risks, and suggest the next analysis." | Metric catalog, quality findings, and an analysis-ready narrative. |
| Executive / decision maker | "Can this report be trusted for a decision? Give me an executive brief and the open risks." | Concise decision brief with Go/Warn/No-Go context, assumptions, and owners. |
| Power BI developer | "Review this PBIP/TMDL project, identify technical risks, and create safe change drafts." | DAX/PQ findings, dependency impact, tests, and PBIP-safe drafts. |
| BI or release lead | "Prepare a release decision with evidence, test status, governance risks, and rollback guidance." | Release candidate pack and explicit sign-off actions. |
| New model owner | "Build a new Power BI model from these data sources and this business goal." | Data-source-to-PBIP design pack with schema, KPIs, RLS, report pages, and validation steps. |

The full role-based guide, including example prompts and the evidence maturity of each workflow, is in [Role-based entry points](docs/role-based-entry-points.md).

For Fabric FinOps, Copilot answer regression, Direct Lake readiness, data-product SLOs, capacity-change proof, and executive decision traces, use the [next-generation USP pack](docs/next-gen-usps.md).

## Install

Use the plugin from this repository by pointing Codex at `plugins/powerbi-desktop`.
Generated review outputs are intentionally ignored by Git; rerun the scripts below to recreate them locally.

New here? Start with [First 10 minutes](docs/start-here.md). Use the [documentation index](docs/index.md) only when you need a deeper workflow or reference.

## First 10 Minutes

1. Ask Codex one of the role-based questions above, or run the local review below.
2. Read the generated index and act on the three highest-priority findings.
3. If a change is needed, work in PBIP/TMDL and generate a draft before applying it.

For a local, no-login first pass:

```powershell
.\plugins\powerbi-desktop\scripts\Invoke-PowerBIAutoReview.ps1 -Path .\your-model -OutputDirectory .\powerbi-auto-review
```

This produces local evidence only. It neither changes the model nor accesses Fabric.

## What It Adds

- A `powerbi-desktop` skill for PBIX/PBIT/PBIP, DAX, Power Query, and semantic model work.
- A local inventory script for Power BI file discovery.
- A local environment check script for Power BI Desktop, Tabular Editor, DAX Studio, pbi-tools, and .NET.
- A model summary script for text-based Power BI assets such as TMDL, DAX, Power Query, and `model.bim`.
- An insight scan that scores report inspectability, source-control readiness, DAX risk patterns, and Power Query dependencies.
- A metric catalog generator that turns measures into a semantic contract starter.
- A refactoring plan generator that turns scan findings into phased work.
- A report blueprint generator that turns metrics into a page-level UX plan.
- A DAX dependency graph generator for impact analysis.
- An AI prompt pack generator with `context-pack.json` and focused review/refactor/narrative prompts.
- A deterministic executive narrative generator for report-owner communication.
- Configurable DAX and Power Query governance rules.
- PBIP/TMDL/report metadata readiness scoring.
- A one-command auto-review orchestrator.
- Live read-only access helpers for the currently open Power BI Desktop model via the local XMLA/ADOMD endpoint.
- Live DAX query validation, metadata governance checks, fix backlogs, DAX fix drafts, and refactor suggestions.
- Innovation review package with guided fixes, semantic diff support, measure lineage impact, generated DAX test plans, performance advice, report UX critique, executive explainability, governance scorecards, Copilot readiness, and release checklists.
- Trust and release assistant with business semantic layers, KPI trust scores, decision-risk analysis, flight-recorder history, before/after behavior comparison, narrative critique, Copilot optimization, DAX fix simulation, visual-to-measure impact mapping, and Go/Warn/No-Go release gates.
- Safe PBIP/TMDL authoring drafts for new measures and calculated columns.
- Safe PBIP report page and visual drafts, with optional PBIP report-page file generation and PBIP-to-PBIX compile workflow guidance.
- Model best-practice checks driven by configurable trust rules.
- Native tool-parity layer for BPA rules, model compare, model documentation, DAX performance heuristics, report layout checks, theme audit, and PBIP source-control planning.
- Real-feature layer for visual schema checks, render-readiness, live DAX benchmarks, live DMV/VertiPaq-style analysis, calculation groups, relationships, RLS roles, Power Query drafts, service planning, incremental refresh, aggregations, and schema-aware visual planning.
- PBIP Apply Engine for measure, calculated column, Power Query, generic TMDL, and report-page drafts with manifests and rollback guidance.
- Unified review runner that combines offline project review, live Desktop review when available, and External Tools registration in one index.
- Power BI External Tools registration generator for a `Codex Power BI Workbench` `.pbitool.json`.
- Golden baseline tests for sample-model semantic regression checks.
- AI engineering workflows for autonomous PBIP fix plans, live-vs-repo reconciliation, measure expectations, PR release comments, KPI trust contracts, local model Q&A, and Fabric readiness.
- Max AI review with 39 artifacts across 38 USP workflows: fix-until-green, Copilot evaluator, data contracts, Fabric deployment risk, visual intent, root-cause graph, KPI trust twin, review memory, natural-language PBIP authoring, governance rule mining, explainable DAX refactoring, report decision simulation, trust debt ledger, KPI incident recorder, RLS leakage checks, Fabric capacity risk forecast, semantic duplicate detection, forecast exception board, usage-vs-trust prioritization, PBIP rollback readiness, agentic remediation prioritization, business outcome simulation, semantic layer autopilot, AI governance evidence, human override learning, cross-report KPI conflict detection, executive narrative quality, autonomous QA lab, PBIP change impact gate, semantic test fixtures, KPI owner sign-off, refresh blast radius, sensitive data exposure, capacity mitigation, report retirement, live validation evidence, semantic contract drift, and RLS persona coverage.
- Enterprise AI release engineering with Fabric workspace inventory planning, service scanner, gated TOM/TMSL write plans, layout auto-fix plans, semantic test runner, measure behavior diff, live safety layer, live-vs-repo drift, PBIP roundtrip validation, enterprise governance packs, report/visual intelligence, guided fix loops, performance trace import, VertiPaq import, screenshot UX review, AI change journal, model risk heatmap, and one-command release candidate pack.
- Analytical release QA with methodology validation, metric change diagnosis, and stakeholder-ready analytical release reports built from local Power BI evidence.
- Advanced Power BI release USPs with evidence graphs, visual-to-measure impact, semantic contract testing, executive trust briefs, DAX change risk, freshness/lineage gates, KPI drift watchlists, RLS trust review, UX regression scanning, and migration readiness.
- Separated portfolio governance, compliance QA, and operations QA packs for portfolio command centers, deployment gates, certification readiness, cost-to-trust optimization, tenant hygiene, KPI conflict resolution, accessibility, Power Query contracts, refresh root cause, semantic coverage, release signatures, and KPI SLAs.
- Fabric Live Read-Only + Snapshot Intelligence with token-file access plans, workspace/tenant snapshots, Fabric portfolio, deployment, operations, governance, security, and executive evidence packs.
- Feature maturity map that separates implemented, live-read, snapshot-backed, draft/apply, metadata-only, synthetic, and heuristic-simulation capabilities.
- Business Process Data Quality packs for local Power BI and ERP export checks across Order-to-Cash, Procure-to-Pay, Record-to-Report, Hire-to-Retire, Plan-to-Produce, Forecast-to-Deliver, and extensible process rule packs.
- Optional external-tool awareness for Tabular Editor, DAX Studio, ALM Toolkit, Power BI Helper, Model Documenter, PBI.tips tools, and pbi-tools validation workflows.
- A theme generator for governed report styling.
- A review prompt template for high-signal Codex report reviews.
- Marketplace metadata for installing the plugin from this repo.

## Quick Checks

Do not run every command below. Pick the workflow that matches your goal in [First 10 minutes](docs/start-here.md). The commands below are maintainer and release checks.

```powershell
.\plugins\powerbi-desktop\scripts\Resolve-PowerBILiveTarget.ps1
.\plugins\powerbi-desktop\scripts\New-PowerBILiveSafetyPlan.ps1
.\plugins\powerbi-desktop\scripts\Invoke-PowerBISemanticTestRunner.ps1 -Path .\plugins\powerbi-desktop\examples\sample-model -FailOnPending
.\plugins\powerbi-desktop\scripts\Compare-PowerBIMeasureBehavior.ps1 -Path .\plugins\powerbi-desktop\examples\sample-model
.\plugins\powerbi-desktop\scripts\New-PowerBIReleaseCandidatePack.ps1 -Path .\plugins\powerbi-desktop\examples\sample-model -OutputDirectory .\powerbi-release-candidate
.\plugins\powerbi-desktop\scripts\New-PowerBIReleaseCandidatePack.ps1 -Path .\plugins\powerbi-desktop\examples\sample-model -OutputDirectory .\powerbi-release-candidate -IncludeAnalyticalQa
.\plugins\powerbi-desktop\scripts\New-PowerBIReleaseCandidatePack.ps1 -Path .\plugins\powerbi-desktop\examples\sample-model -OutputDirectory .\powerbi-release-candidate -IncludeAdvancedUspQa
.\plugins\powerbi-desktop\scripts\New-PowerBIReleaseCandidatePack.ps1 -Path .\plugins\powerbi-desktop\examples\sample-model -OutputDirectory .\powerbi-release-candidate -IncludePortfolioGovernanceQa -IncludeComplianceQa -IncludeOperationsQa
.\plugins\powerbi-desktop\scripts\New-PowerBIReleaseCandidatePack.ps1 -Path .\plugins\powerbi-desktop\examples\sample-model -OutputDirectory .\powerbi-release-candidate -IncludeFabricLiveQa -IncludeFabricPortfolioQa -IncludeFabricDeploymentQa -IncludeFabricOperationsQa -IncludeFabricGovernanceQa -IncludeFabricExecutiveQa -SnapshotDirectory .\plugins\powerbi-desktop\examples\fabric-snapshot\minimal
.\plugins\powerbi-desktop\scripts\New-PowerBIFeatureMaturityMap.ps1 -OutputPath .\powerbi-feature-maturity.md
.\plugins\powerbi-desktop\scripts\Invoke-PowerBIBusinessProcessDataQuality.ps1 -Path .\plugins\powerbi-desktop\examples\sample-model -DataPath .\plugins\powerbi-desktop\examples\business-process-data -OutputDirectory .\powerbi-business-process-dq
.\plugins\powerbi-desktop\scripts\New-PowerBIVisualIntentAnalyzer.ps1 -Path .\plugins\powerbi-desktop\examples\sample-model -OutputPath .\powerbi-visual-intent.md
.\plugins\powerbi-desktop\scripts\Test-PowerBIEnvironment.ps1
.\plugins\powerbi-desktop\scripts\Invoke-PowerBIUnifiedReview.ps1 -Path .\plugins\powerbi-desktop\examples\sample-model -OutputDirectory .\powerbi-unified-review
.\plugins\powerbi-desktop\scripts\Test-PowerBIGoldenBaselines.ps1
.\plugins\powerbi-desktop\scripts\Invoke-PowerBIMaxAIReview.ps1 -Path .\plugins\powerbi-desktop\examples\sample-model -OutputDirectory .\powerbi-max-ai-review
.\plugins\powerbi-desktop\tests\Run-PowerBITests.ps1
```

The plugin intentionally avoids direct binary PBIX editing. Export to PBIP/TMDL or another text-based format before asking Codex to make model or report changes.

## Development

Run the test suite before publishing changes:

```powershell
.\plugins\powerbi-desktop\tests\Run-PowerBITests.ps1
```

The GitHub Actions workflow runs the same test entrypoint plus Pester tests from `plugins/powerbi-desktop/tests/pester`.

## Privacy

The plugin works against local files, the local Power BI Desktop XMLA/ADOMD endpoint, and optional user-supplied Fabric snapshots. Fabric live v1 is token-file and GET-only. It does not publish reports, perform implicit sign-in, promote content, trigger refreshes, rebind, delete, endorse, refresh credentials, or upload model data by itself.

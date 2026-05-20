# Value Proposition And USPs

This plugin turns Codex into a local Power BI engineering workbench for teams that need safer model changes, stronger governance evidence, and faster review cycles without uploading PBIX files or report data.

## Executive Summary

Power BI teams often lose time because model quality, DAX risk, report UX, release readiness, and Fabric planning are checked with separate tools and manual review habits. This plugin brings those checks into one local workflow:

- Review PBIP, TMDL, DAX, Power Query, report metadata, and live Desktop models from one command surface.
- Generate release evidence that explains what is safe, what is risky, and what still needs human sign-off.
- Create guarded PBIP/TMDL drafts instead of editing binary PBIX files directly.
- Combine technical model analysis with business-facing trust, governance, and decision-risk outputs.
- Keep execution local by default, with explicit gates before service, Fabric, or write-oriented operations.

## Core Benefits

| Benefit | What It Means | Typical Output |
| --- | --- | --- |
| Faster review cycles | A report owner can produce a review package without manually stitching together model, DAX, governance, and UX checks. | Unified review, Max AI review, release candidate pack |
| Safer changes | Write actions are planned as drafts, manifests, rollback checks, and apply plans instead of direct PBIX mutation. | PBIP Apply Engine outputs, TOM write plans, rollback readiness |
| Better release decisions | Go/Warn/No-Go evidence is generated from trust rules, semantic tests, live availability, and governance signals. | Trust release gate, release checklist, PR release comment |
| Higher KPI trust | Metrics are evaluated for ownership, definitions, DAX risk, lineage impact, duplicate semantics, tests, and usage. | KPI trust score, trust debt ledger, usage trust matrix |
| Live Desktop confidence | Open Desktop models can be inspected through read-only local XMLA/ADOMD checks when available. | Live model summary, live metric catalog, live-vs-repo drift |
| Fabric readiness | Teams can plan deployment and capacity risk before treating a model as service-ready. | Fabric readiness plan, service scanner, capacity risk forecast |
| AI-ready semantics | Copilot and AI workflows get better model metadata, contracts, prompt packs, and semantic test coverage. | Copilot readiness, data contracts, AI prompt pack |

## Differentiating USPs

## 38 AI/KI USP Map

| USP | Business Value | Output Artifact | Best User |
| --- | --- | --- | --- |
| Fix-until-green loop | Turns failed checks into repeatable remediation cycles. | `fix-until-green.md` | BI developer |
| Copilot evaluator | Shows whether the model is ready for natural-language use. | `semantic-copilot-evaluator.md` | AI enablement lead |
| Data contracts | Makes KPI ownership, assumptions, and validation explicit. | `data-contract.md` | Data owner |
| Fabric deployment risk | Identifies release and tenant-readiness risks early. | `fabric-deployment-risk.md` | Fabric architect |
| Visual intent analysis | Checks whether visuals answer the intended business question. | `visual-intent.md` | Report owner |
| Root-cause graph | Explains likely causes behind risky measures. | `root-cause-graph.md` | BI developer |
| KPI trust twin | Creates machine-readable trust evidence for KPIs. | `kpi-trust-twin.json` | Governance team |
| Review memory | Tracks repeated findings and local review history. | `review-memory.json` | BI lead |
| Natural-language PBIP authoring | Converts business intent into guarded PBIP draft instructions. | `natural-language-authoring.json` | Report builder |
| Governance rule mining | Turns repeated findings into rule candidates. | `governance-rule-miner.md` | Governance team |
| Explainable DAX refactoring | Proposes DAX refactors with rationale and validation notes. | `explainable-dax-refactoring.md` | BI developer |
| Report decision simulation | Shows how report issues can affect decisions. | `report-decision-simulator.md` | Executive stakeholder |
| Trust debt ledger | Converts low trust into owner/SLA-style remediation work. | `trust-debt-ledger.json` | BI lead |
| KPI incident recorder | Creates incident evidence and rollback guidance for broken KPIs. | `kpi-incident-report.json` | Support owner |
| RLS leakage simulator | Drafts RLS validation queries and release impact. | `rls-leakage.json` | Security reviewer |
| Fabric capacity risk | Forecasts capacity, refresh, and query risks. | `fabric-capacity-risk.json` | Fabric architect |
| Semantic duplicate merger | Finds duplicate KPI candidates and canonical options. | `metric-duplicates.json` | Semantic model owner |
| Forecast exception board | Turns forecast gaps into owner-linked cases. | `forecast-exception-board.json` | Revenue leader |
| Usage-vs-trust scanner | Prioritizes high-usage, low-trust remediation. | `usage-trust-matrix.json` | Governance team |
| PBIP rollback gate | Checks whether PBIP changes are rehearsable. | `pbip-rollback-readiness.json` | Release owner |
| Agentic remediation prioritization | Ranks the next fixes by release impact and evidence strength. | `agentic-remediation-plan.json` | BI lead |
| Business outcome simulation | Connects KPI trust to possible business decision errors. | `business-outcome-simulation.json` | Executive stakeholder |
| Semantic layer autopilot | Improves names, descriptions, synonyms, contracts, and Copilot readiness. | `semantic-layer-autopilot.json` | Semantic model owner |
| AI governance evidence pack | Packages AI suggestions, sign-off gaps, residual risk, and release evidence. | `ai-governance-evidence-pack/summary.json` | Audit/compliance |
| Human override learning | Learns from accepted/rejected AI recommendations and forecast overrides. | `human-override-learning.json` | Planning owner |
| Cross-report KPI conflict detection | Finds conflicting KPI definitions across reports. | `cross-report-kpi-conflicts.json` | Enterprise BI owner |
| Executive narrative quality agent | Checks whether executive claims are supported by data and release evidence. | `executive-narrative-quality.json` | Executive report owner |
| Autonomous QA Lab | Generates QA questions, semantic checks, visual readiness, and regression risk. | `autonomous-qa-lab/summary.json` | QA/release owner |
| PBIP change impact gate | Turns changed PBIP/TMDL/report files into release impact evidence. | `pbip-change-impact-gate.json` | Release owner |
| Semantic test fixture generator | Creates deterministic measure expectation fixtures for KPI validation. | `semantic-test-fixtures/measure-expectations.json` | QA engineer |
| KPI owner sign-off workflow | Creates owner-linked sign-off items from trust, contract, and incident evidence. | `kpi-owner-signoff.json` | Data owner |
| Refresh blast-radius analyzer | Shows which KPIs are exposed by refresh, capacity, or service degradation. | `refresh-blast-radius.json` | Fabric operator |
| Sensitive data exposure map | Flags sensitive model/report references and review actions. | `sensitive-data-exposure.json` | Security reviewer |
| Capacity mitigation planner | Converts capacity and performance risks into mitigation work. | `capacity-mitigation-plan.json` | Fabric architect |
| Report retirement advisor | Identifies retirement, merge, and review candidates from usage and trust evidence. | `report-retirement-advisor.json` | BI portfolio owner |
| Live validation evidence recorder | Packages live Desktop validation evidence for audit and release review. | `live-validation-evidence/summary.json` | Release owner |
| Semantic contract drift monitor | Detects stale ownership, missing contracts, and expectation drift. | `semantic-contract-drift.json` | Semantic model owner |
| RLS persona coverage matrix | Maps role/persona coverage to report and KPI impact. | `rls-persona-coverage.json` | Security reviewer |

### 1. Local-First Power BI AI Review

The plugin is designed around local files and the local Power BI Desktop endpoint. It does not require uploading report content to a SaaS review tool before producing useful evidence.

Use it when data sensitivity, regulated environments, or enterprise review policies make local-first workflows important.

### 2. Unified Review Across Offline And Live Models

Most review workflows look either at exported files or at a running model. This plugin combines both:

- Offline PBIP/TMDL/model metadata review.
- Optional live Desktop DMV and DAX checks.
- Live-vs-repo reconciliation so teams can see whether Desktop and source control differ.
- Explicit `LiveUnavailable`, `NoDrift`, and `DriftDetected` status instead of ambiguous pass/fail claims.

### 3. Trust-Centered Release Gates

The release workflow is not just a test runner. It translates model and governance evidence into business-facing release status:

- KPI trust scoring.
- Trust debt ledger.
- Semantic test coverage.
- Governance policy pack.
- PR-ready release notes.
- Go/Warn/No-Go gates.

### 4. Guarded PBIP/TMDL Authoring

The plugin avoids unsafe binary PBIX editing. It generates drafts and apply plans for text-based Power BI assets:

- Measures and calculated columns.
- Power Query drafts.
- Generic TMDL drafts.
- Report page and visual drafts.
- Apply manifests and rollback guidance.

This makes Codex useful for implementation work while keeping human review and source control in the loop.

### 5. Max AI Review Package

The Max AI workflow produces a broad AI/KI review package that goes beyond basic linting:

- Fix-until-green plans.
- Data contracts.
- Copilot evaluator.
- Root-cause graph.
- KPI trust twin.
- Natural-language PBIP authoring.
- Governance rule mining.
- Explainable DAX refactoring.
- Report decision simulation.
- KPI incident recorder.
- Forecast exception board.
- Usage-vs-trust prioritization.

### 6. Enterprise AI Release Engineering

The plugin includes enterprise-oriented release artifacts that help teams move from ad hoc review to repeatable release operations:

- Release candidate pack.
- Model risk heatmap.
- Service scanner.
- Fabric workspace inventory planning.
- Performance trace and VertiPaq imports.
- Screenshot UX review.
- AI change journal.
- Documentation coverage gate.

### 7. Forecast And Planning Intelligence

The AI forecast workflow supports read-only forecast generation from live Desktop or saved extracts, including:

- Actual-to-date reconciliation.
- Backlog conversion.
- Residual demand estimation.
- Budget and roll anchors.
- Sparse-series fallback.
- Backtesting and model-quality outputs.
- Forecast exception boards for ownership and action tracking.

## Best-Fit Use Cases

| User | Best Starting Workflow |
| --- | --- |
| Report owner | `Invoke-PowerBIUnifiedReview.ps1` to understand model, report, and release risk. |
| BI developer | PBIP draft/apply workflows for safer measures, TMDL, Power Query, pages, and visuals. |
| Power BI lead | `New-PowerBIReleaseCandidatePack.ps1` and trust gates for release decisions. |
| Governance team | Policy packs, service scanner, trust debt ledger, and golden baselines. |
| Fabric architect | Fabric readiness, deployment risk, service integration, and capacity risk planning. |
| Executive stakeholder | Executive narrative, KPI incident report, trust matrix, and forecast exception board. |

## Positioning Statement

Use this plugin when Power BI work needs to be more than report editing: it provides a local, reviewable, source-control-friendly engineering layer for model quality, AI readiness, governance evidence, release decisions, and safe PBIP/TMDL authoring.

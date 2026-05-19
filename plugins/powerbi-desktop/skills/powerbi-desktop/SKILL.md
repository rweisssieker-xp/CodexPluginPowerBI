---
name: powerbi-desktop
description: Use when working with Microsoft Power BI Desktop files or projects, including PBIX/PBIT inventory, DAX and Power Query review, semantic model documentation, Tabular Editor workflows, and local Desktop environment checks.
---

# Power BI Desktop

Use this skill when the user asks Codex to inspect, document, generate, or refactor Power BI Desktop assets.

## Boundaries

- Treat `.pbix` and `.pbit` files as package files. Do not modify them directly unless the user has exported a supported editable project format or provides explicit tooling.
- Prefer Power BI Project folders (`.pbip`), Tabular Model Definition Language (`.tmdl`), `model.bim`, Power Query `.pq`, DAX `.dax`, JSON metadata, and exported text over binary PBIX edits.
- Before editing, identify whether the workspace contains a PBIP folder, extracted metadata, or only binary PBIX/PBIT files.
- Do not publish to Power BI Service, sign in, refresh credentials, or overwrite reports unless the user explicitly asks and the required CLI/tooling is available.

## First Checks

1. Inventory the workspace with `scripts/Get-PowerBIInventory.ps1`.
2. Check local Desktop/tooling availability with `scripts/Test-PowerBIEnvironment.ps1`.
3. If Power BI Desktop is open, detect the live model with `scripts/Get-PowerBIDesktopLiveConnection.ps1`.
4. Analyze PBIP structure with `scripts/Get-PowerBIPBIPStructure.ps1`.
5. For full AI/KI review, run `scripts/Invoke-PowerBIAutoReview.ps1`.
6. Run an insight scan with `scripts/Invoke-PowerBIInsightScan.ps1`.
7. Generate a metric catalog with `scripts/New-PowerBIMetricCatalog.ps1` when DAX files are available.
8. Generate a dependency graph with `scripts/New-PowerBIDependencyGraph.ps1` when measures exist.
9. Generate an AI prompt pack with `scripts/New-PowerBIAIPromptPack.ps1` for deeper Codex/LLM review.
10. Generate a refactoring plan with `scripts/New-PowerBIRefactorPlan.ps1` when findings exist.
11. Generate a report blueprint with `scripts/New-PowerBIReportBlueprint.ps1` when measures exist.
12. If text-based model files exist, summarize them with `scripts/New-PowerBIModelSummary.ps1`.
13. For advanced remediation, run `scripts/Invoke-PowerBIInnovationReview.ps1`.
14. For safe authoring, generate drafts with `scripts/New-PowerBIMeasureDraft.ps1` or `scripts/New-PowerBICalculatedColumnDraft.ps1`.
15. For report authoring, create PBIP page/visual drafts with `scripts/Add-PowerBIPBIPReportPage.ps1`.
16. For native external-tool-style capabilities, run `scripts/Invoke-PowerBINativeToolParityReview.ps1`.
17. For real feature coverage, run `scripts/Invoke-PowerBIRealFeatureReview.ps1`.
18. For applying PBIP-safe drafts, use `scripts/Apply-PowerBIPBIPMeasureDraft.ps1`, `scripts/Apply-PowerBIPBIPCalculatedColumnDraft.ps1`, `scripts/Apply-PowerBIPBIPPowerQueryDraft.ps1`, or `scripts/Apply-PowerBIPBIPTmdlDraft.ps1`.
19. For optional external tool validation workflows, run `scripts/Invoke-PowerBIExternalToolsReview.ps1`.
20. For a single productized pass, run `scripts/Invoke-PowerBIUnifiedReview.ps1`.
21. For Power BI External Tools menu integration, generate a `.pbitool.json` with `scripts/New-PowerBIExternalToolRegistration.ps1`, or install/uninstall with `scripts/Install-PowerBIExternalTool.ps1` and `scripts/Uninstall-PowerBIExternalTool.ps1`.
22. Before publishing plugin changes, run `scripts\Test-PowerBIGoldenBaselines.ps1`.
23. For maximum AI/KI workflows, use `scripts/Invoke-PowerBIAutonomousFixAgent.ps1`, `scripts/Compare-PowerBILiveRepoModel.ps1`, `scripts/New-PowerBIKpiTrustContract.ps1`, `scripts/Invoke-PowerBIAskModel.ps1`, and `scripts/New-PowerBIFabricReadinessPlan.ps1`.
24. For the complete 12-USP AI/KI package, run `scripts/Invoke-PowerBIMaxAIReview.ps1`.
25. For enterprise release engineering, run `scripts/New-PowerBIReleaseCandidatePack.ps1`, `scripts/New-PowerBIServiceScanner.ps1`, `scripts/New-PowerBIModelRiskHeatmap.ps1`, `scripts/Invoke-PowerBISemanticTestRunner.ps1`, and `scripts/New-PowerBITomWritePlan.ps1`.
26. For disruptive autonomous planning workflows, use the dedicated skills `powerbi-autonomous-planning-loop`, `powerbi-goal-seeking-planning`, `powerbi-constraint-aware-planning`, `powerbi-autonomous-forecast-agents`, `powerbi-autonomous-exception-management`, `powerbi-revenue-rescue-mode`, `powerbi-forecast-trust-market`, `powerbi-causal-counterfactual-forecasting`, `powerbi-self-healing-forecast-governance`, `powerbi-planning-memory`, `powerbi-planning-readiness-score`, and `powerbi-forecast-war-room`.
27. Look for these editable artifacts:
   - `*.pbip`
   - `*.SemanticModel`, `*.Report`
   - `definition.pbism`, `model.bim`
   - `*.tmdl`, `*.dax`, `*.pq`
   - `DiagramLayout`, `report.json`, `pages.json`

## Common Workflows

### Inventory reports

Run:

```powershell
.\plugins\powerbi-desktop\scripts\Get-PowerBIInventory.ps1 -Path .
```

Summarize report files, sizes, modification dates, and editable metadata candidates. If only PBIX/PBIT files exist, explain that binary-safe inspection is limited.

### Document a model

- Prefer TMDL or `model.bim` as source.
- Extract tables, columns, measures, relationships, partitions, calculation groups, roles, and data sources.
- Keep DAX and M code in fenced code blocks when reporting findings.
- Flag measures with ambiguous names, hidden dependencies, hard-coded dates, repeated filter logic, or suspicious inactive relationship usage.

Run:

```powershell
.\plugins\powerbi-desktop\scripts\New-PowerBIModelSummary.ps1 -Path . -OutputPath .\powerbi-model-summary.md
```

Use the generated markdown as a first-pass map. Verify important business logic against the source files before making recommendations.

### Run an insight scan

Run:

```powershell
.\plugins\powerbi-desktop\scripts\Invoke-PowerBIInsightScan.ps1 -Path . -OutputPath .\powerbi-insight-scan.md
```

Use this as the default "innovative" entry point. It combines file discovery, DAX risk heuristics, Power Query dependency checks, source-control readiness, and recommended next actions. Treat findings as triage signals, not proof of defects.

### Run the full AI review package

Run:

```powershell
.\plugins\powerbi-desktop\scripts\Invoke-PowerBIAutoReview.ps1 -Path . -OutputDirectory .\powerbi-auto-review
```

Use this as the fastest end-to-end path. It produces inventory, PBIP readiness, scan, metric catalog, dependency graph, refactor plan, report blueprint, model summary, executive narrative, AI prompt pack, and innovation review artifacts.

### Run the unified product review

Run:

```powershell
.\plugins\powerbi-desktop\scripts\Invoke-PowerBIUnifiedReview.ps1 -Path . -OutputDirectory .\powerbi-unified-review
```

Use this when the user wants the complete productized workflow. It runs the offline auto-review, attempts the live Desktop review when a local endpoint is available, generates the External Tools registration file, and writes a single index plus machine-readable summary.

### Run the innovation review package

Run:

```powershell
.\plugins\powerbi-desktop\scripts\Invoke-PowerBIInnovationReview.ps1 -Path . -OutputDirectory .\powerbi-innovation-review
```

Use this when the user wants actionable next-generation review artifacts. It produces a guided fix plan, semantic remediation guidance, measure lineage impact, generated DAX test plan, performance advisor, report UX critique, executive explainability pack, governance scorecard, Copilot readiness check, release checklist, business semantic layer, KPI trust score, decision-risk assistant, DAX fix simulation, visual-to-measure impact map, and trust release gate.

### Run maximum AI/KI engineering workflows

Run:

```powershell
.\plugins\powerbi-desktop\scripts\Invoke-PowerBIAutonomousFixAgent.ps1 -Path . -OutputPath .\powerbi-autonomous-fix-agent.md
.\plugins\powerbi-desktop\scripts\Compare-PowerBILiveRepoModel.ps1 -Path . -OutputPath .\powerbi-live-repo-reconciliation.md
.\plugins\powerbi-desktop\scripts\Test-PowerBIMeasureExpectations.ps1 -Path .
.\plugins\powerbi-desktop\scripts\New-PowerBIPRReleaseComment.ps1 -Path . -OutputPath .\powerbi-pr-comment.md
.\plugins\powerbi-desktop\scripts\New-PowerBIKpiTrustContract.ps1 -Path . -OutputPath .\powerbi-kpi-trust-contract.md
.\plugins\powerbi-desktop\scripts\Invoke-PowerBIAskModel.ps1 -Path . -Question "Which KPIs block release?"
.\plugins\powerbi-desktop\scripts\New-PowerBIFabricReadinessPlan.ps1 -Path . -OutputPath .\powerbi-fabric-readiness.md
.\plugins\powerbi-desktop\scripts\Invoke-PowerBIMaxAIReview.ps1 -Path . -OutputDirectory .\powerbi-max-ai-review
```

These commands turn review results into Codex-native engineering artifacts: fix loop plans, live/source-control drift, semantic test expectations, PR comments, KPI trust contracts, local model Q&A, and Fabric deployment readiness. They do not sign in to Fabric or publish content.

### Run enterprise release engineering

Run:

```powershell
.\plugins\powerbi-desktop\scripts\New-PowerBIReleaseCandidatePack.ps1 -Path . -OutputDirectory .\powerbi-release-candidate-pack -SkipLive
.\plugins\powerbi-desktop\scripts\New-PowerBIServiceScanner.ps1 -Path . -WorkspaceName "Target Workspace" -OutputPath .\powerbi-service-scanner.md
.\plugins\powerbi-desktop\scripts\New-PowerBIModelRiskHeatmap.ps1 -Path . -OutputPath .\powerbi-model-risk-heatmap.md
.\plugins\powerbi-desktop\scripts\Invoke-PowerBISemanticTestRunner.ps1 -Path . -OutputPath .\powerbi-semantic-tests.md
.\plugins\powerbi-desktop\scripts\New-PowerBITomWritePlan.ps1 -Operation AddMeasure -TableName Sales -ObjectName "Average Sales" -Expression "DIVIDE([Total Sales], COUNTROWS('Sales'))"
```

Use this when the user wants the strongest Power BI/Fabric engineering workflow. The release candidate pack combines unified review, Max AI review, service scanner, semantic tests, model risk heatmap, and PR release comment. Fabric REST and TOM/TMSL writes stay explicit and gated; do not sign in, publish, or mutate a model unless the user explicitly asks and provides the required endpoint/token/write confirmation.

### Decide whether a report is release-ready

Run:

```powershell
.\plugins\powerbi-desktop\scripts\New-PowerBITrustReleaseGate.ps1 -Path . -OutputPath .\powerbi-trust-release-gate.md
```

Use this for the plugin's differentiating trust workflow. It returns a Go/Warn/No-Go decision based on KPI trust score, unresolved P0 fixes, governance score, Copilot readiness, and low-trust KPI count.

### Draft new measures or calculated columns

Run:

```powershell
.\plugins\powerbi-desktop\scripts\New-PowerBIMeasureDraft.ps1 -TableName Sales -MeasureName "Average Sales" -Expression "DIVIDE([Total Sales], COUNTROWS('Sales'))"
.\plugins\powerbi-desktop\scripts\New-PowerBICalculatedColumnDraft.ps1 -TableName Sales -ColumnName "Sales Bucket" -Expression "IF('Sales'[Sales Amount] > 1000, ""High"", ""Standard"")"
```

These commands create TMDL/PBIP-safe drafts and validation guidance. They do not write directly into binary PBIX/PBIT files. Prefer measures for aggregations and calculated columns only when Power Query or source-system columns are not appropriate.

### Draft PBIP pages and visuals

Run:

```powershell
.\plugins\powerbi-desktop\scripts\New-PowerBIReportPageDraft.ps1 -PageName "Executive Overview" -Measures "Total Sales","Sales YoY %"
.\plugins\powerbi-desktop\scripts\Add-PowerBIPBIPReportPage.ps1 -PbipPath .\MyReport -PageName "Executive Overview" -Measures "Total Sales","Sales YoY %" -Apply
.\plugins\powerbi-desktop\scripts\New-PowerBIPBIXCompileWorkflow.ps1 -PbipPath .\MyReport -OutputPbix .\MyReport.pbix
```

Use this only for PBIP/report JSON workflows. Validate the generated page in Power BI Desktop before saving back to PBIX. If `pbi-tools` is installed, the compile workflow emits a compile command; otherwise use Power BI Desktop Save As PBIX.

### Check model best practices

Run:

```powershell
.\plugins\powerbi-desktop\scripts\Test-PowerBIModelBestPractices.ps1 -Path . -OutputPath .\powerbi-model-best-practices.md
```

Use this to evaluate metric ownership, business definitions, PBIP readiness, deterministic DAX, and performance patterns. Trust and best-practice thresholds are configurable in `rules/powerbi-trust-rules.json`.

### Run native tool-parity capabilities

Run:

```powershell
.\plugins\powerbi-desktop\scripts\Invoke-PowerBINativeToolParityReview.ps1 -Path . -OutputDirectory .\powerbi-native-tool-parity
```

Use this before relying on external tools. It implements native BPA, model compare/documentation, DAX performance heuristics, report layout checks, theme audit, and PBIP source-control planning from local text/live metadata where available.

### Run real feature coverage

Run:

```powershell
.\plugins\powerbi-desktop\scripts\Invoke-PowerBIRealFeatureReview.ps1 -Path . -OutputDirectory .\powerbi-real-feature-review
```

Use this for the real Power BI feature layer: visual schema checks, render-readiness, live DAX benchmark timing, live DMV/VertiPaq-style analysis, calculation group drafts, relationship drafts, RLS role drafts, Power Query/M drafts, service integration planning, incremental refresh drafts, aggregation drafts, and schema-aware visual planning.

### Apply PBIP-safe drafts

Run:

```powershell
.\plugins\powerbi-desktop\scripts\Apply-PowerBIPBIPMeasureDraft.ps1 -PbipPath .\MyReport -TableName Sales -MeasureName "Average Sales" -Expression "DIVIDE([Total Sales], COUNTROWS('Sales'))" -Apply
.\plugins\powerbi-desktop\scripts\Apply-PowerBIPBIPPowerQueryDraft.ps1 -PbipPath .\MyReport -QueryName DimDate -SourceKind DateTable -Apply
.\plugins\powerbi-desktop\scripts\Invoke-PowerBIPBIPApplyPlan.ps1 -PbipPath .\MyReport
```

These scripts write draft artifacts under PBIP folders, maintain a draft manifest where applicable, and include rollback guidance. Validate in Power BI Desktop before saving back to PBIX.

### Use optional external Power BI validation tools

Run:

```powershell
.\plugins\powerbi-desktop\scripts\Get-PowerBIExternalToolInventory.ps1
.\plugins\powerbi-desktop\scripts\Invoke-PowerBIExternalToolsReview.ps1 -Path . -OutputDirectory .\powerbi-external-tools-review
```

Use this to detect Tabular Editor, DAX Studio, ALM Toolkit, Power BI Helper, Model Documenter, PBI.tips tools, and pbi-tools. The plugin's core capabilities are native; external tools are optional validation paths for engine-specific traces, BPA rule packs, or deployment compare scenarios.

### Register as a Power BI External Tool

Run:

```powershell
.\plugins\powerbi-desktop\scripts\New-PowerBIExternalToolRegistration.ps1 -OutputPath .\CodexPowerBIWorkbench.pbitool.json
.\plugins\powerbi-desktop\scripts\Install-PowerBIExternalTool.ps1
.\plugins\powerbi-desktop\scripts\Uninstall-PowerBIExternalTool.ps1
```

Use `-Install` only when the user explicitly wants to write into the machine-wide Power BI Desktop External Tools folder. Power BI Desktop should be restarted after installation.

### Inspect the open Desktop model

Run:

```powershell
.\plugins\powerbi-desktop\scripts\Get-PowerBIDesktopLiveConnection.ps1
.\plugins\powerbi-desktop\scripts\Get-PowerBILiveModelSummary.ps1 -OutputPath .\powerbi-live-model-summary.md
.\plugins\powerbi-desktop\scripts\Invoke-PowerBILiveAutoReview.ps1 -OutputDirectory .\powerbi-live-auto-review
```

This reads the local Analysis Services endpoint created by Power BI Desktop. It can inspect metadata and DMV output from the currently open model when Desktop is running. The live auto-review also creates measure validation, metadata governance, refactor suggestions, prioritized fix backlogs, and DAX fix drafts. Do not use it to modify or publish the report unless the user explicitly asks and a supported write path is available.

### Generate an AI/KI sales forecast

Run:

```powershell
.\plugins\powerbi-desktop\scripts\Invoke-PowerBIAIForecast.ps1 -OutputDirectory .\powerbi-ai-forecast -HorizonMonths 3 -Grain CustomerProduct -Backtest
```

Use this as a read-only forecast workflow from the open Desktop model. It exports live customer/product monthly data when feasible, falls back to customer-hierarchy/product-line if Desktop cannot materialize the fine grain, blends learned backlog conversion, residual demand, seasonality, budget, roll forecast, and sparse-series shrinkage, then writes detail, summary, top-delta, backtest, and model-quality CSV outputs. Import the output as a separate forecast table before drafting DAX measures.

For innovation beyond a static forecast, route the request to the focused autonomous planning skills:

- `powerbi-autonomous-planning-loop`: closed-loop observe, forecast, detect, simulate, decide, act, learn, repeat.
- `powerbi-goal-seeking-planning`: reverse planning from budget, roll, margin, cash, or management targets.
- `powerbi-constraint-aware-planning`: delivery, capacity, stock, margin, cash, and sales-resource constraints.
- `powerbi-revenue-digital-twin`: scenario simulation and target-gap closure.
- `powerbi-autonomous-forecast-agents`: backlog, demand, budget, skeptic, risk, and arbitrator perspectives.
- `powerbi-autonomous-exception-management`: managed cases for gaps, risks, blockers, and biased planning outputs.
- `powerbi-revenue-rescue-mode`: operational customer/product actions to close revenue gaps.
- `powerbi-forecast-trust-market`: human override, confidence, and model-vs-human trust loops.
- `powerbi-causal-counterfactual-forecasting`: causal drivers and what-if alternatives.
- `powerbi-self-healing-forecast-governance`: demotion, blocking, and safer-baseline routing when AI quality is poor.
- `powerbi-planning-memory`: durable run, assumption, action, override, actual, and lesson memory.
- `powerbi-planning-readiness-score`: autonomous-readiness scoring and blocker identification.
- `powerbi-forecast-war-room`: executive control tower, action ownership, and gap status.

### Customize governance rules

Rules live in `rules/powerbi-governance-rules.json`. Adjust severities, regex patterns, and thresholds there instead of editing scanner code. Keep custom rules specific enough to avoid noisy findings.

### Generate a report theme

Run:

```powershell
.\plugins\powerbi-desktop\scripts\New-PowerBITheme.ps1 -Name "Executive Analytics" -OutputPath .\executive-theme.json
```

Use generated themes as a starting point for consistent report styling. Ask before replacing any production theme file.

### Generate a metric catalog

Run:

```powershell
.\plugins\powerbi-desktop\scripts\New-PowerBIMetricCatalog.ps1 -Path . -OutputPath .\powerbi-metric-catalog.md
```

Use this as a semantic contract starter. The generated owner and business definition fields are intentionally TODOs so humans can confirm metric accountability and meaning.

### Create a refactoring plan

Run:

```powershell
.\plugins\powerbi-desktop\scripts\New-PowerBIRefactorPlan.ps1 -Path . -OutputPath .\powerbi-refactor-plan.md
```

Use this to turn scan findings into phased work: Stabilize, Govern, and Polish. Keep it separate from direct file edits until the user confirms the intended changes.

### Create a report blueprint

Run:

```powershell
.\plugins\powerbi-desktop\scripts\New-PowerBIReportBlueprint.ps1 -Path . -OutputPath .\powerbi-report-blueprint.md
```

Use this to convert the metric catalog into a page-level UX plan. It is a design artifact, not a Power BI file writer.

### Create an AI prompt pack

Run:

```powershell
.\plugins\powerbi-desktop\scripts\New-PowerBIAIPromptPack.ps1 -Path . -OutputDirectory .\powerbi-ai-pack
```

Use this when the user wants AI/KI-assisted report improvement. It packages scan results, metrics, dependencies, refactor plan, and report blueprint into `context-pack.json` plus focused prompts.

### Analyze measure impact

Run:

```powershell
.\plugins\powerbi-desktop\scripts\New-PowerBIDependencyGraph.ps1 -Path . -OutputPath .\powerbi-dependency-graph.md
.\plugins\powerbi-desktop\scripts\New-PowerBIDependencyGraph.ps1 -Path . -Mermaid -OutputPath .\powerbi-dependency-graph.mmd
```

Use this before changing shared measures. Treat hub metrics as higher-risk because dependent measures may inherit changed semantics.

### Generate an executive narrative

Run:

```powershell
.\plugins\powerbi-desktop\scripts\New-PowerBIExecutiveNarrative.ps1 -Path . -OutputPath .\powerbi-executive-narrative.md
```

Use this for stakeholder-facing summaries. It is deterministic and based on local scan outputs, not a substitute for business-owner sign-off.

### Propose changes

- For DAX changes, provide the exact measure expression and target table.
- For Power Query changes, provide the target query and replacement M steps.
- For model changes, describe whether they should be made in Power BI Desktop, Tabular Editor, or source-controlled PBIP files.
- Include a rollback note for report-critical changes.

### Validate

When tools are available, prefer:

- Power BI Desktop for opening and visual validation.
- Tabular Editor CLI for Best Practice Analyzer checks.
- DAX Studio or XMLA endpoints for query/performance investigation.
- Source-control diffs for PBIP/TMDL changes.

## Script References

- `scripts/Test-PowerBIEnvironment.ps1` checks for Power BI Desktop, Tabular Editor, DAX Studio, and common Microsoft Store install locations.
- `scripts/Get-PowerBIInventory.ps1` inventories PBIX, PBIT, PBIP, TMDL, DAX, Power Query, and model metadata files.
- `scripts/New-PowerBIModelSummary.ps1` creates a markdown summary from TMDL, DAX, Power Query, and `model.bim` files.
- `scripts/Invoke-PowerBIInsightScan.ps1` creates a governance and risk report with DAX and Power Query heuristics.
- `scripts/New-PowerBITheme.ps1` creates a governed Power BI theme JSON starter.
- `scripts/New-PowerBIMetricCatalog.ps1` creates a markdown or JSON metric catalog from DAX/TMDL measures.
- `scripts/New-PowerBIRefactorPlan.ps1` converts insight findings into a phased refactoring backlog.
- `scripts/New-PowerBIReportBlueprint.ps1` creates a page-level report UX blueprint from the metric catalog.
- `scripts/New-PowerBIDependencyGraph.ps1` creates markdown, JSON, or Mermaid dependency graphs for measures.
- `scripts/New-PowerBIAIPromptPack.ps1` packages AI-ready context and prompts for review/refactoring/narrative tasks.
- `scripts/New-PowerBIExecutiveNarrative.ps1` creates a stakeholder-facing narrative from scan, catalog, and graph outputs.
- `scripts/Get-PowerBIPBIPStructure.ps1` scores PBIP/TMDL/report metadata readiness.
- `scripts/Invoke-PowerBIAutoReview.ps1` runs the full local AI review package.
- `scripts/Get-PowerBIDesktopLiveConnection.ps1` detects the local Desktop model endpoint.
- `scripts/Invoke-PowerBILiveDmv.ps1` runs read-only DMV queries against the open Desktop model via ADOMD.
- `scripts/Get-PowerBILiveModelSummary.ps1` creates a live model summary from the open Desktop model.
- `scripts/New-PowerBILiveMetricCatalog.ps1` creates a live metric catalog from the open Desktop model.
- `scripts/New-PowerBILiveDependencyGraph.ps1` creates live measure dependency graphs.
- `scripts/Invoke-PowerBILiveInsightScan.ps1` scans the open Desktop model for live governance findings.
- `scripts/Invoke-PowerBILiveAutoReview.ps1` runs the complete live-model review package.
- `scripts/Invoke-PowerBILiveDaxQuery.ps1` runs read-only DAX queries against the open Desktop model.
- `scripts/Test-PowerBILiveMeasures.ps1` executes selected hub/review measures and reports pass/fail results.
- `scripts/Test-PowerBILiveMetadataGovernance.ps1` checks descriptions, format strings, naming, and local date table signals.
- `scripts/New-PowerBILiveRefactorSuggestions.ps1` creates DAX refactoring suggestions for risky live measures.
- `rules/powerbi-governance-rules.json` contains configurable DAX and Power Query governance rules.
- `tests/Run-PowerBITests.ps1` runs smoke, golden-baseline, and Pester tests. Pester specs live under `tests/pester`.
- `scripts/Invoke-PowerBIInnovationReview.ps1` creates guided fix, lineage, test, performance, UX, explainability, governance, Copilot, and release-readiness artifacts.
- `scripts/New-PowerBIGuidedFixPlan.ps1` converts findings and metric risks into a prioritized guided remediation workflow.
- `scripts/Compare-PowerBISemanticModel.ps1` compares two text-based model folders for added, removed, or changed measures.
- `scripts/New-PowerBIMeasureLineageImpact.ps1` scores upstream/downstream measure impact.
- `scripts/New-PowerBIMeasureTestPlan.ps1` generates DAX validation queries for key measures.
- `scripts/New-PowerBIPerformanceAdvisor.ps1` flags expensive DAX patterns and remediation advice.
- `scripts/New-PowerBIReportUXCritic.ps1` reviews PBIP report metadata when available.
- `scripts/New-PowerBIExecutiveExplainabilityPack.ps1` creates stakeholder-facing metric trust guidance.
- `scripts/New-PowerBIModelGovernanceScorecard.ps1` creates repeatable governance scoring.
- `scripts/Test-PowerBICopilotReadiness.ps1` checks semantic readiness for Copilot/Q&A scenarios.
- `scripts/New-PowerBIReleaseChecklist.ps1` creates a publish-readiness checklist.
- `scripts/New-PowerBIBusinessSemanticLayer.ps1` describes KPI business meaning, allowed use, prohibited use, and required sign-off.
- `scripts/New-PowerBIKpiTrustScore.ps1` scores every KPI by DAX risk, ownership, definition, dependency impact, and generated test coverage.
- `scripts/New-PowerBIDecisionRiskAssistant.ps1` maps low-trust KPIs to affected decisions, audiences, and required actions.
- `scripts/New-PowerBITrustReleaseGate.ps1` produces a Go/Warn/No-Go release decision.
- `scripts/New-PowerBIFlightRecorder.ps1` records trust and release history snapshots.
- `scripts/Compare-PowerBIMeasureBehavior.ps1` creates before/after validation guidance for changed measures.
- `scripts/New-PowerBIReportNarrativeCritic.ps1` critiques report story quality and executive confidence.
- `scripts/Optimize-PowerBICopilotModel.ps1` proposes names, descriptions, synonyms, and visibility for Copilot/Q&A.
- `scripts/New-PowerBIDaxFixSimulation.ps1` packages original DAX, simulated DAX, validation queries, and rollback notes.
- `scripts/New-PowerBIVisualMeasureImpactMap.ps1` maps measures to detected report metadata references when PBIP report JSON is available.
- `scripts/New-PowerBIMeasureDraft.ps1` creates a safe TMDL draft for a new measure with validation queries and rollback guidance.
- `scripts/New-PowerBICalculatedColumnDraft.ps1` creates a safe TMDL draft for a calculated column and includes the calculated-column best-practice warning.
- `scripts/Test-PowerBIModelBestPractices.ps1` checks model best practices using `rules/powerbi-trust-rules.json`.
- `rules/powerbi-trust-rules.json` configures trust score weights, release-gate thresholds, and best-practice switches.
- `scripts/New-PowerBIReportPageDraft.ps1` creates a PBIP-safe report page draft with visual specs.
- `scripts/New-PowerBIVisualDraft.ps1` creates a visual spec for KPI cards, bar charts, line charts, matrix/table, slicers, tooltips, and drillthrough pages.
- `scripts/New-PowerBIReportLayoutPlan.ps1` creates stable visual layout slots.
- `scripts/Add-PowerBIPBIPReportPage.ps1` writes a generated page into a PBIP report folder when `-Apply` is used.
- `scripts/New-PowerBIPBIXCompileWorkflow.ps1` creates the safe workflow back from PBIP to PBIX.
- `scripts/Get-PowerBIExternalToolInventory.ps1` detects installed Power BI external tools from PATH and known Program Files locations.
- `scripts/New-PowerBIExternalToolCapabilityMatrix.ps1` maps Codex and external tool capabilities side by side.
- `scripts/Invoke-PowerBIExternalToolsReview.ps1` generates workflows for Tabular Editor, DAX Studio, ALM Toolkit, Power BI Helper, Model Documenter, PBI.tips tools, and pbi-tools.
- `scripts/Invoke-PowerBINativeToolParityReview.ps1` runs native BPA, documentation, performance, layout, theme, and source-control artifacts without external wrappers.
- `scripts/Invoke-PowerBINativeBpa.ps1` applies built-in DAX, Power Query, and metric-governance rules.
- `scripts/Compare-PowerBINativeModel.ps1` compares semantic and file-level model changes.
- `scripts/New-PowerBINativeModelDocumentation.ps1` creates local model documentation similar to documentation tools.
- `scripts/New-PowerBINativePerformanceProfile.ps1` estimates DAX performance risk and VertiPaq-style follow-up needs.
- `scripts/Test-PowerBIReportLayoutBestPractices.ps1` checks PBIP report JSON layout signals.
- `scripts/New-PowerBIThemeAudit.ps1` checks theme completeness.
- `scripts/New-PowerBIPBIPSourceControlPlan.ps1` creates source-control guidance for PBIP projects.
- `scripts/Invoke-PowerBIRealFeatureReview.ps1` creates the real-feature review package.
- `scripts/Test-PowerBIVisualSchema.ps1` checks PBIP report JSON validity where available.
- `scripts/Test-PowerBIReportRenderReadiness.ps1` creates render-readiness checks.
- `scripts/Invoke-PowerBILiveDaxBenchmark.ps1` measures live XMLA DAX query elapsed time.
- `scripts/Get-PowerBILiveVertiPaqAnalyzer.ps1` reads live DMVs for model-size/performance follow-up.
- `scripts/New-PowerBICalculationGroupDraft.ps1` creates calculation group and calculation item drafts.
- `scripts/New-PowerBIRelationshipDraft.ps1` creates relationship drafts.
- `scripts/New-PowerBIRlsRoleDraft.ps1` creates RLS role drafts.
- `scripts/New-PowerBIPowerQueryDraft.ps1` creates Power Query/M drafts with folding and gateway guidance.
- `scripts/New-PowerBIServiceIntegrationPlan.ps1` creates service workspace/deployment/refresh planning.
- `scripts/New-PowerBIIncrementalRefreshDraft.ps1` creates incremental refresh policy drafts.
- `scripts/New-PowerBIAggregationDraft.ps1` creates aggregation mapping drafts.
- `scripts/New-PowerBISchemaAwareVisualPlan.ps1` recommends visuals from metric/schema signals.
- `scripts/Apply-PowerBIPBIPTmdlDraft.ps1` writes generic TMDL drafts with backup and manifest handling.
- `scripts/Apply-PowerBIPBIPMeasureDraft.ps1` applies a measure draft into a PBIP draft folder.
- `scripts/Apply-PowerBIPBIPCalculatedColumnDraft.ps1` applies a calculated column draft into a PBIP draft folder.
- `scripts/Apply-PowerBIPBIPPowerQueryDraft.ps1` applies a Power Query draft into a PBIP query folder.
- `scripts/Invoke-PowerBIPBIPApplyPlan.ps1` summarizes applied draft artifacts and validation steps.

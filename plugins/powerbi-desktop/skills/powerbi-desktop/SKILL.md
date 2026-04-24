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
13. Look for these editable artifacts:
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

Use this as the fastest end-to-end path. It produces inventory, PBIP readiness, scan, metric catalog, dependency graph, refactor plan, report blueprint, model summary, executive narrative, and AI prompt pack.

### Inspect the open Desktop model

Run:

```powershell
.\plugins\powerbi-desktop\scripts\Get-PowerBIDesktopLiveConnection.ps1
.\plugins\powerbi-desktop\scripts\Get-PowerBILiveModelSummary.ps1 -OutputPath .\powerbi-live-model-summary.md
.\plugins\powerbi-desktop\scripts\Invoke-PowerBILiveAutoReview.ps1 -OutputDirectory .\powerbi-live-auto-review
```

This reads the local Analysis Services endpoint created by Power BI Desktop. It can inspect metadata and DMV output from the currently open model when Desktop is running. The live auto-review also creates measure validation, metadata governance, refactor suggestions, prioritized fix backlogs, and DAX fix drafts. Do not use it to modify or publish the report unless the user explicitly asks and a supported write path is available.

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
- `scripts/Test-PowerBIPlugin.ps1` runs smoke tests against the bundled sample model.

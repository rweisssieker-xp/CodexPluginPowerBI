# Script Catalog

Scripts live in `plugins/powerbi-desktop/scripts`. Most commands accept either a local `-Path` for offline review or generate output through `-OutputPath`, `-OutputDirectory`, or `-Json`.

## Environment And Discovery

- `Test-PowerBIEnvironment.ps1`: checks local Power BI tooling such as Power BI Desktop, Tabular Editor, DAX Studio, pbi-tools, and .NET.
- `Get-PowerBIInventory.ps1`: discovers Power BI files in a workspace.
- `Get-PowerBIPBIPStructure.ps1`: scores PBIP/TMDL inspectability and source-control readiness.
- `Get-PowerBIDesktopLiveConnection.ps1`: detects running Desktop model endpoints; supports explicit `-Server`, `-Port`, and `-RequireSingle` target selection.
- `Resolve-PowerBILiveTarget.ps1`: machine-readable live target resolver with ambiguity handling.
- `New-PowerBILiveSafetyPlan.ps1`: machine-readable DryRun/Preview/Confirm guardrail plan for live Desktop workflows.

## Review Orchestrators

- `Invoke-PowerBIAutoReview.ps1`: offline review package for a project path.
- `Invoke-PowerBIUnifiedReview.ps1`: broad review index combining offline, live when available, native parity, external tools, and AI outputs.
- `Invoke-PowerBIMaxAIReview.ps1`: advanced AI/KI package with 21 artifacts across 20 USP workflows.
- `Invoke-PowerBIInnovationReview.ps1`: innovation-focused package with UX, governance, release, and trust outputs.
- `Invoke-PowerBIRealFeatureReview.ps1`: real-feature validation for schema, render readiness, Fabric/service planning, refresh, aggregation, RLS, and visuals.
- `Invoke-PowerBINativeToolParityReview.ps1`: native parity package for BPA, compare, docs, performance, layout, theme, and source control.
- `Invoke-PowerBIExternalToolsReview.ps1`: external-tool-aware workflow bundle.

## Semantic Model Analysis

- `New-PowerBIModelSummary.ps1`: summarizes model files, measures, queries, and metadata.
- `Invoke-PowerBIInsightScan.ps1`: scores DAX, Power Query, PBIP readiness, and inspectability risks.
- `New-PowerBIMetricCatalog.ps1`: creates a semantic metric catalog.
- `New-PowerBIDependencyGraph.ps1`: creates Markdown or Mermaid DAX dependency output.
- `New-PowerBIRefactorPlan.ps1`: converts findings into phased refactor work.
- `Compare-PowerBISemanticModel.ps1`: compares semantic model artifacts.
- `Compare-PowerBIMeasureBehavior.ps1`: compares before/after measure behavior metadata.

## Live Desktop Analysis

- `Invoke-PowerBILiveDmv.ps1`: runs read-only DMV queries.
- `Invoke-PowerBILiveDaxQuery.ps1`: runs DAX queries for validation.
- `Get-PowerBILiveModelSummary.ps1`: summarizes the open Desktop model.
- `New-PowerBILiveMetricCatalog.ps1`: catalogs measures from the live model.
- `Invoke-PowerBILiveInsightScan.ps1`: live risk scan.
- `Test-PowerBILiveMeasures.ps1`: validates measures with DAX queries.
- `Test-PowerBILiveMetadataGovernance.ps1`: checks live metadata quality.
- `New-PowerBILiveRefactorSuggestions.ps1`: suggests live-model refactors.
- `New-PowerBILiveFixBacklog.ps1`: creates a prioritized fix backlog.
- `New-PowerBILiveDaxFixDrafts.ps1`: drafts DAX fixes from live findings.
- `Invoke-PowerBILiveDaxBenchmark.ps1`: lightweight DAX benchmark helper.
- `Get-PowerBILiveVertiPaqAnalyzer.ps1`: VertiPaq-style live metadata extraction.
- `Invoke-PowerBILiveAutoReview.ps1`: live review package.

## AI/KI And USP Workflows

### `Invoke-PowerBIAIForecast.ps1`

Creates read-only AI/KI sales forecast from open Desktop model or saved extract. Supports `-AsOfDate`, `-HorizonMonths`, `-Grain CustomerProduct|HierarchyProductLine`, `-Backtest`, and `-Json`. Outputs detail, monthly summary, top-delta, backtest, and model-quality CSV files. Combines actual-to-date, learned backlog conversion, residual demand, budget/roll anchors, sparse-series fallback, and monthly reconciliation. Live `CustomerProduct` extraction can fall back to hierarchy/product-line grain when Desktop cannot materialize the fine grain.

- `Invoke-PowerBIFixUntilGreenLoop.ps1`: generates iterative fix-loop guidance.
- `Test-PowerBISemanticModelCopilotEvaluator.ps1`: evaluates Copilot-readiness semantics.
- `New-PowerBIDataContract.ps1`: drafts data contracts for key model artifacts.
- `New-PowerBIFabricDeploymentRiskSimulator.ps1`: simulates deployment risk.
- `New-PowerBIVisualIntentAnalyzer.ps1`: checks whether report visuals match metric intent.
- `New-PowerBIBrokenMeasureRootCauseGraph.ps1`: maps likely root causes for broken measures.
- `New-PowerBIKpiTrustTwin.ps1`: creates KPI trust-twin scoring.
- `Update-PowerBIReviewMemory.ps1`: maintains local review memory.
- `New-PowerBINaturalLanguagePBIPAuthoring.ps1`: turns natural-language intent into PBIP draft instructions.
- `New-PowerBIGovernanceRuleMiner.ps1`: proposes governance rules from repeated findings.
- `New-PowerBIExplainableDaxRefactoring.ps1`: creates explainable DAX refactor options.
- `New-PowerBIReportDecisionSimulator.ps1`: simulates report decision risk.
- `New-PowerBITrustDebtLedger.ps1`: creates owner/SLA-style KPI trust debt from trust scores, release gates, and guided fixes.
- `New-PowerBIKpiIncidentReport.ps1`: creates KPI incident evidence, root-cause, rollback, and validation dossiers.
- `Test-PowerBIRlsLeakage.ps1`: drafts RLS leakage tests and release-gate impact from role metadata or role matrices.
- `New-PowerBIFabricCapacityRiskForecast.ps1`: forecasts Fabric capacity, refresh, and query risk from local evidence.
- `Find-PowerBIMetricDuplicates.ps1`: finds semantic duplicate measures and canonical KPI candidates.
- `New-PowerBIForecastExceptionBoard.ps1`: creates forecast exception cases with owners, actions, due windows, and closure evidence.
- `Import-PowerBIUsageSignals.ps1`: imports usage metrics, audit, or activity CSV/JSON exports.
- `New-PowerBIUsageTrustMatrix.ps1`: combines usage signals and KPI trust to prioritize high-usage/low-trust remediation.
- `Test-PowerBIPBIPRollbackReadiness.ps1`: checks PBIP rollback rehearsal readiness without destructive file operations.

## Enterprise AI Release Engineering

- `Get-PowerBIFabricWorkspaceInventory.ps1`: creates an offline Fabric workspace inventory plan, with explicit token-file gated REST preparation.
- `New-PowerBIServiceScanner.ps1`: creates service governance findings for ownership, refresh, labels, endorsements, source control, and release gate state.
- `New-PowerBITomWritePlan.ps1`: drafts gated TOM/TMSL write plans with dry-run, backup, diff, and rollback checks.
- `Optimize-PowerBIReportLayout.ps1`: creates auto-fix layout plans for report visuals.
- `Invoke-PowerBISemanticTestRunner.ps1`: creates or evaluates semantic measure test expectations.
- `Import-PowerBIPerformanceTrace.ps1`: imports Performance Analyzer or DAX Studio trace signals and creates hotspot guidance.
- `Import-PowerBIVertiPaqAnalyzer.ps1`: imports VPAX/VertiPaq-style storage signals or creates capture guidance.
- `New-PowerBIReportScreenshotUXReview.ps1`: creates screenshot-based UX, accessibility, and executive-fit review structure.
- `New-PowerBIGovernancePolicyPack.ps1`: generates profile-specific governance rules.
- `Update-PowerBIChangeJournal.ps1`: records AI change decisions and statuses.
- `New-PowerBIModelRiskHeatmap.ps1`: aggregates model, DAX, service, storage, and release risk.
- `New-PowerBIReleaseCandidatePack.ps1`: creates a one-command enterprise release package.

## PBIP Authoring And Apply

- `New-PowerBIMeasureDraft.ps1`: drafts a measure.
- `New-PowerBICalculatedColumnDraft.ps1`: drafts a calculated column.
- `New-PowerBIPowerQueryDraft.ps1`: drafts Power Query M.
- `New-PowerBICalculationGroupDraft.ps1`: drafts calculation-group TMDL.
- `New-PowerBIRelationshipDraft.ps1`: drafts relationship TMDL.
- `New-PowerBIRlsRoleDraft.ps1`: drafts RLS role TMDL.
- `New-PowerBIReportPageDraft.ps1`: drafts a report page.
- `New-PowerBIVisualDraft.ps1`: drafts a visual definition.
- `Add-PowerBIPBIPReportPage.ps1`: writes a PBIP report page when `-Apply` is used.
- `Apply-PowerBIPBIPMeasureDraft.ps1`: writes a measure draft when `-Apply` is used.
- `Apply-PowerBIPBIPCalculatedColumnDraft.ps1`: writes a calculated-column draft when `-Apply` is used.
- `Apply-PowerBIPBIPPowerQueryDraft.ps1`: writes a Power Query draft when `-Apply` is used.
- `Apply-PowerBIPBIPTmdlDraft.ps1`: writes generic TMDL when `-Apply` is used.
- `Invoke-PowerBIPBIPApplyPlan.ps1`: summarizes applied draft artifacts.
- `New-PowerBIPBIXCompileWorkflow.ps1`: documents a PBIP-to-PBIX compile path.

## Governance, Trust, And Release

- `Test-PowerBIModelBestPractices.ps1`: checks configured trust rules.
- `Test-PowerBIGoldenBaselines.ps1`: validates sample-model regression baselines.
- `New-PowerBITrustReleaseGate.ps1`: produces Go/Warn/No-Go release gates.
- `New-PowerBIReleaseChecklist.ps1`: creates a release checklist.
- `New-PowerBIGuidedFixPlan.ps1`: turns findings into guided fixes.
- `New-PowerBIMeasureTestPlan.ps1`: drafts measure test cases.
- `Test-PowerBIMeasureExpectations.ps1`: validates expected measures.
- `New-PowerBIPRReleaseComment.ps1`: generates PR-ready release notes.

## Native And External Tool Parity

- `Invoke-PowerBINativeBpa.ps1`: local BPA-style checks.
- `Compare-PowerBINativeModel.ps1`: local model compare.
- `New-PowerBINativeModelDocumentation.ps1`: model documentation.
- `New-PowerBINativePerformanceProfile.ps1`: DAX risk/performance profile.
- `Test-PowerBIReportLayoutBestPractices.ps1`: layout checks.
- `New-PowerBIThemeAudit.ps1`: theme audit.
- `New-PowerBIPBIPSourceControlPlan.ps1`: source-control plan.
- `Get-PowerBIExternalToolInventory.ps1`: detects known external tools.
- `New-PowerBIExternalToolCapabilityMatrix.ps1`: maps tool capabilities.
- `New-PowerBITabularEditorWorkflow.ps1`, `New-PowerBIDaxStudioWorkflow.ps1`, `New-PowerBIALMToolkitWorkflow.ps1`, `New-PowerBIHelperWorkflow.ps1`, `New-PowerBIPbiToolsWorkflow.ps1`: tool-specific workflows.

## Fabric And Service Planning

- `New-PowerBIFabricReadinessPlan.ps1`: Fabric readiness plan.
- `New-PowerBIFabricDeploymentRiskSimulator.ps1`: deployment-risk simulation.
- `New-PowerBIServiceIntegrationPlan.ps1`: service integration plan.
- `New-PowerBIIncrementalRefreshDraft.ps1`: incremental refresh draft.
- `New-PowerBIAggregationDraft.ps1`: aggregation draft.
- `New-PowerBISchemaAwareVisualPlan.ps1`: visual plan based on model schema.

## Reporting, UX, And Narratives

- `New-PowerBIReportBlueprint.ps1`: page-level report blueprint.
- `New-PowerBIReportLayoutPlan.ps1`: layout plan.
- `New-PowerBIReportUXCritic.ps1`: report UX critique.
- `New-PowerBIReportNarrativeCritic.ps1`: narrative critique.
- `New-PowerBIExecutiveNarrative.ps1`: deterministic executive narrative.
- `New-PowerBIExecutiveExplainabilityPack.ps1`: explainability package.
- `New-PowerBITheme.ps1`: governed theme generator.
- `New-PowerBIAIPromptPack.ps1`: context and prompt pack for Codex reviews.

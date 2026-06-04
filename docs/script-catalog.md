# Script Catalog

Scripts live in `plugins/powerbi-desktop/scripts`. Most commands accept either a local `-Path` for offline review or generate output through `-OutputPath`, `-OutputDirectory`, or `-Json`.

## Status Model And Schemas

- Live/repo reconciliation uses `LiveUnavailable`, `NoDrift`, and `DriftDetected` to distinguish skipped live checks from clean or changed live Desktop comparisons.
- Semantic test output uses schema `codex.powerbi.semanticTestRunner.v2`.
- Semantic tests can return `PendingLiveDax` when live DAX execution is required; `-FailOnPending` treats those pending checks as failures for release gates.

## Environment And Discovery

- `Test-PowerBIEnvironment.ps1`: checks local Power BI tooling such as Power BI Desktop, Tabular Editor, DAX Studio, pbi-tools, .NET, and the ADOMD client provider used by live DMV/DAX workflows.
- `Test-PowerBIPlugin.ps1`: runs the local plugin smoke and regression checks.
- `Test-PowerBIDocumentationCoverage.ps1`: checks that scripts are mentioned in documentation and stale claims are absent.
- `Get-PowerBIInventory.ps1`: discovers Power BI files in a workspace.
- `Get-PowerBIPBIPStructure.ps1`: scores PBIP/TMDL inspectability and source-control readiness.
- `Get-PowerBIDesktopLiveConnection.ps1`: detects running Desktop model endpoints; supports explicit `-Server`, `-Port`, and `-RequireSingle` target selection.
- `Resolve-PowerBILiveTarget.ps1`: machine-readable live target resolver with ambiguity handling.
- `New-PowerBILiveSafetyPlan.ps1`: machine-readable DryRun/Preview/Confirm guardrail plan for live Desktop workflows.

## Review Orchestrators

- `Invoke-PowerBIAutoReview.ps1`: offline review package for a project path.
- `Invoke-PowerBIUnifiedReview.ps1`: broad review index combining offline, live when available, native parity, external tools, and AI outputs.
- `Invoke-PowerBIMaxAIReview.ps1`: advanced AI package with 39 artifacts across 38 USP workflows.
- `Invoke-PowerBIBusinessProcessDataQuality.ps1`: local business process data-quality package for Power BI metadata and CSV/JSON ERP exports.
- `New-PowerBIProcessDataMapping.ps1`: proposes canonical process object mappings from PBIP/TMDL metadata and local CSV/JSON exports.
- `New-PowerBIBusinessProcessDQPack.ps1`: wrapper for the standalone business process data-quality pack.
- `Invoke-PowerBIInnovationReview.ps1`: innovation-focused package with UX, governance, release, and trust outputs.
- `Invoke-PowerBIRealFeatureReview.ps1`: real-feature validation for schema, render readiness, Fabric/service planning, refresh, aggregation, RLS, and visuals.
- `Invoke-PowerBINativeToolParityReview.ps1`: native parity package for BPA, compare, docs, performance, layout, theme, and source control.
- `Invoke-PowerBIExternalToolsReview.ps1`: external-tool-aware workflow bundle.
- `Test-PowerBIAnalysisMethodology.ps1`: validates whether local analysis evidence is methodologically ready for stakeholder release.
- `New-PowerBIMetricChangeDiagnosis.ps1`: explains metric movement, mismatch, or diagnostic gaps from local Power BI evidence.
- `New-PowerBIAnalyticalReleaseReport.ps1`: creates a stakeholder-ready analytical release report from trust, semantic-test, release-gate, and methodology evidence.
- `New-PowerBIEvidenceGraph.ps1`: links model metrics, semantic tests, dependencies, visuals, and review artifacts into a local evidence graph.
- `New-PowerBIExecutiveTrustBrief.ps1`: creates a one-page executive trust brief with release decision, KPI trust, methodology, lineage, and security status.

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
- `Compare-PowerBILiveRepoModel.ps1`: compares a live Desktop model with local repo metadata and reports live drift status.
- `New-PowerBILiveDependencyGraph.ps1`: builds live measure dependency nodes and edges, with optional Mermaid output.
- `New-PowerBILiveExecutiveNarrative.ps1`: summarizes live model risk, top findings, and high-impact measures for executives.

## AI And USP Workflows

### `Invoke-PowerBIAIForecast.ps1`

Creates read-only AI sales forecast from open Desktop model or saved extract. Supports `-AsOfDate`, `-HorizonMonths`, `-Grain CustomerProduct|HierarchyProductLine`, `-Backtest`, and `-Json`. Outputs detail, monthly summary, top-delta, backtest, and model-quality CSV files. Combines actual-to-date, learned backlog conversion, residual demand, budget/roll anchors, sparse-series fallback, and monthly reconciliation. Live `CustomerProduct` extraction can fall back to hierarchy/product-line grain when Desktop cannot materialize the fine grain.

- `Invoke-PowerBIFixUntilGreenLoop.ps1`: generates iterative fix-loop guidance.
- `Invoke-PowerBIAskModel.ps1`: answers model questions from local Power BI metadata.
- `Invoke-PowerBIAutonomousFixAgent.ps1`: creates autonomous fix guidance and guarded remediation plans.
- `Test-PowerBISemanticModelCopilotEvaluator.ps1`: evaluates Copilot-readiness semantics.
- `Test-PowerBICopilotReadiness.ps1`: scores Copilot readiness from technical naming and missing semantic definitions.
- `Optimize-PowerBICopilotModel.ps1`: proposes display names, descriptions, synonyms, and Q&A visibility.
- `New-PowerBIDataContract.ps1`: drafts data contracts for key model artifacts.
- `New-PowerBIFabricDeploymentRiskSimulator.ps1`: simulates deployment risk.
- `New-PowerBIVisualIntentAnalyzer.ps1`: checks whether report visuals match metric intent.
- `New-PowerBIBrokenMeasureRootCauseGraph.ps1`: maps likely root causes for broken measures.
- `New-PowerBIKpiTrustTwin.ps1`: creates KPI trust-twin scoring.
- `New-PowerBIKpiTrustScore.ps1`: scores KPI trust using DAX risks, ownership, definitions, lineage impact, and generated test coverage.
- `New-PowerBIKpiTrustContract.ps1`: creates KPI trust contracts for ownership, validation, and release-use rules.
- `Update-PowerBIReviewMemory.ps1`: maintains local review memory.
- `New-PowerBINaturalLanguagePBIPAuthoring.ps1`: turns natural-language intent into PBIP draft instructions.
- `New-PowerBIGovernanceRuleMiner.ps1`: proposes governance rules from repeated findings.
- `New-PowerBIExplainableDaxRefactoring.ps1`: creates explainable DAX refactor options.
- `New-PowerBIReportDecisionSimulator.ps1`: simulates report decision risk.
- `New-PowerBIBusinessSemanticLayer.ps1`: documents business context, allowed use, prohibited use, sign-off, and warnings for metrics.
- `New-PowerBIDaxFixSimulation.ps1`: simulates DAX fix candidates and validation queries for risky measures.
- `New-PowerBIDecisionRiskAssistant.ps1`: links KPI trust scores to affected decisions, audiences, and required actions.
- `New-PowerBIFlightRecorder.ps1`: records trust and release-gate history and computes trend movement.
- `New-PowerBIMeasureLineageImpact.ps1`: ranks measure change impact from upstream and downstream dependencies.
- `New-PowerBIModelGovernanceScorecard.ps1`: scores DAX quality, metadata, PBIP readiness, performance risk, and test coverage.
- `New-PowerBIPerformanceAdvisor.ps1`: finds DAX performance-risk patterns and proposes benchmark guidance.
- `New-PowerBITrustDebtLedger.ps1`: creates owner/SLA-style KPI trust debt from trust scores, release gates, and guided fixes.
- `New-PowerBIKpiIncidentReport.ps1`: creates KPI incident evidence, root-cause, rollback, and validation dossiers.
- `Test-PowerBIRlsLeakage.ps1`: drafts RLS leakage tests and release-gate impact from role metadata or role matrices.
- `New-PowerBIFabricCapacityRiskForecast.ps1`: forecasts Fabric capacity, refresh, and query risk from local evidence.
- `Find-PowerBIMetricDuplicates.ps1`: finds semantic duplicate measures and canonical KPI candidates.
- `New-PowerBIForecastExceptionBoard.ps1`: creates forecast exception cases with owners, actions, due windows, and closure evidence.
- `Import-PowerBIUsageSignals.ps1`: imports usage metrics, audit, or activity CSV/JSON exports.
- `New-PowerBIUsageTrustMatrix.ps1`: combines usage signals and KPI trust to prioritize high-usage/low-trust remediation.
- `Test-PowerBIPBIPRollbackReadiness.ps1`: checks PBIP rollback rehearsal readiness without destructive file operations.
- `New-PowerBIAgenticRemediationPlan.ps1`: ranks release blockers, guided fixes, DAX simulations, lineage impact, usage trust, and service governance into an actionable remediation backlog.
- `New-PowerBIBusinessOutcomeSimulator.ps1`: translates low-trust KPIs and report intent into business decision scenarios, confidence bands, and required evidence.
- `New-PowerBISemanticLayerAutopilot.ps1`: creates a semantic improvement plan for names, descriptions, synonyms, owner gaps, KPI contracts, visibility, and Copilot readiness.
- `New-PowerBIAIGovernanceEvidencePack.ps1`: builds an audit-style AI evidence package with suggestions, sign-off gaps, residual risks, and release evidence.
- `New-PowerBIHumanOverrideLearning.ps1`: reads optional human override CSV/JSON evidence or emits a capture template and learning-readiness status.
- `New-PowerBICrossReportKpiConflictDetector.ps1`: detects cross-report KPI definition conflicts and recommends canonical KPI ownership decisions.
- `New-PowerBIExecutiveNarrativeQualityAgent.ps1`: checks whether executive narrative claims are supported by visual intent, KPI trust, and release gates.
- `New-PowerBIAutonomousQALab.ps1`: generates QA questions, semantic expectations, visual readiness evidence, and regression-risk summaries.
- `New-PowerBIPBIPChangeImpactGate.ps1`: creates a diff-aware KPI release impact gate for changed PBIP/TMDL/report files.
- `New-PowerBISemanticTestFixtureGenerator.ps1`: generates deterministic semantic test fixtures and measure expectations.
- `New-PowerBIKpiOwnerSignoffWorkflow.ps1`: creates KPI owner sign-off items from trust debt, contracts, and incident evidence.
- `New-PowerBIRefreshBlastRadiusAnalyzer.ps1`: maps refresh, capacity, and service degradation to affected KPIs and stakeholders.
- `New-PowerBISensitiveDataExposureMap.ps1`: scans local metadata and report references for sensitive-data exposure risk.
- `New-PowerBICapacityMitigationPlanner.ps1`: turns capacity and performance risks into prioritized mitigation work.
- `New-PowerBIReportRetirementAdvisor.ps1`: identifies retirement, consolidation, and review candidates from usage, trust, and duplicate evidence.
- `New-PowerBILiveValidationEvidenceRecorder.ps1`: records live Desktop and Max AI validation evidence into a local audit pack.
- `New-PowerBISemanticContractDriftMonitor.ps1`: detects drift between metric catalogs, KPI contracts, and usage expectations.
- `New-PowerBIRlsPersonaCoverageMatrix.ps1`: maps RLS personas to visual/KPI impact and coverage gaps.

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
- `New-PowerBIReleaseCandidatePack.ps1 -IncludeAnalyticalQa`: adds analysis methodology validation, metric change diagnosis, and an analytical release report to the release package.
- `New-PowerBIReleaseCandidatePack.ps1 -IncludeAdvancedUspQa`: adds evidence graph, visual-to-measure impact, semantic contract test, executive trust brief, DAX change risk, freshness/lineage gate, KPI drift watchlist, RLS trust review, UX regression scan, and migration readiness.
- `New-PowerBIReleaseCandidatePack.ps1 -IncludePortfolioGovernanceQa`: adds portfolio command center, cost-to-trust optimizer, tenant hygiene scanner, and KPI conflict resolution.
- `New-PowerBIReleaseCandidatePack.ps1 -IncludeComplianceQa`: adds deployment pipeline gate, certified dataset readiness, accessibility compliance, Power Query data contract, and release evidence signature.
- `New-PowerBIReleaseCandidatePack.ps1 -IncludeOperationsQa`: adds refresh failure root-cause advisor, semantic test coverage score, and Business KPI SLA monitor.
- `New-PowerBIReleaseCandidatePack.ps1 -IncludeFabricLiveQa`: adds Fabric read-only access planning or imports a workspace snapshot.
- `New-PowerBIReleaseCandidatePack.ps1 -IncludeFabricPortfolioQa`: adds Fabric portfolio command center, tenant hygiene, cost-to-trust, workspace risk, and retirement evidence.
- `New-PowerBIReleaseCandidatePack.ps1 -IncludeFabricDeploymentQa`: adds Fabric deployment gate, certified dataset readiness, release evidence, promotion risk, and Dev/Test/Prod drift evidence.
- `New-PowerBIReleaseCandidatePack.ps1 -IncludeFabricOperationsQa`: adds Fabric refresh root cause, capacity hotspot, gateway risk, refresh SLA, and incident timeline.
- `New-PowerBIReleaseCandidatePack.ps1 -IncludeFabricGovernanceQa`: adds Fabric lineage graph, sensitivity label, sharing exposure, RLS service evidence, and audit evidence map.
- `New-PowerBIReleaseCandidatePack.ps1 -IncludeFabricExecutiveQa`: adds Fabric executive war room, board brief, CFO risk brief, data product scorecard, and trust narrative.

## Fabric Live Read-Only And Snapshot Intelligence

- `Get-PowerBIFabricAccessPlan.ps1`: read-only Fabric access plan with token-file and workspace-scope checks.
- `Invoke-PowerBIFabricReadOnlyRequest.ps1`: GET-only REST helper; mutating methods return `BlockedUnsafeMethod`.
- `Import-PowerBIFabricWorkspaceSnapshot.ps1`: imports or stages a local Fabric workspace snapshot.
- `Import-PowerBIFabricTenantSnapshot.ps1`: imports or stages a local Fabric tenant snapshot.
- `PowerBIFabricSnapshot.Shared.ps1`: shared snapshot reader used by Fabric USP scripts.
- `New-PowerBIFabricPortfolioCommandCenter.ps1`: Fabric portfolio trust, ownership, refresh, and risk command center.
- `New-PowerBIFabricTenantHygieneScanner.ps1`: Fabric tenant/workspace hygiene checks.
- `New-PowerBIFabricCostToTrustOptimizer.ps1`: Fabric capacity/usage/trust optimization backlog.
- `New-PowerBIFabricWorkspaceRiskRadar.ps1`: Fabric workspace refresh, gateway, and capacity risk radar.
- `New-PowerBIFabricArtifactRetirementBoard.ps1`: Fabric retirement/consolidation candidates.
- `Test-PowerBIFabricDeploymentPipelineGate.ps1`: Fabric deployment promotion gate.
- `Test-PowerBIFabricCertifiedDatasetReadiness.ps1`: Fabric certified dataset readiness check.
- `New-PowerBIFabricReleaseEvidencePack.ps1`: Fabric release evidence wrapper.
- `New-PowerBIFabricPromotionRiskSimulator.ps1`: promotion risk simulator from snapshot evidence.
- `Compare-PowerBIFabricDevTestProdDrift.ps1`: Dev/Test/Prod drift check.
- `New-PowerBIFabricRefreshFailureRootCauseAdvisor.ps1`: refresh failure root-cause advisor.
- `New-PowerBIFabricCapacityHotspotAnalyzer.ps1`: Fabric capacity hotspot analyzer.
- `New-PowerBIFabricGatewayRiskReview.ps1`: gateway risk review.
- `New-PowerBIFabricRefreshSlaMonitor.ps1`: refresh SLA monitor.
- `New-PowerBIFabricIncidentTimeline.ps1`: Fabric incident timeline.
- `New-PowerBIFabricLineageEvidenceGraph.ps1`: Fabric lineage evidence graph.
- `Test-PowerBIFabricSensitivityLabelCoverage.ps1`: sensitivity label coverage.
- `Test-PowerBIFabricSharingExposure.ps1`: external sharing exposure check.
- `Test-PowerBIFabricRlsServiceEvidence.ps1`: RLS service evidence check.
- `New-PowerBIFabricAuditEvidenceMap.ps1`: audit evidence map.
- `New-PowerBIFabricExecutiveWarRoom.ps1`: executive Fabric war room.
- `New-PowerBIFabricBoardBrief.ps1`: board-ready Fabric brief.
- `New-PowerBIFabricCfoRiskBrief.ps1`: CFO risk brief.
- `New-PowerBIFabricDataProductScorecard.ps1`: data product scorecard.
- `New-PowerBIFabricTrustNarrative.ps1`: Fabric trust narrative.

## Advanced Release USPs

- `New-PowerBIEvidenceGraph.ps1`: machine-readable evidence graph for release decisions.
- `New-PowerBIVisualMeasureImpactMap.ps1`: visual-to-measure impact analysis from PBIP report metadata.
- `Test-PowerBISemanticContract.ps1`: semantic contract testing for owners, definitions, and executable expectations.
- `New-PowerBIExecutiveTrustBrief.ps1`: executive trust brief in Markdown or JSON.
- `New-PowerBIDaxChangeRiskClassifier.ps1`: DAX change risk classifier for filter context, time intelligence, relationships, performance, and blank handling.
- `Test-PowerBIDataFreshnessLineageGate.ps1`: freshness, service scanner, data contract, and PBIP lineage release gate.
- `New-PowerBIKpiDriftWatchlist.ps1`: post-release KPI drift watchlist ranked by trust, risk, and visual exposure.
- `New-PowerBIRlsTrustReview.ps1`: RLS/OLS trust review wrapper with release status.
- `New-PowerBIReportUxRegressionScanner.ps1`: report UX regression scanner with optional baseline comparison.
- `Test-PowerBIMigrationReadiness.ps1`: PBIP/Fabric migration readiness gate.

## Portfolio Governance QA

- `New-PowerBIPortfolioCommandCenter.ps1`: portfolio-level trust, risk, usage, and retirement command center.
- `New-PowerBICostToTrustOptimizer.ps1`: ranks high-cost/low-trust KPI remediation opportunities.
- `New-PowerBITenantHygieneScanner.ps1`: checks service governance and flags missing tenant/workspace export evidence.
- `Resolve-PowerBIKpiDefinitionConflict.ps1`: turns duplicate/conflicting KPI evidence into owner decision recommendations.

## Compliance QA

- `Test-PowerBIDeploymentPipelineGate.ps1`: Dev/Test/Prod promotion gate from release, semantic test, and rollback evidence.
- `Test-PowerBICertifiedDatasetReadiness.ps1`: certification readiness from trust, service governance, RLS, and semantic contract evidence.
- `Test-PowerBIReportAccessibilityCompliance.ps1`: accessibility/compliance gate from UX, theme, and render-readiness evidence.
- `Test-PowerBIPowerQueryDataContract.ps1`: Power Query source, schema, gateway, and folding contract checks.
- `New-PowerBIReleaseEvidenceSignature.ps1`: SHA256 release evidence signature across local review artifacts.

## Operations QA

- `New-PowerBIRefreshFailureRootCauseAdvisor.ps1`: likely refresh failure root-cause advisor from Power Query and refresh blast-radius evidence.
- `New-PowerBISemanticTestCoverageScore.ps1`: coverage score for KPI, executable semantic test, and RLS validation evidence.
- `New-PowerBIBusinessKpiSlaMonitor.ps1`: KPI SLA monitor from trust, freshness, and drift watchlist evidence.

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
- `New-PowerBIExternalToolRegistration.ps1`: creates external-tool registration metadata.
- `Install-PowerBIExternalTool.ps1`: installs or stages external-tool registration assets.
- `Uninstall-PowerBIExternalTool.ps1`: removes external-tool registration assets.

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
- `New-PowerBIVisualMeasureImpactMap.ps1`: maps measures to report visual metadata references and impact guidance.
- `Test-PowerBIVisualSchema.ps1`: validates PBIP report visual JSON structure.
- `Test-PowerBIReportRenderReadiness.ps1`: combines visual schema checks with manual render and screenshot readiness status.

# Workflows

This page describes practical end-to-end flows.

The current USP stack is organized around eight repeatable workflows:

1. Unified review package.
2. Live target resolution and live-vs-repo reconciliation.
3. Semantic test runner.
4. Measure behavior diff.
5. PBIP Apply Engine with roundtrip and rollback checks.
6. Governance release gate.
7. Report and visual intelligence.
8. Release candidate pack for enterprise handoff.
9. Fabric live read-only QA from service snapshots.

## 1. First Local Health Check

Run this after cloning or changing plugin scripts:

```powershell
.\plugins\powerbi-desktop\scripts\Test-PowerBIEnvironment.ps1
.\plugins\powerbi-desktop\tests\Run-PowerBITests.ps1
```

Use `-SkipPester` when Pester is not installed and you only need the script smoke tests:

```powershell
.\plugins\powerbi-desktop\tests\Run-PowerBITests.ps1 -SkipPester
```

## 2. Offline Model Review

Use this for PBIP/TMDL/extracted models and sample projects.

```powershell
$model = ".\plugins\powerbi-desktop\examples\sample-model"
.\plugins\powerbi-desktop\scripts\Invoke-PowerBIAutoReview.ps1 -Path $model -OutputDirectory .\powerbi-auto-review
.\plugins\powerbi-desktop\scripts\Invoke-PowerBIInsightScan.ps1 -Path $model -OutputPath .\powerbi-insight-scan.md
.\plugins\powerbi-desktop\scripts\New-PowerBIMetricCatalog.ps1 -Path $model -OutputPath .\powerbi-metric-catalog.md
.\plugins\powerbi-desktop\scripts\New-PowerBIDependencyGraph.ps1 -Path $model -Mermaid -OutputPath .\powerbi-dependency-graph.mmd
```

Use this flow when you need deterministic review output without a running Power BI Desktop instance.

## 3. Unified Review Package

Use the unified review when you want one navigable package.

```powershell
.\plugins\powerbi-desktop\scripts\Invoke-PowerBIUnifiedReview.ps1 `
  -Path .\plugins\powerbi-desktop\examples\sample-model `
  -OutputDirectory .\powerbi-unified-review
```

Expected outputs include an index, model summary, scans, native parity outputs, external-tool context, and live outputs when Desktop is available.

## 4. Live Target Resolution And Reconciliation

Open Power BI Desktop with the model first. Then run:

```powershell
.\plugins\powerbi-desktop\scripts\Resolve-PowerBILiveTarget.ps1 -Json
.\plugins\powerbi-desktop\scripts\Get-PowerBIDesktopLiveConnection.ps1
.\plugins\powerbi-desktop\scripts\Invoke-PowerBILiveAutoReview.ps1 -OutputDirectory .\powerbi-live-auto-review
```

Use live mode when you need validation against the currently open Desktop model, not just source files. `Resolve-PowerBILiveTarget.ps1` makes target selection explicit and returns `TargetResolved`, `NoLiveTarget`, or `AmbiguousLiveTarget` before downstream scripts use a Desktop endpoint.

For source-control drift checks:

```powershell
.\plugins\powerbi-desktop\scripts\Compare-PowerBILiveRepoModel.ps1 `
  -Path .\plugins\powerbi-desktop\examples\sample-model `
  -Json
```

The live-vs-repo status is `LiveUnavailable`, `NoDrift`, or `DriftDetected`. `LiveUnavailable` means the offline review is still valid, but no live evidence was attached.

## 5. Max AI Review

Use this when you want the full USP package.

```powershell
.\plugins\powerbi-desktop\scripts\Invoke-PowerBIMaxAIReview.ps1 `
  -Path .\plugins\powerbi-desktop\examples\sample-model `
  -OutputDirectory .\powerbi-max-ai-review
```

This package focuses on fix loops, Copilot readiness, data contracts, Fabric risk, visual intent, root-cause graphs, KPI trust, review memory, natural-language PBIP authoring, governance rule mining, explainable refactoring, and decision simulation.

## 5a. Fabric Live Read-Only QA

Use this when Fabric service metadata must be part of the evidence without mutating Fabric:

```powershell
.\plugins\powerbi-desktop\scripts\Get-PowerBIFabricAccessPlan.ps1 -WorkspaceName "Target Workspace" -AccessTokenPath .\token.txt -Json
.\plugins\powerbi-desktop\scripts\Import-PowerBIFabricWorkspaceSnapshot.ps1 -WorkspaceName "Target Workspace" -AccessTokenPath .\token.txt -OutputDirectory .\fabric-snapshot
.\plugins\powerbi-desktop\scripts\New-PowerBIReleaseCandidatePack.ps1 -Path . -SnapshotDirectory .\fabric-snapshot -IncludeFabricLiveQa -IncludeFabricPortfolioQa -IncludeFabricDeploymentQa -IncludeFabricOperationsQa -IncludeFabricGovernanceQa -IncludeFabricExecutiveQa
```

For CI or offline review, skip the token and use a local snapshot fixture under `plugins/powerbi-desktop/examples/fabric-snapshot`.

## 6. Semantic Tests And Measure Behavior Diff

Run semantic tests before release gates:

```powershell
.\plugins\powerbi-desktop\scripts\Invoke-PowerBISemanticTestRunner.ps1 `
  -Path .\plugins\powerbi-desktop\examples\sample-model `
  -ExpectationsPath .\measure-expectations.json `
  -Json
```

Expectation entries carry `expected`, `tolerance`, and optional filter context. Add `-FailOnPending` when pending live DAX validation should fail CI instead of remaining a warning.

Compare behavior across two result files:

```powershell
.\plugins\powerbi-desktop\scripts\Compare-PowerBIMeasureBehavior.ps1 `
  -BaselineResultsPath .\baseline-semantic-tests.json `
  -CurrentResultsPath .\current-semantic-tests.json `
  -OutputPath .\measure-behavior-diff.md
```

Use behavior diff after DAX changes, PBIP apply runs, or live-server comparisons. A plan-only result is `NotAvailable` until result files or live servers are supplied.

## 7. PBIP Draft And Apply

Generate a draft first:

```powershell
.\plugins\powerbi-desktop\scripts\New-PowerBIMeasureDraft.ps1 `
  -TableName Sales `
  -MeasureName "Average Sales" `
  -Expression "DIVIDE([Total Sales], COUNTROWS('Sales'))"
```

Apply only when the target PBIP path is correct:

```powershell
.\plugins\powerbi-desktop\scripts\Apply-PowerBIPBIPMeasureDraft.ps1 `
  -PbipPath .\MyReport `
  -TableName Sales `
  -MeasureName "Average Sales" `
  -Expression "DIVIDE([Total Sales], COUNTROWS('Sales'))" `
  -Apply
```

Summarize applied artifacts:

```powershell
.\plugins\powerbi-desktop\scripts\Invoke-PowerBIPBIPApplyPlan.ps1 `
  -PbipPath .\MyReport `
  -OutputPath .\powerbi-apply-plan\apply-plan.json
```

Validate roundtrip and rollback readiness before handing a PBIX candidate to reviewers:

```powershell
.\plugins\powerbi-desktop\scripts\Get-PowerBIPBIPStructure.ps1 `
  -Path .\MyReport `
  -Json

.\plugins\powerbi-desktop\scripts\Test-PowerBIPBIPRollbackReadiness.ps1 `
  -PbipPath .\MyReport `
  -Json
```

## 8. Governance Release Gate

Run a trust gate before merging model changes:

```powershell
.\plugins\powerbi-desktop\scripts\Test-PowerBIModelBestPractices.ps1 `
  -Path .\plugins\powerbi-desktop\examples\sample-model `
  -OutputPath .\powerbi-model-best-practices.md

.\plugins\powerbi-desktop\scripts\New-PowerBITrustReleaseGate.ps1 `
  -Path .\plugins\powerbi-desktop\examples\sample-model `
  -CheckLiveAvailability `
  -OutputPath .\powerbi-trust-release-gate.md

.\plugins\powerbi-desktop\scripts\New-PowerBIPRReleaseComment.ps1 `
  -Path .\plugins\powerbi-desktop\examples\sample-model `
  -OutputPath .\powerbi-pr-comment.md
```

The gate evaluates open P0/P1 guided fixes, pending semantic tests, live validation availability, governance score, and trust signals. Use JSON output when CI or PR automation needs machine-readable decisions.

## 9. Report And Visual Intelligence

Use report intelligence when PBIP report metadata or screenshots are available:

```powershell
.\plugins\powerbi-desktop\scripts\New-PowerBIVisualMeasureImpactMap.ps1 `
  -Path .\MyReport `
  -OutputPath .\powerbi-visual-impact.md

.\plugins\powerbi-desktop\scripts\New-PowerBIVisualIntentAnalyzer.ps1 `
  -Path .\MyReport `
  -OutputPath .\powerbi-visual-intent.md

.\plugins\powerbi-desktop\scripts\New-PowerBIReportScreenshotUXReview.ps1 `
  -ImagePath .\report.png `
  -OutputPath .\powerbi-screenshot-ux.md
```

This maps measures to visual metadata, flags risky visual patterns, and adds UX/accessibility review evidence when screenshots are attached.

## 10. Fabric Readiness

Use this before moving a Desktop-centered model toward Fabric operations:

```powershell
.\plugins\powerbi-desktop\scripts\New-PowerBIFabricReadinessPlan.ps1 `
  -Path .\plugins\powerbi-desktop\examples\sample-model `
  -OutputPath .\powerbi-fabric-readiness.md

.\plugins\powerbi-desktop\scripts\New-PowerBIFabricDeploymentRiskSimulator.ps1 `
  -Path .\plugins\powerbi-desktop\examples\sample-model `
  -OutputPath .\powerbi-fabric-deployment-risk.md
```

This produces planning artifacts only. Tenant deployment stays explicit and manual.

## 11. Enterprise Release Candidate

Use this when a model is close to release and you need one package for engineering, governance, and PR review.

```powershell
.\plugins\powerbi-desktop\scripts\New-PowerBIReleaseCandidatePack.ps1 `
  -Path .\plugins\powerbi-desktop\examples\sample-model `
  -OutputDirectory .\powerbi-release-candidate-pack `
  -SkipLive
```

The package includes unified review, Max AI review, service scanner, semantic tests, model risk heatmap, and PR release comment. See [Enterprise AI features](enterprise-ai-features.md).

## 12. Business Process Data Quality

Use this when you need local evidence for standard process data problems such as Order-to-Cash, Procure-to-Pay, Record-to-Report, Hire-to-Retire, Plan-to-Produce, Forecast-to-Deliver, Service-to-Cash, Issue-to-Resolution, Lead-to-Opportunity, or Quote-to-Order.

```powershell
.\plugins\powerbi-desktop\scripts\New-PowerBIProcessDataMapping.ps1 `
  -Path .\plugins\powerbi-desktop\examples\sample-model `
  -DataPath .\plugins\powerbi-desktop\examples\business-process-data `
  -OutputPath .\process-data-mapping.json `
  -Json

.\plugins\powerbi-desktop\scripts\Invoke-PowerBIBusinessProcessDataQuality.ps1 `
  -Path .\plugins\powerbi-desktop\examples\sample-model `
  -DataPath .\plugins\powerbi-desktop\examples\business-process-data `
  -OutputDirectory .\powerbi-business-process-dq `
  -ProcessPack All
```

Use the standalone wrapper when you want a distributable process-DQ package:

```powershell
.\plugins\powerbi-desktop\scripts\New-PowerBIBusinessProcessDQPack.ps1 `
  -Path .\plugins\powerbi-desktop\examples\sample-model `
  -DataPath .\plugins\powerbi-desktop\examples\business-process-data `
  -OutputDirectory .\powerbi-business-process-dq
```

The workflow is deterministic and local-first. It validates local CSV/JSON exports and local Power BI metadata, but it does not sign in to ERP systems, query databases, publish to Power BI Service, or mutate PBIX files.

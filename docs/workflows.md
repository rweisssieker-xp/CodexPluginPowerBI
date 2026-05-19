# Workflows

This page describes practical end-to-end flows.

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

## 4. Live Desktop Review

Open Power BI Desktop with the model first. Then run:

```powershell
.\plugins\powerbi-desktop\scripts\Get-PowerBIDesktopLiveConnection.ps1
.\plugins\powerbi-desktop\scripts\Invoke-PowerBILiveAutoReview.ps1 -OutputDirectory .\powerbi-live-auto-review
```

Use live mode when you need validation against the currently open Desktop model, not just source files.

## 5. Max AI/KI Review

Use this when you want the full USP package.

```powershell
.\plugins\powerbi-desktop\scripts\Invoke-PowerBIMaxAIReview.ps1 `
  -Path .\plugins\powerbi-desktop\examples\sample-model `
  -OutputDirectory .\powerbi-max-ai-review
```

This package focuses on fix loops, Copilot readiness, data contracts, Fabric risk, visual intent, root-cause graphs, KPI trust, review memory, natural-language PBIP authoring, governance rule mining, explainable refactoring, and decision simulation.

## 6. PBIP Draft And Apply

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

## 7. Release Gate

Run a trust gate before merging model changes:

```powershell
.\plugins\powerbi-desktop\scripts\Test-PowerBIModelBestPractices.ps1 `
  -Path .\plugins\powerbi-desktop\examples\sample-model `
  -OutputPath .\powerbi-model-best-practices.md

.\plugins\powerbi-desktop\scripts\New-PowerBITrustReleaseGate.ps1 `
  -Path .\plugins\powerbi-desktop\examples\sample-model `
  -OutputPath .\powerbi-trust-release-gate.md

.\plugins\powerbi-desktop\scripts\New-PowerBIPRReleaseComment.ps1 `
  -Path .\plugins\powerbi-desktop\examples\sample-model `
  -OutputPath .\powerbi-pr-comment.md
```

## 8. Fabric Readiness

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

## 9. Enterprise Release Candidate

Use this when a model is close to release and you need one package for engineering, governance, and PR review.

```powershell
.\plugins\powerbi-desktop\scripts\New-PowerBIReleaseCandidatePack.ps1 `
  -Path .\plugins\powerbi-desktop\examples\sample-model `
  -OutputDirectory .\powerbi-release-candidate-pack `
  -SkipLive
```

The package includes unified review, Max AI review, service scanner, semantic tests, model risk heatmap, and PR release comment. See [Enterprise AI features](enterprise-ai-features.md).

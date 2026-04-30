# Fabric Planning

The plugin includes Fabric-oriented planning features without requiring Fabric credentials.

## What It Does

- Scores model readiness for Fabric-style operational use.
- Simulates deployment risk from model, governance, and report signals.
- Drafts service integration plans.
- Drafts incremental refresh and aggregation guidance.
- Helps prepare PBIP/TMDL source-control workflows.
- Produces release artifacts for PRs and governance review.

## What It Does Not Do

- It does not sign in to a tenant.
- It does not publish datasets, semantic models, reports, or apps.
- It does not modify Fabric workspaces.
- It does not refresh credentials.
- It does not create capacities, workspaces, pipelines, or lakehouses.

## Core Commands

```powershell
.\plugins\powerbi-desktop\scripts\New-PowerBIFabricReadinessPlan.ps1 `
  -Path .\plugins\powerbi-desktop\examples\sample-model `
  -OutputPath .\powerbi-fabric-readiness.md

.\plugins\powerbi-desktop\scripts\New-PowerBIFabricDeploymentRiskSimulator.ps1 `
  -Path .\plugins\powerbi-desktop\examples\sample-model `
  -OutputPath .\powerbi-fabric-deployment-risk.md

.\plugins\powerbi-desktop\scripts\New-PowerBIServiceIntegrationPlan.ps1 `
  -Path .\plugins\powerbi-desktop\examples\sample-model `
  -OutputPath .\powerbi-service-integration-plan.md
```

## Incremental Refresh And Aggregations

```powershell
.\plugins\powerbi-desktop\scripts\New-PowerBIIncrementalRefreshDraft.ps1 `
  -TableName FactSales `
  -DateColumn OrderDate `
  -OutputPath .\powerbi-incremental-refresh.md

.\plugins\powerbi-desktop\scripts\New-PowerBIAggregationDraft.ps1 `
  -DetailTable FactSales `
  -AggregationTable AggSalesMonth `
  -OutputPath .\powerbi-aggregation-draft.md
```

## Recommended Fabric Gate

Before moving a model toward Fabric deployment:

1. Run unified review.
2. Run Max AI review.
3. Run Fabric readiness.
4. Run deployment risk simulation.
5. Run trust release gate.
6. Attach the PR release comment to the change request.

```powershell
.\plugins\powerbi-desktop\scripts\New-PowerBITrustReleaseGate.ps1 `
  -Path .\plugins\powerbi-desktop\examples\sample-model `
  -OutputPath .\powerbi-trust-release-gate.md

.\plugins\powerbi-desktop\scripts\New-PowerBIPRReleaseComment.ps1 `
  -Path .\plugins\powerbi-desktop\examples\sample-model `
  -OutputPath .\powerbi-pr-comment.md
```

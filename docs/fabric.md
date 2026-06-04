# Fabric Live Read-Only And Planning

The plugin includes Fabric-oriented planning plus an optional read-only snapshot layer. Fabric live v1 is deliberately narrow: token-file auth, GET-only metadata reads, local snapshots, and no Fabric mutation.

## What It Does

- Creates access plans for Fabric read-only review.
- Imports workspace and tenant snapshots from Fabric metadata or local fixtures.
- Scores model readiness for Fabric-style operational use.
- Simulates deployment risk from model, governance, and report signals.
- Generates Fabric portfolio, deployment, operations, governance, security, and executive evidence packs.
- Drafts service integration plans.
- Drafts incremental refresh and aggregation guidance.
- Helps prepare PBIP/TMDL source-control workflows.
- Produces release artifacts for PRs and governance review.

## What It Does Not Do

- It does not perform implicit sign-in.
- It does not publish datasets, semantic models, reports, or apps.
- It does not modify Fabric workspaces.
- It does not promote, refresh, rebind, delete, endorse, or mutate Fabric artifacts.
- It does not refresh credentials.
- It does not create capacities, workspaces, pipelines, or lakehouses.

## Fabric Live Read-Only Snapshot Workflow

Use an access plan before reading live metadata:

```powershell
.\plugins\powerbi-desktop\scripts\Get-PowerBIFabricAccessPlan.ps1 `
  -WorkspaceName "Target Workspace" `
  -AccessTokenPath .\token.txt `
  -Json
```

Import a local workspace snapshot only when the token file and workspace target are explicit:

```powershell
.\plugins\powerbi-desktop\scripts\Import-PowerBIFabricWorkspaceSnapshot.ps1 `
  -WorkspaceName "Target Workspace" `
  -AccessTokenPath .\token.txt `
  -OutputDirectory .\fabric-snapshot
```

For offline, CI, and marketplace demos, use fixtures under `plugins\powerbi-desktop\examples\fabric-snapshot` instead of a token:

```powershell
.\plugins\powerbi-desktop\scripts\New-PowerBIReleaseCandidatePack.ps1 `
  -Path .\plugins\powerbi-desktop\examples\sample-model `
  -SnapshotDirectory .\plugins\powerbi-desktop\examples\fabric-snapshot\minimal `
  -IncludeFabricLiveQa `
  -IncludeFabricPortfolioQa `
  -IncludeFabricDeploymentQa `
  -IncludeFabricOperationsQa `
  -IncludeFabricGovernanceQa `
  -IncludeFabricExecutiveQa
```

If live QA is requested without enough access information, the release pack records `NeedsAccessPlan` and writes an access plan instead of failing hidden or attempting login.

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
3. Import or attach a Fabric snapshot when service evidence is required.
4. Run Fabric readiness and Fabric deployment QA.
5. Run trust release gate.
6. Generate the release candidate pack with the separated Fabric QA switches needed by the release board.
7. Attach the PR release comment to the change request.

```powershell
.\plugins\powerbi-desktop\scripts\New-PowerBITrustReleaseGate.ps1 `
  -Path .\plugins\powerbi-desktop\examples\sample-model `
  -OutputPath .\powerbi-trust-release-gate.md

.\plugins\powerbi-desktop\scripts\New-PowerBIPRReleaseComment.ps1 `
  -Path .\plugins\powerbi-desktop\examples\sample-model `
  -OutputPath .\powerbi-pr-comment.md
```

# Enterprise AI Features

These features extend the plugin from local model review into enterprise release engineering. Defaults remain local and safe: tenant calls and model writes are not performed implicitly.

## Release Candidate Pack

```powershell
.\plugins\powerbi-desktop\scripts\New-PowerBIReleaseCandidatePack.ps1 `
  -Path .\plugins\powerbi-desktop\examples\sample-model `
  -OutputDirectory .\powerbi-release-candidate-pack `
  -SkipLive `
  -IncludeAnalyticalQa
```

Creates one release index with unified review, Max AI review, service scanner, semantic tests, model risk heatmap, and PR release comment. Add `-IncludeAnalyticalQa` when the handoff needs methodology validation, metric change diagnosis, and an analytical release report. Add `-IncludeFabricLiveQa` with the separated Fabric switches when Fabric service snapshot evidence is required.

The pack is the enterprise handoff artifact. Its `summary.json` combines the release gate decision, open P0/P1 counts, pending semantic test count, live status, PBIP roundtrip status, rollback readiness, service scanner evidence, risk heatmap, trust debt, RLS leakage, capacity risk, usage trust signals, and optional analytical QA status. Use `-SkipLive` for deterministic offline packaging; omit it when Desktop live evidence is required.

Fabric live read-only QA is snapshot-first:

```powershell
.\plugins\powerbi-desktop\scripts\New-PowerBIReleaseCandidatePack.ps1 `
  -Path . `
  -SnapshotDirectory .\fabric-snapshot `
  -IncludeFabricLiveQa `
  -IncludeFabricPortfolioQa `
  -IncludeFabricDeploymentQa `
  -IncludeFabricOperationsQa `
  -IncludeFabricGovernanceQa `
  -IncludeFabricExecutiveQa
```

Use `Get-PowerBIFabricAccessPlan.ps1` before live reads. Fabric v1 is read-only, token-file based, and never publishes, promotes, refreshes, rebinds, deletes, or writes endorsements.

## Fabric And Service

```powershell
.\plugins\powerbi-desktop\scripts\Get-PowerBIFabricWorkspaceInventory.ps1 -WorkspaceName "Finance BI" -Json
.\plugins\powerbi-desktop\scripts\New-PowerBIServiceScanner.ps1 -Path .\MyModel -WorkspaceName "Finance BI"
```

`Get-PowerBIFabricWorkspaceInventory.ps1` defaults to `OfflinePlan`. REST mode requires explicit `-UseRest` and a token file path; it now performs GET-only reads for workspace, report, dataset, dashboard, and recent refresh-history metadata. The scanner creates governance findings for ownership, refresh, sensitivity, endorsement, source control, and trust gate status.

Use the maturity map when a release board needs to separate live evidence from plans, drafts, snapshots, and simulations:

```powershell
.\plugins\powerbi-desktop\scripts\New-PowerBIFeatureMaturityMap.ps1 -OutputPath .\powerbi-feature-maturity.md
```

## Safe Write Planning

```powershell
.\plugins\powerbi-desktop\scripts\New-PowerBITomWritePlan.ps1 `
  -Operation AddMeasure `
  -TableName Sales `
  -ObjectName "Average Sales" `
  -Expression "DIVIDE([Total Sales], COUNTROWS('Sales'))"
```

The TOM/TMSL plan is dry-run by default. It documents required gates: explicit endpoint, backup, diff, rollback, and confirmation.

## Layout And UX

```powershell
.\plugins\powerbi-desktop\scripts\Optimize-PowerBIReportLayout.ps1 -PageName "Executive Overview" -VisualCount 5
.\plugins\powerbi-desktop\scripts\New-PowerBIReportScreenshotUXReview.ps1 -ImagePath .\report.png
.\plugins\powerbi-desktop\scripts\New-PowerBIVisualMeasureImpactMap.ps1 -Path .\MyModel
.\plugins\powerbi-desktop\scripts\New-PowerBIVisualIntentAnalyzer.ps1 -Path .\MyModel
```

The layout optimizer creates governed placement fixes for PBIP/report JSON workflows. Screenshot review gives structured UX, accessibility, and executive-fit checks. `Test-PowerBIReportRenderReadiness.ps1 -ScreenshotPath .\report.png` marks the evidence as `EvidenceBacked` when report metadata and screenshot evidence are both available; automated publish remains intentionally disabled.

Report and visual intelligence works at two levels:

- Metadata review maps measures to detected visual references and flags risky visual choices when PBIP report JSON is available.
- Screenshot review adds visual QA evidence for spacing, hierarchy, accessibility, executive fit, and follow-up capture needs.

When report metadata is unavailable, the metadata tools return a non-destructive availability status instead of invalidating the model review.

## Semantic Tests And Performance

```powershell
.\plugins\powerbi-desktop\scripts\Invoke-PowerBISemanticTestRunner.ps1 -Path .\MyModel
.\plugins\powerbi-desktop\scripts\Compare-PowerBIMeasureBehavior.ps1 -BaselineResultsPath .\baseline.json -CurrentResultsPath .\current.json
.\plugins\powerbi-desktop\scripts\Import-PowerBIPerformanceTrace.ps1 -Path .\MyModel -TracePath .\trace.json
.\plugins\powerbi-desktop\scripts\Import-PowerBIVertiPaqAnalyzer.ps1 -Path .\MyModel -VpaxPath .\model.vpax
```

Semantic tests generate measure-level expectations when no expectation file exists. Performance and VertiPaq importers can consume exported traces, but also provide deterministic fallback guidance when exports are not available.

The Semantic Test Runner reads `measure-expectations.json` when present. Each expectation can define:

- `measure`: the measure under test.
- `expected`: the expected scalar value, or an existence-only check when no expected value is supplied.
- `tolerance`: the acceptable numeric variance.
- `filters` or `filterContext`: the context for generated DAX.

Without expectations, the runner creates generated placeholders so teams can see coverage gaps. Pending live DAX checks normally warn; add `-FailOnPending` when CI should fail until a live server or result file supplies evidence.

Measure Behavior Diff compares actual outcomes rather than only metadata. It supports baseline/current result files, live baseline/current servers, or plan-only model diffs. `Passed` means current values match within tolerance, `Failed` means a value/context changed beyond tolerance or exists only on one side, and `NotAvailable` means the script produced a validation plan but did not receive comparable live or result-file evidence.

## Governance And Change Control

```powershell
.\plugins\powerbi-desktop\scripts\New-PowerBIGovernancePolicyPack.ps1 -Profile EnterpriseBI
.\plugins\powerbi-desktop\scripts\Update-PowerBIChangeJournal.ps1 -Title "Refactor Total Sales" -Status proposed
.\plugins\powerbi-desktop\scripts\New-PowerBIModelRiskHeatmap.ps1 -Path .\MyModel
```

Policy packs provide profile-specific rule sets for Enterprise BI, Finance, Healthcare, Executive Reporting, Self-Service BI, and Fabric Premium. The AI change journal records proposed, accepted, rejected, applied, and verified decisions. The model risk heatmap aggregates DAX, inspectability, service, storage, and release-readiness risk.

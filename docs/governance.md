# Governance

Governance in this plugin is rule-driven and local. Rules live in `plugins/powerbi-desktop/rules`.

## Rule Files

- `powerbi-governance-rules.json`: configurable DAX, Power Query, naming, and model-review rules.
- `powerbi-trust-rules.json`: release-trust and model best-practice rules.
- `powerbi-golden-baselines.json`: deterministic baseline expectations for sample-model regression tests.

## Best-Practice Checks

```powershell
.\plugins\powerbi-desktop\scripts\Test-PowerBIModelBestPractices.ps1 `
  -Path .\plugins\powerbi-desktop\examples\sample-model `
  -OutputPath .\powerbi-model-best-practices.md
```

Use this when a model change needs a configurable quality gate.

## Golden Baselines

```powershell
.\plugins\powerbi-desktop\scripts\Test-PowerBIGoldenBaselines.ps1
```

Golden baselines protect the sample model from accidental semantic regressions in tests. They are not a replacement for model-specific tests in real projects.

## Release Gates

```powershell
.\plugins\powerbi-desktop\scripts\New-PowerBITrustReleaseGate.ps1 `
  -Path .\plugins\powerbi-desktop\examples\sample-model `
  -OutputPath .\powerbi-trust-release-gate.md
```

The release gate creates a Go/Warn/No-Go decision artifact based on model, trust, and risk signals.

## Gate Model

The gate model is intentionally explicit:

- P0 guided fixes are release blockers when `blockOnP0` or `blockOnOpenP0` is enabled.
- P1 guided fixes create a Warn decision when `warnOnP1` or `warnOnOpenP1` is enabled.
- Pending semantic tests create a warning by default. They become No-Go when `blockOnPendingSemanticTests` is enabled or when the semantic runner is executed with `-FailOnPending`.
- Live validation can be optional or blocking. `warnOnLiveUnavailable` records missing Desktop/XMLA evidence as Warn; `blockOnLiveUnavailable` or `-TreatLiveUnavailableAsNoGo` promotes that condition to No-Go.
- Machine-readable JSON is required by the default trust rules so CI, PR comments, and release candidate packs can consume the same evidence as humans.

The main switch locations are:

- `plugins/powerbi-desktop/rules/powerbi-trust-rules.json`
- `plugins/powerbi-desktop/rules/powerbi-governance-rules.json`

Typical CI-oriented invocation:

```powershell
.\plugins\powerbi-desktop\scripts\New-PowerBITrustReleaseGate.ps1 `
  -Path .\plugins\powerbi-desktop\examples\sample-model `
  -CheckLiveAvailability `
  -OutputPath .\powerbi-trust-release-gate.json `
  -Json
```

Use `-TreatLiveUnavailableAsNoGo` only when the release policy requires live Desktop/XMLA evidence for every candidate.

## Machine-Readable Results

Governance artifacts should be written as JSON when another process will make a decision from them:

```powershell
.\plugins\powerbi-desktop\scripts\Invoke-PowerBISemanticTestRunner.ps1 `
  -Path .\plugins\powerbi-desktop\examples\sample-model `
  -OutputPath .\semantic-tests.json `
  -Json

.\plugins\powerbi-desktop\scripts\New-PowerBIReleaseCandidatePack.ps1 `
  -Path .\plugins\powerbi-desktop\examples\sample-model `
  -OutputDirectory .\powerbi-release-candidate-pack `
  -SkipLive
```

The release candidate pack summary carries the gate decision, fail/warn counts, open P0/P1 counts, pending semantic test count, live status, PBIP roundtrip status, and rollback readiness.

## Data Contracts

```powershell
.\plugins\powerbi-desktop\scripts\New-PowerBIDataContract.ps1 `
  -Path .\plugins\powerbi-desktop\examples\sample-model `
  -OutputPath .\powerbi-data-contract.md
```

Data contracts make assumptions explicit: key measures, tables, owner context, refresh expectations, and risk areas.

## Governance Rule Mining

```powershell
.\plugins\powerbi-desktop\scripts\New-PowerBIGovernanceRuleMiner.ps1 `
  -Path .\plugins\powerbi-desktop\examples\sample-model `
  -OutputPath .\powerbi-governance-rule-miner.md
```

Rule mining proposes new governance rules from repeated findings. Treat the output as a draft and review it before changing rule JSON.

## Review Memory

```powershell
.\plugins\powerbi-desktop\scripts\Update-PowerBIReviewMemory.ps1 `
  -Path .\plugins\powerbi-desktop\examples\sample-model `
  -MemoryPath .\powerbi-review-memory.json
```

Review memory is local state. It helps repeat reviews retain context without calling external services.

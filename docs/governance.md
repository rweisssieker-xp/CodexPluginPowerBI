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

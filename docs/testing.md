# Testing

All plugin tests are launched from the dedicated test directory:

```powershell
.\plugins\powerbi-desktop\tests\Run-PowerBITests.ps1
```

The runner executes:

- smoke tests through `scripts\Test-PowerBIPlugin.ps1`
- golden baselines through `scripts\Test-PowerBIGoldenBaselines.ps1`
- Pester specs from `tests\pester`

Current focused Pester specs include:

- `PowerBIPlugin.Tests.ps1`
- `SemanticRunner.Tests.ps1`
- `ReportVisualIntelligence.Tests.ps1`
- `GuidedFixLoop.Tests.ps1`
- `AIForecast.Tests.ps1`
- `BusinessProcessDQ.Tests.ps1`

Fabric v3 coverage is included in `PowerBIPlugin.Tests.ps1`. It verifies the read-only access plan, GET-only REST guardrail, token redaction, snapshot import from local fixtures, stable schemas for Fabric USP scripts, and Release Candidate Pack behavior for snapshot-only and `NeedsAccessPlan` paths.

To run only the CI-style smoke and golden baseline checks:

```powershell
.\plugins\powerbi-desktop\tests\Run-PowerBITests.ps1 -SkipPester
```

To run Pester directly:

```powershell
Invoke-Pester .\plugins\powerbi-desktop\tests\pester
```

To run a single focused spec:

```powershell
Invoke-Pester .\plugins\powerbi-desktop\tests\pester\SemanticRunner.Tests.ps1
Invoke-Pester .\plugins\powerbi-desktop\tests\pester\ReportVisualIntelligence.Tests.ps1
Invoke-Pester .\plugins\powerbi-desktop\tests\pester\GuidedFixLoop.Tests.ps1
Invoke-Pester .\plugins\powerbi-desktop\tests\pester\BusinessProcessDQ.Tests.ps1
```

To run the documentation coverage gate used by CI:

```powershell
.\plugins\powerbi-desktop\scripts\Test-PowerBIDocumentationCoverage.ps1
```

This gate checks that script files are mentioned in README/docs/SKILL/plugin metadata, rejects stale numbered-USP and legacy semantic test runner claims, verifies that `New-PowerBILiveExecutiveNarrative.ps1` is documented, and covers the Fabric v3 script surface.

Generated test outputs are written under `plugins\powerbi-desktop\tmp` and should not be committed.

Business process DQ smoke coverage lives in `scripts\Test-PowerBIPlugin.ps1`. It asserts that `Invoke-PowerBIBusinessProcessDataQuality.ps1`, `New-PowerBIProcessDataMapping.ps1`, and `New-PowerBIBusinessProcessDQPack.ps1` exist, that all process rule packs parse as `codex.powerbi.processRulePack.v1`, and that sample CSV exports produce deterministic high, medium, and mapping findings.

Fabric snapshot fixtures live under `plugins\powerbi-desktop\examples\fabric-snapshot` and cover minimal, portfolio-risk, deployment-drift, refresh-failures, security-exposure, and executive-war-room scenarios.

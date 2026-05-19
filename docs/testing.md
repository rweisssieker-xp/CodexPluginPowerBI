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
```

To run the documentation coverage gate used by CI:

```powershell
.\plugins\powerbi-desktop\scripts\Test-PowerBIDocumentationCoverage.ps1
```

This gate checks that script files are mentioned in README/docs/SKILL/plugin metadata, rejects stale numbered-USP and legacy semantic test runner claims, and verifies that `New-PowerBILiveExecutiveNarrative.ps1` is documented.

Generated test outputs are written under `plugins\powerbi-desktop\tmp` and should not be committed.

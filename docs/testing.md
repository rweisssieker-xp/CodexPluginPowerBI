# Testing

All plugin tests are launched from the dedicated test directory:

```powershell
.\plugins\powerbi-desktop\tests\Run-PowerBITests.ps1
```

The runner executes:

- smoke tests through `scripts\Test-PowerBIPlugin.ps1`
- golden baselines through `scripts\Test-PowerBIGoldenBaselines.ps1`
- Pester specs from `tests\pester`

To run only the CI-style smoke and golden baseline checks:

```powershell
.\plugins\powerbi-desktop\tests\Run-PowerBITests.ps1 -SkipPester
```

To run Pester directly:

```powershell
Invoke-Pester .\plugins\powerbi-desktop\tests\pester
```

Generated test outputs are written under `plugins\powerbi-desktop\tmp` and should not be committed.

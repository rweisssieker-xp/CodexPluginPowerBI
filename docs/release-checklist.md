# Release Checklist

Before tagging a stable release:

- Run `.\plugins\powerbi-desktop\tests\Run-PowerBITests.ps1`.
- Run `.\plugins\powerbi-desktop\scripts\Test-PowerBIDocumentationCoverage.ps1` and resolve missing script documentation or stale claims.
- Run `.\plugins\powerbi-desktop\scripts\Invoke-PowerBIMaxAIReview.ps1 -Path .\plugins\powerbi-desktop\examples\sample-model -OutputDirectory .\powerbi-max-ai-review` for a full AI artifact check before release.
- Run `.\plugins\powerbi-desktop\scripts\New-PowerBIReleaseCandidatePack.ps1 -Path .\plugins\powerbi-desktop\examples\sample-model -OutputDirectory .\powerbi-release-candidate -IncludeAnalyticalQa` and review the generated gate summary, methodology validation, metric diagnosis, and analytical release report.
- Run the Fabric snapshot pack when Fabric evidence is part of the release: `.\plugins\powerbi-desktop\scripts\New-PowerBIReleaseCandidatePack.ps1 -Path .\plugins\powerbi-desktop\examples\sample-model -OutputDirectory .\powerbi-release-candidate -SnapshotDirectory .\plugins\powerbi-desktop\examples\fabric-snapshot\minimal -IncludeFabricLiveQa -IncludeFabricPortfolioQa -IncludeFabricDeploymentQa -IncludeFabricOperationsQa -IncludeFabricGovernanceQa -IncludeFabricExecutiveQa`.
- Confirm Fabric v1 stayed read-only: no publish, promote, refresh trigger, rebind, delete, or endorsement write.
- Run semantic tests with pending live checks treated as failures before release: `.\plugins\powerbi-desktop\scripts\Invoke-PowerBISemanticTestRunner.ps1 -Path .\plugins\powerbi-desktop\examples\sample-model -FailOnPending`.
- Confirm PBIP roundtrip readiness with `Get-PowerBIPBIPStructure.ps1` and `New-PowerBIPBIXCompileWorkflow.ps1`; do not claim automated compile readiness when `pbi-tools` is missing or PBIP structure is incomplete.
- Confirm generated review outputs are not staged.
- Confirm `plugins/powerbi-desktop/.codex-plugin/plugin.json` parses.
- Confirm `plugin.json` claims match the documented script catalog and do not contain stale numbered-USP wording or legacy semantic test runner schema names.
- Confirm `CHANGELOG.md` has an entry for the release version.
- Create and push a Git tag such as `v1.0.0`.

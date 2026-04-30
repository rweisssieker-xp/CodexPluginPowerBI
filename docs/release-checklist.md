# Release Checklist

Before tagging a stable release:

- Run `.\plugins\powerbi-desktop\tests\Run-PowerBITests.ps1`.
- Run `.\plugins\powerbi-desktop\scripts\Invoke-PowerBIMaxAIReview.ps1 -Path .\plugins\powerbi-desktop\examples\sample-model -OutputDirectory .\powerbi-max-ai-review` for a full AI/KI artifact check before release.
- Confirm generated review outputs are not staged.
- Confirm `plugins/powerbi-desktop/.codex-plugin/plugin.json` parses.
- Confirm `CHANGELOG.md` has an entry for the release version.
- Create and push a Git tag such as `v1.0.0`.

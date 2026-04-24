# Release Checklist

Before tagging a stable release:

- Run `.\plugins\powerbi-desktop\scripts\Test-PowerBIPlugin.ps1`.
- Confirm generated review outputs are not staged.
- Confirm `plugins/powerbi-desktop/.codex-plugin/plugin.json` parses.
- Confirm `CHANGELOG.md` has an entry for the release version.
- Create and push a Git tag such as `v1.0.0`.


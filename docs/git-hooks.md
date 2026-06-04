# Git Hooks

The repository includes versioned Git hooks under `.githooks`.

## Install

```powershell
.\scripts\Install-GitHooks.ps1
```

This sets:

```powershell
git config core.hooksPath .githooks
```

To disable the local hook path:

```powershell
.\scripts\Install-GitHooks.ps1 -Unset
```

## Hooks

- `pre-commit`: parses `plugin.json`, parses `.agents/plugins/marketplace.json`, blocks staged generated review outputs and Power BI binaries, and runs documentation coverage.
- `pre-push`: runs the same checks plus golden baselines. Set `POWERBI_HOOK_RUN_PESTER=1` to add local Pester specs before push.

The full smoke and full Pester suite remain part of CI and the release checklist because they can take significantly longer on local workstations.

## Safety Boundary

Hooks do not mutate Power BI files, do not connect to Fabric, and do not install external dependencies. They only validate local repository state.

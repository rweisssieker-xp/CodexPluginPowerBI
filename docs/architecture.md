# Architecture

The plugin is a local-first Power BI engineering workbench for Codex. It gives Codex a structured command surface for inspecting, documenting, reviewing, and safely drafting changes for Power BI Desktop and Fabric-oriented projects.

## Design Principles

- Local-first: scripts read local files and the local Power BI Desktop endpoint.
- Text-first: durable edits target PBIP, TMDL, JSON, Power Query, and other text-based artifacts.
- Read-only live access: live Desktop helpers query metadata and DAX through the local endpoint but do not mutate the open model.
- Explicit apply gates: PBIP changes are generated as drafts and only written when an apply script is called with `-Apply`.
- Generated artifacts: reviews produce Markdown and JSON outputs that can be attached to PRs, release gates, or engineering discussions.
- Fabric-aware without hidden deployment: Fabric scripts plan, score, and simulate readiness. They do not sign in, publish, refresh credentials, or modify workspaces.

## Layers

1. Codex skill layer

   `plugins/powerbi-desktop/skills/powerbi-desktop/SKILL.md` tells Codex how to reason about Power BI Desktop, PBIP, TMDL, DAX, Power Query, Fabric planning, and local safety boundaries.

2. Script layer

   `plugins/powerbi-desktop/scripts` contains the PowerShell command surface. Scripts are deterministic where possible and return Markdown or JSON for review automation.

3. Rule layer

   `plugins/powerbi-desktop/rules` contains configurable governance, trust, and baseline rules. This keeps policy separate from script logic.

4. Example and test layer

   `plugins/powerbi-desktop/examples` supplies sample models. `plugins/powerbi-desktop/tests` validates script presence, deterministic behavior, package creation, baselines, and Pester specs.

5. Documentation layer

   `docs` documents operating modes, workflows, command families, safety boundaries, and troubleshooting.

## Execution Modes

Offline project mode inspects a file system path such as a PBIP folder, TMDL folder, extracted model, or sample project.

```powershell
.\plugins\powerbi-desktop\scripts\Invoke-PowerBIUnifiedReview.ps1 `
  -Path .\plugins\powerbi-desktop\examples\sample-model `
  -OutputDirectory .\powerbi-unified-review
```

Live Desktop mode discovers a running Power BI Desktop instance and uses the local XMLA/ADOMD endpoint for metadata, DMV, and DAX validation.

```powershell
.\plugins\powerbi-desktop\scripts\Get-PowerBIDesktopLiveConnection.ps1
.\plugins\powerbi-desktop\scripts\Invoke-PowerBILiveAutoReview.ps1 -OutputDirectory .\powerbi-live-auto-review
```

PBIP authoring mode generates or applies text artifacts in PBIP/TMDL-compatible structures.

```powershell
.\plugins\powerbi-desktop\scripts\New-PowerBIMeasureDraft.ps1 `
  -TableName Sales `
  -MeasureName "Average Sales" `
  -Expression "DIVIDE([Total Sales], COUNTROWS('Sales'))"
```

Fabric planning mode produces readiness and deployment-risk outputs without connecting to Fabric tenants.

```powershell
.\plugins\powerbi-desktop\scripts\New-PowerBIFabricReadinessPlan.ps1 `
  -Path .\plugins\powerbi-desktop\examples\sample-model `
  -OutputPath .\powerbi-fabric-readiness.md
```

## Safety Boundaries

- The plugin does not directly edit binary `.pbix` files.
- Live Desktop scripts are review and validation helpers, not write APIs.
- PBIP apply scripts require explicit `-Apply`.
- Generated review outputs are disposable and reproducible.
- Secrets, credentials, tenant tokens, and Fabric publishing are outside this plugin's default behavior.

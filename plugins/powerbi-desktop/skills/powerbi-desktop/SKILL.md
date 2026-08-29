---
name: powerbi-desktop
description: "Use when reviewing Power BI models or reports, explaining KPI trust, changing PBIP/TMDL safely, or preparing release evidence."
---

# Power BI Desktop

Start from the user's outcome. Use the smallest workflow that answers it, then offer deeper review only when needed.

## Safety Boundaries

- Never modify `.pbix` or `.pbit` binaries. Make changes only in supported PBIP/TMDL/text assets after confirmation.
- Do not publish, sign in, refresh credentials, or change Fabric/Power BI Service content unless explicitly authorized.
- Live Desktop and Fabric workflows are read-only unless the user explicitly requests a supported write path.
- State whether evidence is local, live, snapshot-based, heuristic, or a draft.

## Route By Role

| User goal | Start with | Result |
| --- | --- | --- |
| Understand KPIs and caveats | `Invoke-PowerBIAutoReview.ps1` | metric meaning, quality signals, analysis questions |
| Decide whether to trust a report | `New-PowerBIExecutiveTrustBrief.ps1` | concise decision brief and open risks |
| Change a model safely | `Invoke-PowerBIUnifiedReview.ps1` | risk, dependency impact, validation and PBIP-safe drafts |
| Prepare a release | `New-PowerBIReleaseCandidatePack.ps1` | Go/Warn/No-Go evidence, owners, and rollback guidance |
| Start a governed model | `New-PowerBIModelWizard.ps1` | PBIP-first star schema, KPI, RLS, and report-page design drafts |
| Operate Fabric evidence locally | `Invoke-PowerBIEnterpriseOperationsPack.ps1` | eight labelled operations artifacts without service changes |
| Explain and govern decisions | `Invoke-PowerBIDecisionIntelligencePack.ps1` | Copilot, KPI, scenario, contract, owner and visual evidence |

## Choose The Asset

1. Run `Get-PowerBIInventory.ps1` when the available files are unknown.
2. Prefer `.pbip`, `.tmdl`, `.dax`, `.pq`, `model.bim`, and report JSON for analysis and changes.
3. If Power BI Desktop is open and live validation matters, run `Get-PowerBIDesktopLiveConnection.ps1` first.
4. If only PBIX/PBIT is present, explain the binary boundary and recommend export to PBIP/TMDL for editing.

## Default Workflows

### New model from scratch

Use `New-PowerBIModelWizard.ps1 -ProjectName <name> -BusinessPurpose <goal> -Initialize` to create a reviewable local design pack. The user then creates the actual PBIP in Power BI Desktop, reviews the generated drafts, and explicitly applies approved PBIP/TMDL changes.

### Local review

```powershell
.\plugins\powerbi-desktop\scripts\Invoke-PowerBIAutoReview.ps1 -Path .\your-model -OutputDirectory .\powerbi-auto-review
```

Use for a first pass. It reads local assets and does not modify them.

### Live Desktop review

```powershell
.\plugins\powerbi-desktop\scripts\Invoke-PowerBILiveAutoReview.ps1 -OutputDirectory .\powerbi-live-auto-review
```

Use only when Desktop is open. Report `LiveUnavailable` rather than treating absence as a failed model check.

### Safe authoring

Create drafts first; apply only when the user asks and the target is PBIP/TMDL. Read [authoring and validation](references/authoring.md) for draft types and validation.

### Release evidence

Use `New-PowerBIReleaseCandidatePack.ps1` for a release decision. Read [release workflow](references/release.md) when the release needs Fabric, advanced QA, or sign-off context.

### Enterprise operations evidence

Run `Invoke-PowerBIEnterpriseOperationsPack.ps1` when the user needs Copilot-quality, capacity, Direct Lake, SLO, governance, evidence-bundle, onboarding, or plugin-quality status in one local pack. Supply only exported local snapshots; the pack never connects to Fabric.

Run `Invoke-PowerBIDecisionIntelligencePack.ps1` for the eight decision USPs: answer reliability, KPI comparison, scenario impact, semantic contracts, decision history, exception approval, workspace benchmarking, and visual regression. Treat all outputs as local evidence and require human approval for decisions or remediation.

## References

- Read [review workflow](references/review.md) for diagnostic, KPI, and live-review variants.
- Read [authoring and validation](references/authoring.md) before generating or applying a model/report draft.
- Read [release workflow](references/release.md) for release gates, Fabric snapshots, and governance evidence.
- Use `docs/start-here.md` for user-facing onboarding and `docs/script-catalog.md` only when a specific script is required.

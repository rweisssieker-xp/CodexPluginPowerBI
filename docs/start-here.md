# First 10 Minutes

Use this page when you want a useful Power BI answer quickly. Choose your role, run one workflow, and read the result before expanding the scope.

## 1. Pick Your Starting Question

| If you are … | Ask Codex … | You receive … |
| --- | --- | --- |
| an analyst | “What do these KPIs mean, what can distort them, and what should I analyse next?” | KPI definitions, caveats, and analysis questions. |
| an executive | “Can I use this report for a decision? State the conclusion, evidence, caveats, and next owner.” | A concise decision brief. |
| a Power BI developer | “What are the highest technical risks and the safe change path?” | Findings, dependencies, tests, and drafts. |
| a release owner | “Is this ready to release and what blocks approval?” | A Go/Warn/No-Go recommendation and sign-off actions. |
| a new model owner | “Create a Power BI model plan from this business goal, data sources, KPIs, and security needs.” | A PBIP-first star-schema, KPI, security, and report-page design pack. |

For longer, copy-ready prompts see [role-based entry points](role-based-entry-points.md).

## 2. Run One Suitable Workflow

| Need | Command | What it does |
| --- | --- | --- |
| Fast, local review | `Invoke-PowerBIAutoReview.ps1 -Path .\your-model -OutputDirectory .\powerbi-auto-review` | Inspects text-based Power BI assets and produces an index. |
| Executive trust brief | `New-PowerBIExecutiveTrustBrief.ps1 -Path .\your-model` | Summarizes decision-relevant confidence and caveats. |
| Release evidence | `New-PowerBIReleaseCandidatePack.ps1 -Path .\your-model -OutputDirectory .\powerbi-release-candidate` | Packages tests, risks, ownership, and rollback guidance. |
| Open Desktop model | `Invoke-PowerBILiveAutoReview.ps1 -OutputDirectory .\powerbi-live-auto-review` | Uses the local read-only Desktop endpoint when Power BI Desktop is open. |
| Start a new model | `New-PowerBIModelWizard.ps1 -ProjectName ContosoSales -DataSourcePaths .\sales.csv -BusinessPurpose "Manage sales performance" -Initialize` | Inspects local CSV/JSON sources and creates a star-schema, KPI, query, security, and report design pack before a PBIP is created in Desktop. Any Power BI Desktop connector can instead be declared through `templates/powerbi-data-sources.example.json`. |

Replace `your-model` with a PBIP/TMDL folder or exported text model. A PBIX/PBIT is not modified directly.

## 3. Read the Evidence Label

| Label | Meaning | Appropriate use |
| --- | --- | --- |
| Local | Deterministic inspection of local files. | First review and source-control checks. |
| Live Desktop | Read-only query against the currently open Desktop model. | Validate the model currently being edited. |
| Snapshot | Assessment from saved Fabric/Power BI metadata. | Repeatable governance and CI review. |
| Heuristic | A prioritized signal, not proof of an error. | Triage and human follow-up. |
| Draft | Proposed PBIP/TMDL change, not an applied change. | Review before applying and validating. |

## Next Step

- Need a change? Continue with [PBIP Apply Engine](pbip-apply-engine.md).
- Need release confidence? Continue with [Unified review](unified-review.md) or [release checklist](release-checklist.md).
- Need Fabric evidence? Continue with [Fabric live read-only and planning](fabric.md).
- Need every available command? Use the [script catalog](script-catalog.md).

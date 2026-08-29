# Role-Based Entry Points

This plugin serves different Power BI users. Start with the decision or job to be done, not the underlying script name. Every result should state its evidence maturity: local deterministic analysis, live Desktop read, snapshot-backed evidence, heuristic assessment, or a safe draft.

## Analyst: Understand the numbers

**Goal:** make a report understandable, find data-quality caveats, and identify the next useful analysis.

Ask Codex:

> Explain the KPI definitions in this Power BI project, identify data-quality and interpretation risks, and propose the next analysis.

Recommended workflow: `Invoke-PowerBIAutoReview.ps1`, then `New-PowerBIMetricCatalog.ps1` and `New-PowerBIExecutiveNarrative.ps1`.

**Outcome:** a business-readable metric catalog, visible assumptions and caveats, and prioritized questions. This entry point does not change the model.

## C-level: Decide with confidence

**Goal:** understand whether a dashboard supports a decision, what can invalidate it, and who owns the remaining risk.

Ask Codex:

> Can this report be trusted for an executive decision? Give me a concise brief with the decision status, evidence, caveats, and accountable next actions.

Recommended workflow: `New-PowerBIExecutiveTrustBrief.ps1` plus `New-PowerBITrustReleaseGate.ps1`. Use `New-PowerBIAnalyticalReleaseReport.ps1` when methodology and KPI changes need explaining.

**Outcome:** a decision brief, not a technical audit. It distinguishes verified evidence from assumptions and highlights only the risks that could change the decision.

## Power BI Developer: Change safely

**Goal:** find model/DAX issues, understand impact, and make source-controlled changes without editing a binary PBIX.

Ask Codex:

> Review this PBIP/TMDL project, rank the technical risks, show dependency impact, and create safe drafts for the approved fixes.

Recommended workflow: `Invoke-PowerBIUnifiedReview.ps1`, `New-PowerBIDependencyGraph.ps1`, and the PBIP Apply Engine. Use `Invoke-PowerBISemanticTestRunner.ps1` before release.

**Outcome:** reproducible findings, validation queries, and PBIP/TMDL drafts with rollback guidance. Binary PBIX files remain untouched.

## BI Lead / Release Owner: Govern the release

**Goal:** turn technical evidence into a clear release decision and a short sign-off list.

Ask Codex:

> Prepare a release decision for this Power BI project, including test status, governance risks, unresolved owners, and rollback readiness.

Recommended workflow: `New-PowerBIReleaseCandidatePack.ps1`; add `-IncludeAnalyticalQa` or `-IncludeAdvancedUspQa` only when their evidence is needed.

**Outcome:** a release candidate package with explicit Go/Warn/No-Go status. Snapshot and heuristic findings must not be presented as live validation.

## Product Rules For All Entry Points

- Lead with the audience outcome, then offer the technical artifacts as supporting evidence.
- Default to the smallest workflow that answers the user's question; offer deeper review as the next step.
- Clearly label whether evidence is live, local, snapshot-backed, heuristic, or a draft.
- Never imply that a release gate replaces business-owner sign-off.

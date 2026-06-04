# Codex Marketplace Submission v3.0.0

This document provides the listing copy and submission checklist for publishing the Power BI Desktop plugin on [codex-marketplace.com](https://www.codex-marketplace.com/).

## Repository URL

`https://github.com/rweisssieker-xp/CodexPluginPowerBI`

## Direct Plugin Path

`rweisssieker-xp/CodexPluginPowerBI/plugins/powerbi-desktop`

## Install Command

```powershell
npx codex-marketplace add rweisssieker-xp/CodexPluginPowerBI/plugins/powerbi-desktop --plugin
```

## Marketplace Requirements Covered

- Valid plugin manifest: `plugins/powerbi-desktop/.codex-plugin/plugin.json`
- Repo-level marketplace file: `.agents/plugins/marketplace.json`
- Plugin source path: `./plugins/powerbi-desktop`
- Version: `3.0.0`
- Category: `Productivity`
- Privacy URL: `https://github.com/rweisssieker-xp/CodexPluginPowerBI/blob/main/docs/privacy.md`
- Terms URL: `https://github.com/rweisssieker-xp/CodexPluginPowerBI#license`
- Git tag: `v3.0.0`
- GitHub release: `https://github.com/rweisssieker-xp/CodexPluginPowerBI/releases/tag/v3.0.0`

## Listing Copy

### Name

Power BI Desktop

### Short Description

Local-first Power BI and Fabric read-only engineering workbench for PBIP, DAX, KPI trust, release QA, and governance evidence.

### Long Description

Power BI Desktop turns Codex into a local Power BI and Fabric engineering workbench. It helps teams inspect PBIP/TMDL projects, document semantic models, review DAX and Power Query, validate KPI trust, diagnose metric movement, generate release evidence, and prepare governed Power BI releases without uploading report data by default.

Version 3 adds Fabric Live Read-Only + Snapshot Intelligence. Teams can create token-file access plans, import read-only workspace or tenant snapshots, and run Fabric portfolio, deployment, operations, governance, security, and executive evidence packs against local snapshot data. The Fabric live layer is strictly read-only: it allows GET-only metadata requests, blocks unsafe methods, writes snapshots locally, and does not publish, promote, refresh, rebind, delete, endorse, or mutate Fabric assets.

The plugin also includes Max AI Review packages, analytical release QA, advanced release QA, separated portfolio/compliance/operations packs, Business Process Data Quality packs, PBIP Apply Engine workflows, semantic tests, model risk heatmaps, report/visual intelligence, release candidate packs, and governance-ready Markdown/JSON artifacts for engineering, PR, compliance, and executive handoff.

## Capabilities To Highlight

- Local Power BI, PBIP, TMDL, DAX, Power Query, and report metadata review
- Fabric Live Read-Only access planning with token-file auth
- Fabric workspace and tenant snapshot import
- Fabric portfolio, deployment, operations, governance, security, and executive evidence packs
- Release Candidate Pack with optional separated Fabric QA switches
- KPI trust scoring, semantic tests, metric diagnostics, and analytical release reports
- Advanced evidence graphs, semantic contracts, DAX change risk, RLS trust, UX regression, and migration readiness
- Portfolio command center, deployment gate, certification readiness, tenant hygiene, and cost-to-trust optimization
- Business Process Data Quality packs for local Power BI metadata and local CSV/JSON ERP exports
- PBIP Apply Engine with drafts, manifests, rollback guidance, and roundtrip readiness checks
- Local-first governance artifacts for PRs, release boards, auditors, and business owners

## Conversation Starters

- Run a local Power BI Max AI Review for this PBIP project.
- Create a Fabric live read-only access plan for this workspace.
- Import a Fabric workspace snapshot from my token file and generate portfolio, deployment, operations, governance, and executive evidence packs.
- Build a release candidate pack with KPI trust, semantic tests, analytical QA, advanced QA, Fabric snapshot QA, and process DQ evidence.
- Diagnose why this KPI changed between baseline and current evidence.
- Check this model and local ERP exports for Order-to-Cash data quality issues.
- Create a governed PBIP change plan with rollback guidance and release evidence.
- Explain which KPIs, workspaces, reports, datasets, and owners are release blockers.

## Safety Notes

- Marketplace copy should describe the plugin as local-first and snapshot-first.
- Fabric live v1 uses user-supplied token files only; it does not perform implicit login flows.
- Fabric REST helper permits GET-only requests. Unsafe methods return `BlockedUnsafeMethod`.
- The plugin must not be marketed as publishing, promoting, refreshing, rebinding, deleting, or endorsing Fabric artifacts.
- Business Process Data Quality checks validate visible local metadata and local CSV/JSON exports; they are not a full ERP process-mining replacement without event logs.
- Missing source evidence, missing permissions, or partial Fabric snapshots are modeled as findings or access issues rather than hidden success.

## Submission Steps

1. Open `https://www.codex-marketplace.com/submit`.
2. Sign in with GitHub.
3. Submit `https://github.com/rweisssieker-xp/CodexPluginPowerBI` or the direct tree path for `plugins/powerbi-desktop`.
4. Use `v3.0.0` as the release/tag reference if the form asks for a version.
5. Use the short and long descriptions from this document.
6. Wait for automated scanner checks and reviewer approval.

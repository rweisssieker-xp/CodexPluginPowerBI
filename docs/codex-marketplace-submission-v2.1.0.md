# Codex Marketplace Submission Draft

This draft is for publishing the Power BI Desktop plugin on [codex-marketplace.com](https://www.codex-marketplace.com/).

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
- Version: `2.1.0`
- Category: `Productivity`
- Privacy URL: `https://github.com/rweisssieker-xp/CodexPluginPowerBI/blob/main/docs/privacy.md`
- Terms URL: `https://github.com/rweisssieker-xp/CodexPluginPowerBI#license`
- Git tag: `v2.1.0`

## Listing Copy

### Name

Power BI Desktop

### Short Description

Local-first AI/KI workbench for Power BI Desktop, PBIP, DAX, governance, release evidence, and business process data quality.

### Long Description

Power BI Desktop helps teams inspect, document, govern, and release Power BI projects from local files and local Desktop evidence. It provides Max AI Review packages, semantic tests, KPI trust scoring, release candidate packs, PBIP-safe authoring guidance, visual and narrative intelligence, and Business Process Data Quality packs for standard processes such as Order-to-Cash, Procure-to-Pay, Record-to-Report, Hire-to-Retire, Plan-to-Produce, Forecast-to-Deliver, Service-to-Cash, Issue-to-Resolution, Lead-to-Opportunity, and Quote-to-Order.

The workflow is local-first: it does not sign in to ERP systems, does not publish reports, does not call external APIs, and does not mutate PBIX files without explicit supported workflows. It is designed for deterministic review artifacts, governance evidence, and practical engineering handoff.

## Capabilities To Highlight

- Local Power BI and PBIP review
- DAX and semantic model documentation
- KPI trust scoring and release gates
- Max AI Review with 39 local artifacts
- Business Process Data Quality Packs
- Order-to-Cash, Procure-to-Pay, and Record-to-Report checks
- Local ERP CSV/JSON export validation
- Release Candidate Pack generation
- Governance evidence and owner action tracking

## Conversation Starters

- Run a local Power BI Max AI Review for this project.
- Check this model and local ERP exports for Order-to-Cash data quality issues.
- Create a process data mapping proposal for my CSV exports.
- Build a release candidate pack with KPI trust, semantic tests, and process DQ evidence.
- Explain which KPIs are risky and what owners need to sign off.

## Safety Notes

- Keep the listing clear that the tool is local-first and does not connect to ERP systems or Power BI Service by default.
- Do not market it as a full process-mining replacement without event logs.
- Do not claim it fixes all possible ERP data problems; it detects issues visible in local model metadata or local exports.

## Submission Steps

1. Open `https://www.codex-marketplace.com/submit`.
2. Sign in with GitHub.
3. Submit `https://github.com/rweisssieker-xp/CodexPluginPowerBI` or the direct tree path for `plugins/powerbi-desktop`.
4. Use `v2.1.0` as the release/tag reference if the form asks for a version.
5. Wait for automated scanner checks and reviewer approval.

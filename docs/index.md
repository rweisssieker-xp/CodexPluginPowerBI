# Power BI Desktop Codex Plugin Documentation

This documentation describes the local Codex plugin for Power BI Desktop and Fabric-oriented Power BI engineering work.

## Start Here

- [Getting started](getting-started.md): install path, first checks, first review run.
- [Value proposition and USPs](value-proposition.md): business value, differentiators, best-fit use cases, and positioning.
- [Workflows](workflows.md): practical end-to-end flows for model review, live Desktop review, PBIP authoring, release gates, and Fabric planning.
- [Script catalog](script-catalog.md): command families and when to use each script.
- [Testing](testing.md): local smoke tests, Pester tests, and CI layout.

## Core Capabilities

- [Unified review](unified-review.md): one review package that combines offline PBIP/project review, live Desktop when available, native parity, external-tool awareness, and AI outputs.
- [Max AI review](max-ai-review.md): the high-end AI review pack with 38 USP workflows and 39 artifacts.
- [AI USP workflows](ai-usp-workflows.md): detailed operating model for the AI differentiators.
- [Enterprise AI features](enterprise-ai-features.md): service scanner, release candidate pack, risk heatmap, semantic tests, performance/VertiPaq imports, and change journal.
- [Architecture](architecture.md): local-first design, read-only live access, PBIP write gates, and generated artifacts.
- [PBIP Apply Engine](pbip-apply-engine.md): how draft generation, apply scripts, manifests, and rollback guidance work.

## Power BI Desktop, Fabric, And Governance

- [Live Desktop](live-desktop.md): local XMLA/ADOMD discovery, live DMV/DAX checks, and limitations.
- [Fabric planning](fabric.md): readiness plans, deployment risk simulation, service integration, and what the plugin does not do.
- [Governance](governance.md): rule files, trust gates, golden baselines, data contracts, and memory/rule mining.
- [Business process data quality](business-process-data-quality.md): local Power BI and ERP export rule packs for standard enterprise processes.
- [External Tool installation](external-tool-installation.md): register the Codex Power BI Workbench as a Power BI External Tool.
- [Golden baselines](golden-baselines.md): deterministic regression checks for semantic model changes.

## Operations

- [Privacy](privacy.md): data boundaries and local execution model.
- [Release checklist](release-checklist.md): what to verify before publishing plugin changes.
- [v2.1.0 release notes](release-notes-v2.1.0.md): GitHub release text and verification summary.
- [Codex Marketplace submission draft](codex-marketplace-submission-v2.1.0.md): listing copy, install command, conversation starters, and publishing checklist.
- [Example output](example-output.md): expected generated artifacts.
- [Troubleshooting](troubleshooting.md): common failures and fixes.

## Repository Map

- `plugins/powerbi-desktop/.codex-plugin/plugin.json`: plugin manifest.
- `plugins/powerbi-desktop/skills/powerbi-desktop/SKILL.md`: Codex skill instructions.
- `plugins/powerbi-desktop/scripts`: PowerShell command surface.
- `plugins/powerbi-desktop/rules`: governance, trust, and golden-baseline rule JSON.
- `plugins/powerbi-desktop/examples`: sample PBIP-style projects used by tests and examples.
- `plugins/powerbi-desktop/tests`: test entrypoint and Pester specs.
- `docs`: user and maintainer documentation.

# KPI SLO Action List

## Goal

Create a local, versioned action list for each KPI without changing release decisions or calling external services.

## Configuration

`rules/powerbi-kpi-slos.json` contains one entry per KPI: `metricName`, `owner`, `decisionCritical`, `freshnessTargetHours`, `severity`, and `actionHint`.

Missing entries produce `NeedsOwnerSetup`; they never fail the command.

## Processing

The runner reads the SLO configuration and existing KPI trust, freshness, and drift evidence. It emits `slo-action-list.json` with the status, owner, priority, causes, and next action for each KPI.

## Boundaries

- Local files only; no authentication, notification, publish, refresh, or automatic remediation.
- The action list is advisory and does not alter Go/Warn/No-Go release decisions.
- Existing model assets are read only.

## Verification

Use the sample model and a fixture configuration. Verify that configured KPIs receive their assigned owner, missing configurations are reported, and output remains machine-readable.

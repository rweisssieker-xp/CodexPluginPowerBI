# Example Output

The generated review folders are intentionally ignored by Git. A typical innovation review creates:

- `guided-fix-plan.md`
- `kpi-trust-score.md`
- `trust-release-gate.md`
- `decision-risk-assistant.md`
- `measure-test-plan.md`
- `model-best-practices.md`
- `visual-measure-impact-map.md`

A Fabric-enabled release candidate pack can also attach:

- `fabric-access-plan.json`
- `fabric-workspace-snapshot.json`
- `fabric-portfolio-command-center.md`
- `fabric-deployment-pipeline-gate.md`
- `fabric-refresh-failure-root-cause-advisor.md`
- `fabric-lineage-evidence-graph.md`
- `fabric-executive-war-room.md`

Example release gate summary:

```text
Decision: No-Go
KPI trust score: 56
Low-trust KPI count: 5
P0 guided fixes: 2
```

This means the report should not be published until the failing checks are remediated or explicitly accepted by the report owner.

When Fabric live access is not configured, the pack records `NeedsAccessPlan` and writes the requested access plan instead of attempting a hidden login. When a local Fabric snapshot is supplied, all Fabric QA runs against that snapshot without REST access.

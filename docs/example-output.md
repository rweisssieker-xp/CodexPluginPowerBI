# Example Output

The generated review folders are intentionally ignored by Git. A typical innovation review creates:

- `guided-fix-plan.md`
- `kpi-trust-score.md`
- `trust-release-gate.md`
- `decision-risk-assistant.md`
- `measure-test-plan.md`
- `model-best-practices.md`
- `visual-measure-impact-map.md`

Example release gate summary:

```text
Decision: No-Go
KPI trust score: 56
Low-trust KPI count: 5
P0 guided fixes: 2
```

This means the report should not be published until the failing checks are remediated or explicitly accepted by the report owner.


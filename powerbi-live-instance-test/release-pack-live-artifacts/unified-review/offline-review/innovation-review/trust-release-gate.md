# Power BI Trust Release Gate

Decision: **No-Go**

Release note: Block publish until failing checks are remediated.

## Checks
- [Fail] KPI trust score: 0 - Overall KPI trust score.
- [Pass] Low-trust KPI count: 0 - KPIs below trust score 60.
- [Fail] Open P0 guided fixes: 1 - Open P0 fixes block release.
- [Pass] Open P1 guided fixes: 0 - Open P1 fixes require explicit caveat or waiver.
- [Warn] Governance score: 57 - Model governance scorecard result.
- [Pass] Copilot readiness: 100 - Copilot readiness score.
- [Pass] Pending semantic tests: 0 - Generated, not-run, or live-DAX-pending semantic tests.
- [Warn] Live validation availability: NotChecked - Live validation was not requested.


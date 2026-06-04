# Feature Maturity

Use `New-PowerBIFeatureMaturityMap.ps1` when a reviewer needs to know whether a plugin capability is fully implemented, live-read, snapshot-backed, draft/apply, metadata-only, synthetic, or heuristic simulation.

```powershell
.\plugins\powerbi-desktop\scripts\New-PowerBIFeatureMaturityMap.ps1 -OutputPath .\powerbi-feature-maturity.md
```

## Maturity Values

- `Implemented`: local feature reads real files or metadata and produces deterministic findings.
- `ImplementedWhenDesktopAvailable`: feature uses the open Power BI Desktop XMLA/ADOMD endpoint when available and reports unavailable states otherwise.
- `LiveReadOrSnapshot`: feature can read live service metadata with explicit token-file GET requests, or use local snapshots.
- `SnapshotBacked`: feature runs against live-imported or fixture snapshots.
- `DraftAndApply`: feature creates drafts and applies only to supported text-based PBIP/TMDL artifacts with explicit apply switches.
- `MetadataPlusOptionalScreenshot`: feature uses report metadata and can attach screenshot evidence, but does not automate publish.
- `DraftWithOptionalLiveQuery`: feature creates validation drafts and can execute live validation queries when a Desktop endpoint is available.
- `HeuristicSimulation`: feature models risk or decision impact from available evidence and does not mutate service state.
- `SyntheticTestData`: feature generates deterministic fixture data or expectations for later validation.

## Current High-Impact Upgrades

- Fabric workspace inventory now performs GET-only reads for workspace, report, dataset, dashboard, and recent refresh-history metadata when `-UseRest -AccessTokenPath` are provided.
- Fabric workspace snapshot import can create local snapshot files from the same GET-only metadata surface.
- RLS leakage review can attach live DAX query results with `-CheckLive`.
- Report render readiness emits explicit `evidenceMaturity` and accepts optional screenshot evidence.

The maturity map is not a substitute for tests. It is a release-board aid that prevents draft, simulation, and snapshot-backed features from being mistaken for hidden service automation.

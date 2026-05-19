# Power BI Live Fix Backlog

Risk level: **High**
Risk score: **44**
Items: 4

## [P1] Replace auto date tables with a governed date table
- Theme: Model Design
- Source: `model`
- Why: Detected 72 hidden local date tables. Prefer a governed date table.
- Action: Create or designate a governed calendar table, mark it as date table, remap time-intelligence measures, then disable auto date/time where appropriate.
- Validation: Refresh the model and confirm LocalDateTable object count drops as expected.

## [P2] Reduce metadata finding group: Technical-looking visible measure
- Theme: Metric Governance
- Source: `model`
- Why: Detected 168 occurrences.
- Action: Batch-update measure names, descriptions, visibility, or format strings according to the finding group.
- Validation: Rerun Test-PowerBILiveMetadataGovernance.ps1 and compare finding counts.

## [P2] Reduce metadata finding group: Missing format string
- Theme: Metric Governance
- Source: `model`
- Why: Detected 30 occurrences.
- Action: Batch-update measure names, descriptions, visibility, or format strings according to the finding group.
- Validation: Rerun Test-PowerBILiveMetadataGovernance.ps1 and compare finding counts.

## [P2] Reduce metadata finding group: Missing measure description
- Theme: Metric Governance
- Source: `model`
- Why: Detected 3 occurrences.
- Action: Batch-update measure names, descriptions, visibility, or format strings according to the finding group.
- Validation: Rerun Test-PowerBILiveMetadataGovernance.ps1 and compare finding counts.



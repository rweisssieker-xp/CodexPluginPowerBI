# Power BI Desktop Plugin v3.0.0

Release date: 2026-06-04

## Summary

v3.0.0 adds Fabric Live Read-Only + Snapshot Intelligence on top of the existing local Power BI release QA stack. The release keeps the safety boundary explicit: read-only Fabric metadata, token-file auth, local snapshots, no implicit login, no publish, no promote, no refresh trigger, no rebind, no delete, and no endorsement writes.

## Highlights

- Fabric read-only foundation:
  - `Get-PowerBIFabricAccessPlan.ps1`
  - `Invoke-PowerBIFabricReadOnlyRequest.ps1`
  - `Import-PowerBIFabricWorkspaceSnapshot.ps1`
  - `Import-PowerBIFabricTenantSnapshot.ps1`
- Fabric portfolio, release, deployment, operations, governance, security, and executive evidence packs.
- Release Candidate Pack integration with separate Fabric QA switches for live, portfolio, deployment, operations, governance, and executive evidence.
- Snapshot fixtures for minimal, portfolio-risk, deployment-drift, refresh-failures, security-exposure, and executive-war-room scenarios.
- Marketplace documentation updated for v3.0.0 positioning and safety claims.

## GitHub Release Text

```markdown
## Power BI Desktop Plugin v3.0.0

This release adds Fabric Live Read-Only + Snapshot Intelligence for local-first Power BI release QA.

### Added

- Token-file Fabric access planning.
- GET-only Fabric REST helper with `BlockedUnsafeMethod` protection.
- Workspace and tenant snapshot import.
- Fabric portfolio, deployment, operations, governance, security, and executive evidence packs.
- Release Candidate Pack switches for separated Fabric QA.
- Local Fabric snapshot fixtures and Pester coverage.
- Marketplace v3 documentation and submission copy.

### Safety boundary

- Read-only Fabric metadata only.
- No implicit login flow.
- No publish, promote, refresh trigger, rebind, delete, or endorsement writes.
- Missing Fabric permissions are modeled as access issues or findings.
- Snapshot-first review works without Fabric credentials.

### Verification

- `Test-PowerBIDocumentationCoverage.ps1` passed.
- `Invoke-Pester .\plugins\powerbi-desktop\tests\pester\PowerBIPlugin.Tests.ps1` passed.
- `Test-PowerBIPlugin.ps1` passed.
- `plugin.json` parse check passed.
```

## Verification

- `plugin.json` parse check passed.
- `Test-PowerBIDocumentationCoverage.ps1` passed.
- `Invoke-Pester .\plugins\powerbi-desktop\tests\pester\PowerBIPlugin.Tests.ps1` passed.
- `Test-PowerBIPlugin.ps1` passed.

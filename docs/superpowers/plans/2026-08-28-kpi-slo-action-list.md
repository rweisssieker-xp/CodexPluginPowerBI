# KPI SLO Action List Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a local, owner-specific KPI SLO action list without release blocking or external calls.

**Architecture:** A JSON rule file supplies KPI ownership and SLO targets. A focused PowerShell runner combines those rules with existing trust, freshness, and drift outputs into a machine-readable action list. The release pack may include this artifact without changing its decision.

**Tech Stack:** PowerShell 5.1+, existing Power BI plugin scripts, Pester.

---

### Task 1: Define the versioned SLO configuration

**Files:**
- Create: `plugins/powerbi-desktop/rules/powerbi-kpi-slos.json`
- Test: `plugins/powerbi-desktop/tests/pester/PowerBIPlugin.Tests.ps1`

- [ ] **Step 1: Write the failing Pester assertion**

```powershell
$config = Get-Content -Raw -LiteralPath (Join-Path $pluginRoot 'rules/powerbi-kpi-slos.json') | ConvertFrom-Json
$config.schema | Should Be 'codex.powerbi.kpiSlos.v1'
@($config.kpis).Count | Should BeGreaterThan 0
```

- [ ] **Step 2: Run the assertion**

Run: `Invoke-Pester plugins/powerbi-desktop/tests/pester/PowerBIPlugin.Tests.ps1`
Expected: fail because the configuration file does not exist.

- [ ] **Step 3: Add the minimal configuration**

```json
{
  "schema": "codex.powerbi.kpiSlos.v1",
  "default": { "freshnessTargetHours": 24, "severity": "Medium" },
  "kpis": [
    { "metricName": "Total Sales", "owner": "Sales Analytics", "decisionCritical": true, "freshnessTargetHours": 24, "severity": "High", "actionHint": "Confirm source refresh and owner sign-off." }
  ]
}
```

- [ ] **Step 4: Re-run the test**

Expected: pass.

### Task 2: Create the SLO action-list runner

**Files:**
- Create: `plugins/powerbi-desktop/scripts/New-PowerBIKpiSloActionList.ps1`
- Test: `plugins/powerbi-desktop/tests/pester/PowerBIPlugin.Tests.ps1`

- [ ] **Step 1: Write the failing Pester assertion**

```powershell
$result = & (Join-Path $scriptsPath 'New-PowerBIKpiSloActionList.ps1') -Path $samplePath -Json | ConvertFrom-Json
$result.schema | Should Be 'codex.powerbi.kpiSloActionList.v1'
$result.itemCount | Should Be 5
($result.items | Where-Object metricName -eq 'Total Sales').owner | Should Be 'Sales Analytics'
```

- [ ] **Step 2: Implement the runner**

The runner reads `powerbi-kpi-slos.json`, `New-PowerBIKpiTrustScore.ps1`, `Test-PowerBIDataFreshnessLineageGate.ps1`, and `New-PowerBIKpiDriftWatchlist.ps1`. For every metric it emits `metricName`, `owner`, `status`, `priority`, `causes`, and `nextAction`. A missing KPI rule emits `NeedsOwnerSetup` and never throws.

- [ ] **Step 3: Run the focused Pester test**

Expected: configured KPI has its owner; unconfigured KPIs are listed as `NeedsOwnerSetup`.

### Task 3: Add optional release-pack inclusion

**Files:**
- Modify: `plugins/powerbi-desktop/scripts/New-PowerBIReleaseCandidatePack.ps1`
- Test: `plugins/powerbi-desktop/tests/pester/PowerBIPlugin.Tests.ps1`

- [ ] **Step 1: Add `-IncludeKpiSloActions`**

When set, create `kpi-slo-action-list.json` under the release directory and expose its item count in `enterpriseUsps`. Do not change `decision`, `gate`, or existing release thresholds.

- [ ] **Step 2: Add release-pack verification**

```powershell
$release = & (Join-Path $scriptsPath 'New-PowerBIReleaseCandidatePack.ps1') -Path $samplePath -SkipLive -IncludeKpiSloActions -OutputDirectory $outputDirectory
Test-Path -LiteralPath (Join-Path $outputDirectory 'kpi-slo-action-list.json') | Should Be $true
```

- [ ] **Step 3: Run tests and documentation gate**

Run: `Invoke-Pester plugins/powerbi-desktop/tests/pester/PowerBIPlugin.Tests.ps1` and `plugins/powerbi-desktop/scripts/Test-PowerBIDocumentationCoverage.ps1`.
Expected: all relevant tests pass and documentation coverage remains passed.

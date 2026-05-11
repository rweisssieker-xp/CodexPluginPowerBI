# AI Forecast Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a read-only AI/KI sales forecast workflow for Power BI Desktop that combines short-term backlog conversion with granular customer/product monthly demand forecasting.

**Architecture:** Add one PowerShell entrypoint that extracts live model data and delegates deterministic forecast computation to a small Python worker. The worker outputs forecast detail, monthly summary, and top-delta CSV files without modifying the PBIX. Tests use local fixtures so CI does not need Power BI Desktop.

**Tech Stack:** PowerShell 5+/7, Python 3 standard library, ADOMD live DAX via existing `Invoke-PowerBILiveDaxQuery.ps1`, Pester tests.

---

## Scope

Implement the first production-grade, read-only version:

- Forecast grain: `CustomerHierarchy x ProductLine x Month`.
- Backlog-aware short-term forecast for current month plus next 1-3 months.
- Demand forecast with seasonality, YTD growth, budget/roll anchors, sparse-series shrinkage, and monthly reconciliation.
- Output as CSV artifacts suitable for import into Power BI.

Do not write into PBIX, PBIP, TMDL, or Power BI Service in this plan.

## File Structure

- Create `plugins/powerbi-desktop/scripts/Invoke-PowerBIAIForecast.ps1`
  - Public entrypoint.
  - Builds DAX queries, exports live model JSON, invokes Python worker, returns artifact paths.

- Create `plugins/powerbi-desktop/scripts/support/powerbi_ai_forecast.py`
  - Pure Python forecast engine.
  - Accepts live extract JSON and writes CSV outputs.
  - Contains parsing, feature generation, sparse shrinkage, backlog blending, and reconciliation.

- Create `plugins/powerbi-desktop/examples/ai-forecast/segment-monthly.json`
  - Small deterministic fixture for tests.

- Create `plugins/powerbi-desktop/tests/pester/AIForecast.Tests.ps1`
  - Verifies fixture execution, artifact schema, and entrypoint dry-run behavior.

- Modify `plugins/powerbi-desktop/tests/pester/PowerBIPlugin.Tests.ps1`
  - Add one smoke assertion that the new entrypoint exists and parses.

- Modify `plugins/powerbi-desktop/skills/powerbi-desktop/SKILL.md`
  - Add a concise workflow note for AI forecast generation.

- Modify `docs/script-catalog.md`
  - Document the new script.

## Task 1: Create Fixture and Python Worker Skeleton

**Files:**
- Create: `plugins/powerbi-desktop/examples/ai-forecast/segment-monthly.json`
- Create: `plugins/powerbi-desktop/scripts/support/powerbi_ai_forecast.py`
- Test: manual Python fixture run

- [ ] **Step 1: Create a minimal fixture**

Create `plugins/powerbi-desktop/examples/ai-forecast/segment-monthly.json`:

```json
{
  "schema": "codex.powerbi.liveDmv.v1",
  "rows": [
    {
      "dw Custtable[CustHierachy01]": "A - Germany",
      "dw Inventtable[ProductLineHerachy01]": "P1 - Standard",
      "Dates[Calendar Year]": 2025,
      "Dates[Calendar MonthNumber]": 5,
      "Dates[Calendar Month Year]": "May 2025",
      "[Sales]": 1000.0,
      "[Qty]": 10.0,
      "[Budget]": 0.0,
      "[ForecastRoll]": 0.0,
      "[Backlog]": 0.0
    },
    {
      "dw Custtable[CustHierachy01]": "A - Germany",
      "dw Inventtable[ProductLineHerachy01]": "P1 - Standard",
      "Dates[Calendar Year]": 2026,
      "Dates[Calendar MonthNumber]": 1,
      "Dates[Calendar Month Year]": "Jan 2026",
      "[Sales]": 1200.0,
      "[Qty]": 12.0,
      "[Budget]": 1500.0,
      "[ForecastRoll]": 1200.0,
      "[Backlog]": 0.0
    },
    {
      "dw Custtable[CustHierachy01]": "A - Germany",
      "dw Inventtable[ProductLineHerachy01]": "P1 - Standard",
      "Dates[Calendar Year]": 2026,
      "Dates[Calendar MonthNumber]": 5,
      "Dates[Calendar Month Year]": "May 2026",
      "[Sales]": 400.0,
      "[Qty]": 4.0,
      "[Budget]": 1500.0,
      "[ForecastRoll]": 1400.0,
      "[Backlog]": 300.0
    },
    {
      "dw Custtable[CustHierachy01]": "B - USA",
      "dw Inventtable[ProductLineHerachy01]": "P2 - Sparse",
      "Dates[Calendar Year]": 2025,
      "Dates[Calendar MonthNumber]": 6,
      "Dates[Calendar Month Year]": "Jun 2025",
      "[Sales]": 500.0,
      "[Qty]": 5.0,
      "[Budget]": 0.0,
      "[ForecastRoll]": 0.0,
      "[Backlog]": 0.0
    },
    {
      "dw Custtable[CustHierachy01]": "B - USA",
      "dw Inventtable[ProductLineHerachy01]": "P2 - Sparse",
      "Dates[Calendar Year]": 2026,
      "Dates[Calendar MonthNumber]": 6,
      "Dates[Calendar Month Year]": "Jun 2026",
      "[Sales]": 0.0,
      "[Qty]": 0.0,
      "[Budget]": 600.0,
      "[ForecastRoll]": 650.0,
      "[Backlog]": 450.0
    }
  ]
}
```

- [ ] **Step 2: Create Python worker with CLI**

Create `plugins/powerbi-desktop/scripts/support/powerbi_ai_forecast.py`:

```python
import argparse
import csv
import json
import math
from collections import defaultdict
from pathlib import Path


MONTH_LABELS = {
    1: "Jan 2026",
    2: "Feb 2026",
    3: "Mar 2026",
    4: "Apr 2026",
    5: "May 2026",
    6: "Jun 2026",
    7: "Jul 2026",
    8: "Aug 2026",
    9: "Sep 2026",
    10: "Oct 2026",
    11: "Nov 2026",
    12: "Dec 2026",
}


def num(value):
    if value is None:
        return 0.0
    try:
        if isinstance(value, float) and math.isnan(value):
            return 0.0
        return float(value)
    except (TypeError, ValueError):
        return 0.0


def clamp(value, low, high):
    return max(low, min(high, value))


def load_rows(input_path):
    with open(input_path, "r", encoding="utf-8-sig") as handle:
        payload = json.load(handle)
    return payload.get("rows", [])


def build_series(rows):
    series = defaultdict(dict)
    monthly_totals = defaultdict(lambda: defaultdict(float))
    for row in rows:
        customer_hierarchy = row.get("dw Custtable[CustHierachy01]") or "n/a"
        product_line = row.get("dw Inventtable[ProductLineHerachy01]") or "n/a"
        year = int(row["Dates[Calendar Year]"])
        month_no = int(row["Dates[Calendar MonthNumber]"])
        key = (customer_hierarchy, product_line)
        values = {
            "sales": num(row.get("[Sales]")),
            "qty": num(row.get("[Qty]")),
            "budget": num(row.get("[Budget]")),
            "roll": num(row.get("[ForecastRoll]")),
            "backlog": num(row.get("[Backlog]")),
        }
        series[key][(year, month_no)] = values
        for metric, value in values.items():
            monthly_totals[(year, month_no)][metric] += value
    return series, monthly_totals


def value_for(points, year, month, metric):
    return points.get((year, month), {}).get(metric, 0.0)


def calculate_forecast(rows, forecast_year, start_month, end_month):
    series, monthly_totals = build_series(rows)
    ytd_months = range(1, max(1, start_month))
    global_ytd_current = sum(monthly_totals[(forecast_year, m)]["sales"] for m in ytd_months)
    global_ytd_prior = sum(monthly_totals[(forecast_year - 1, m)]["sales"] for m in ytd_months)
    global_growth = global_ytd_current / global_ytd_prior - 1 if global_ytd_prior else 0.0
    annual_current = sum(monthly_totals[(forecast_year - 1, m)]["sales"] for m in range(1, 13))
    annual_prior = sum(monthly_totals[(forecast_year - 2, m)]["sales"] for m in range(1, 13))
    global_annual_growth = annual_current / annual_prior - 1 if annual_prior else 0.0

    detail_rows = []
    raw_month_totals = defaultdict(float)
    top_down_targets = {}

    for month in range(start_month, end_month + 1):
        actual = monthly_totals[(forecast_year, month)]["sales"]
        budget = monthly_totals[(forecast_year, month)]["budget"]
        roll = monthly_totals[(forecast_year, month)]["roll"]
        backlog = monthly_totals[(forecast_year, month)]["backlog"]
        last_year = monthly_totals[(forecast_year - 1, month)]["sales"]
        seasonal_ytd = last_year * (1 + global_growth) if last_year > 0 else 0.0
        trend = seasonal_ytd * (1 + global_annual_growth) if seasonal_ytd > 0 else 0.0
        backlog_expected = backlog * 0.70
        if month == start_month and actual > 0:
            run_rate = actual * 18.0 / 5.0
            top_down_targets[month] = 0.35 * run_rate + 0.25 * seasonal_ytd + 0.20 * budget + 0.10 * roll + 0.10 * backlog_expected
        else:
            top_down_targets[month] = 0.30 * seasonal_ytd + 0.20 * budget + 0.20 * roll + 0.20 * backlog_expected + 0.10 * trend

    for (customer_hierarchy, product_line), points in series.items():
        ytd_current = sum(value_for(points, forecast_year, m, "sales") for m in ytd_months)
        ytd_prior = sum(value_for(points, forecast_year - 1, m, "sales") for m in ytd_months)
        raw_growth = ytd_current / ytd_prior - 1 if ytd_prior else global_growth
        shrink_weight = clamp(ytd_prior / 100000.0, 0.0, 1.0)
        ytd_growth = clamp((shrink_weight * raw_growth) + ((1 - shrink_weight) * global_growth), -0.40, 0.60)

        for month in range(start_month, end_month + 1):
            actual = value_for(points, forecast_year, month, "sales")
            budget = value_for(points, forecast_year, month, "budget")
            roll = value_for(points, forecast_year, month, "roll")
            backlog = value_for(points, forecast_year, month, "backlog")
            last_year = value_for(points, forecast_year - 1, month, "sales")
            seasonal = last_year * (1 + ytd_growth) if last_year > 0 else 0.0
            trend_values = [value_for(points, y, month, "sales") for y in (forecast_year - 3, forecast_year - 2, forecast_year - 1)]
            trend_values = [v for v in trend_values if v > 0]
            trend = (sum(trend_values) / len(trend_values)) * (1 + ytd_growth) if trend_values else seasonal
            backlog_expected = backlog * 0.70
            active_history_months = sum(1 for (year, _), vals in points.items() if year < forecast_year and vals["sales"] > 0)

            components = []
            if seasonal > 0:
                components.append((0.25, seasonal))
            if trend > 0:
                components.append((0.15, trend))
            if budget > 0:
                components.append((0.15, budget))
            if roll > 0:
                components.append((0.15, roll))
            if backlog_expected > 0:
                components.append((0.30, backlog_expected))
            if actual > 0 and month == start_month:
                components.append((0.25, actual * 18.0 / 5.0))
            weight_sum = sum(weight for weight, _ in components)
            raw_forecast = sum(weight * value for weight, value in components) / weight_sum if weight_sum else 0.0
            risk = "sparse" if active_history_months < 6 else "volatile" if abs(ytd_growth) > 0.30 else "normal"
            confidence = "low" if risk == "sparse" else "medium" if risk == "volatile" else "high"

            row = {
                "customer_hierarchy": customer_hierarchy,
                "product_line": product_line,
                "month": MONTH_LABELS.get(month, f"{month:02d}/{forecast_year}"),
                "month_no": month,
                "actual_sales": round(actual, 2),
                "open_backlog": round(backlog, 2),
                "backlog_conversion_probability": 0.70 if backlog > 0 else 0.0,
                "expected_backlog_revenue": round(backlog_expected, 2),
                "budget": round(budget, 2),
                "roll_forecast": round(roll, 2),
                "statistical_demand_forecast": round(max(seasonal, trend), 2),
                "raw_ai_forecast": round(raw_forecast, 2),
                "final_ai_forecast": 0.0,
                "forecast_low": 0.0,
                "forecast_high": 0.0,
                "confidence": confidence,
                "risk_flag": risk,
                "explanation": f"{risk} segment; blended backlog, seasonality, budget, and roll forecast.",
            }
            detail_rows.append(row)
            raw_month_totals[month] += raw_forecast

    for row in detail_rows:
        month = int(row["month_no"])
        raw_total = raw_month_totals[month]
        target = top_down_targets[month]
        factor = target / raw_total if raw_total else 0.0
        final_value = row["raw_ai_forecast"] * factor
        row["final_ai_forecast"] = round(final_value, 2)
        row["forecast_low"] = round(final_value * 0.90, 2)
        row["forecast_high"] = round(final_value * 1.10, 2)
    return detail_rows


def write_csv(path, rows):
    path.parent.mkdir(parents=True, exist_ok=True)
    fieldnames = [
        "customer_hierarchy",
        "product_line",
        "month",
        "month_no",
        "actual_sales",
        "open_backlog",
        "backlog_conversion_probability",
        "expected_backlog_revenue",
        "budget",
        "roll_forecast",
        "statistical_demand_forecast",
        "raw_ai_forecast",
        "final_ai_forecast",
        "forecast_low",
        "forecast_high",
        "confidence",
        "risk_flag",
        "explanation",
    ]
    with open(path, "w", newline="", encoding="utf-8-sig") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames, delimiter=";")
        writer.writeheader()
        writer.writerows(rows)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", required=True)
    parser.add_argument("--output-directory", required=True)
    parser.add_argument("--forecast-year", type=int, default=2026)
    parser.add_argument("--start-month", type=int, default=5)
    parser.add_argument("--end-month", type=int, default=12)
    args = parser.parse_args()
    rows = calculate_forecast(load_rows(args.input), args.forecast_year, args.start_month, args.end_month)
    output_dir = Path(args.output_directory)
    detail_path = output_dir / "ai-forecast-detail.csv"
    write_csv(detail_path, rows)
    summary = {
        "schema": "codex.powerbi.aiForecast.v1",
        "rowCount": len(rows),
        "detailPath": str(detail_path),
        "forecastYear": args.forecast_year,
        "startMonth": args.start_month,
        "endMonth": args.end_month,
    }
    print(json.dumps(summary, indent=2))


if __name__ == "__main__":
    main()
```

- [ ] **Step 3: Run fixture worker**

Run:

```powershell
python .\plugins\powerbi-desktop\scripts\support\powerbi_ai_forecast.py `
  --input .\plugins\powerbi-desktop\examples\ai-forecast\segment-monthly.json `
  --output-directory .\plugins\powerbi-desktop\tmp\ai-forecast-fixture `
  --forecast-year 2026 `
  --start-month 5 `
  --end-month 6
```

Expected: JSON output with `"schema": "codex.powerbi.aiForecast.v1"` and `"rowCount"` greater than `0`.

- [ ] **Step 4: Commit**

```powershell
git add .\plugins\powerbi-desktop\examples\ai-forecast\segment-monthly.json `
        .\plugins\powerbi-desktop\scripts\support\powerbi_ai_forecast.py
git commit -m "Add AI forecast worker"
```

## Task 2: Add PowerShell Entrypoint

**Files:**
- Create: `plugins/powerbi-desktop/scripts/Invoke-PowerBIAIForecast.ps1`
- Test: `plugins/powerbi-desktop/tests/pester/AIForecast.Tests.ps1`

- [ ] **Step 1: Write Pester test for fixture mode**

Create `plugins/powerbi-desktop/tests/pester/AIForecast.Tests.ps1`:

```powershell
$pluginRoot = Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../..')
$scriptsPath = Join-Path $pluginRoot 'scripts'
$fixturePath = Join-Path $pluginRoot 'examples/ai-forecast/segment-monthly.json'

Describe 'AI Forecast workflow' {
    It 'runs from a fixture extract' {
        $outputDirectory = Join-Path $pluginRoot 'tmp/pester-ai-forecast'
        $result = & (Join-Path $scriptsPath 'Invoke-PowerBIAIForecast.ps1') `
            -InputPath $fixturePath `
            -OutputDirectory $outputDirectory `
            -ForecastYear 2026 `
            -StartMonth 5 `
            -EndMonth 6 `
            -Json | ConvertFrom-Json

        $result.schema | Should Be 'codex.powerbi.aiForecast.v1'
        $result.rowCount | Should BeGreaterThan 0
        (Test-Path -LiteralPath $result.detailPath) | Should Be $true
    }

    It 'exposes a dry-run live query plan' {
        $outputDirectory = Join-Path $pluginRoot 'tmp/pester-ai-forecast-dry-run'
        $result = & (Join-Path $scriptsPath 'Invoke-PowerBIAIForecast.ps1') `
            -OutputDirectory $outputDirectory `
            -ForecastYear 2026 `
            -StartMonth 5 `
            -EndMonth 6 `
            -DryRun `
            -Json | ConvertFrom-Json

        $result.schema | Should Be 'codex.powerbi.aiForecast.plan.v1'
        $result.queries.segmentMonthly | Should Match 'SUMMARIZECOLUMNS'
        $result.queries.segmentMonthly | Should Match 'Backlog'
    }
}
```

- [ ] **Step 2: Run test and verify it fails**

Run:

```powershell
Invoke-Pester .\plugins\powerbi-desktop\tests\pester\AIForecast.Tests.ps1
```

Expected: FAIL because `Invoke-PowerBIAIForecast.ps1` does not exist.

- [ ] **Step 3: Create PowerShell entrypoint**

Create `plugins/powerbi-desktop/scripts/Invoke-PowerBIAIForecast.ps1`:

```powershell
param(
    [string]$Server,
    [string]$InputPath,
    [string]$OutputDirectory = (Join-Path (Get-Location) 'powerbi-ai-forecast'),
    [int]$ForecastYear = 2026,
    [int]$StartMonth = 5,
    [int]$EndMonth = 12,
    [switch]$DryRun,
    [switch]$Json
)

$ErrorActionPreference = 'Stop'

function New-SegmentMonthlyQuery {
    param([int]$ForecastYear)
    $minYear = $ForecastYear - 5
    @"
EVALUATE
FILTER(
    SUMMARIZECOLUMNS(
        'dw Custtable'[CustHierachy01],
        'dw Inventtable'[ProductLineHerachy01],
        'Dates'[Calendar Year],
        'Dates'[Calendar MonthNumber],
        'Dates'[Calendar Month Year],
        "MonthStart", MIN('Dates'[Date]),
        "Sales", [_SumSalesTotal],
        "Qty", [_SumQTY],
        "Budget", [_SumBudgetAmount],
        "ForecastRoll", [_SumForecastAmountRoll],
        "Backlog", [_BacklogAmountMst]
    ),
    'Dates'[Calendar Year] >= $minYear
        && 'Dates'[Calendar Year] <= $ForecastYear
        && (
            NOT ISBLANK([_SumSalesTotal])
            || NOT ISBLANK([_SumBudgetAmount])
            || NOT ISBLANK([_SumForecastAmountRoll])
            || NOT ISBLANK([_BacklogAmountMst])
        )
)
ORDER BY 'dw Custtable'[CustHierachy01], 'dw Inventtable'[ProductLineHerachy01], [MonthStart]
"@
}

$resolvedOutputDirectory = New-Item -ItemType Directory -Force -Path $OutputDirectory
$segmentQuery = New-SegmentMonthlyQuery -ForecastYear $ForecastYear

if ($DryRun) {
    $plan = [pscustomobject]@{
        schema = 'codex.powerbi.aiForecast.plan.v1'
        outputDirectory = $resolvedOutputDirectory.FullName
        forecastYear = $ForecastYear
        startMonth = $StartMonth
        endMonth = $EndMonth
        queries = [pscustomobject]@{
            segmentMonthly = $segmentQuery
        }
    }
    if ($Json) { $plan | ConvertTo-Json -Depth 8; return }
    $plan
    return
}

if (-not $InputPath) {
    $InputPath = Join-Path $resolvedOutputDirectory.FullName 'segment-monthly.json'
    $daxScript = Join-Path $PSScriptRoot 'Invoke-PowerBILiveDaxQuery.ps1'
    $queryArgs = @('-Query', $segmentQuery, '-Json')
    if ($Server) { $queryArgs = @('-Server', $Server) + $queryArgs }
    & $daxScript @queryArgs | Set-Content -LiteralPath $InputPath -Encoding UTF8
}

$pythonScript = Join-Path $PSScriptRoot 'support/powerbi_ai_forecast.py'
$pythonArgs = @(
    $pythonScript,
    '--input', $InputPath,
    '--output-directory', $resolvedOutputDirectory.FullName,
    '--forecast-year', $ForecastYear,
    '--start-month', $StartMonth,
    '--end-month', $EndMonth
)

$raw = & python @pythonArgs
if ($LASTEXITCODE -ne 0) {
    throw "AI forecast worker failed with exit code $LASTEXITCODE."
}
$result = $raw | ConvertFrom-Json
$result | Add-Member -NotePropertyName inputPath -NotePropertyValue (Resolve-Path -LiteralPath $InputPath).Path

if ($Json) {
    $result | ConvertTo-Json -Depth 8
    return
}

$result
```

- [ ] **Step 4: Run Pester test and verify it passes**

Run:

```powershell
Invoke-Pester .\plugins\powerbi-desktop\tests\pester\AIForecast.Tests.ps1
```

Expected: PASS for both AI forecast workflow tests.

- [ ] **Step 5: Commit**

```powershell
git add .\plugins\powerbi-desktop\scripts\Invoke-PowerBIAIForecast.ps1 `
        .\plugins\powerbi-desktop\tests\pester\AIForecast.Tests.ps1
git commit -m "Add Power BI AI forecast entrypoint"
```

## Task 3: Add Summary and Top Delta Outputs

**Files:**
- Modify: `plugins/powerbi-desktop/scripts/support/powerbi_ai_forecast.py`
- Test: `plugins/powerbi-desktop/tests/pester/AIForecast.Tests.ps1`

- [ ] **Step 1: Extend Pester assertions**

Modify the first test in `AIForecast.Tests.ps1` to include:

```powershell
$result.summaryPath | Should Not BeNullOrEmpty
$result.topDeltaPath | Should Not BeNullOrEmpty
(Test-Path -LiteralPath $result.summaryPath) | Should Be $true
(Test-Path -LiteralPath $result.topDeltaPath) | Should Be $true
$summaryRows = Import-Csv -LiteralPath $result.summaryPath -Delimiter ';'
($summaryRows | Measure-Object).Count | Should Be 2
```

- [ ] **Step 2: Run test and verify it fails**

Run:

```powershell
Invoke-Pester .\plugins\powerbi-desktop\tests\pester\AIForecast.Tests.ps1
```

Expected: FAIL because `summaryPath` and `topDeltaPath` are not returned.

- [ ] **Step 3: Add summary writers**

Add these functions to `powerbi_ai_forecast.py` after `write_csv`:

```python
def write_summary_csv(path, rows):
    summary = defaultdict(lambda: defaultdict(float))
    for row in rows:
        label = row["month"]
        summary[label]["actual_sales"] += num(row["actual_sales"])
        summary[label]["open_backlog"] += num(row["open_backlog"])
        summary[label]["expected_backlog_revenue"] += num(row["expected_backlog_revenue"])
        summary[label]["budget"] += num(row["budget"])
        summary[label]["roll_forecast"] += num(row["roll_forecast"])
        summary[label]["statistical_demand_forecast"] += num(row["statistical_demand_forecast"])
        summary[label]["raw_ai_forecast"] += num(row["raw_ai_forecast"])
        summary[label]["final_ai_forecast"] += num(row["final_ai_forecast"])

    path.parent.mkdir(parents=True, exist_ok=True)
    fieldnames = [
        "month",
        "actual_sales",
        "open_backlog",
        "expected_backlog_revenue",
        "budget",
        "roll_forecast",
        "statistical_demand_forecast",
        "raw_ai_forecast",
        "final_ai_forecast",
        "delta_ai_vs_roll",
        "delta_ai_vs_budget",
    ]
    with open(path, "w", newline="", encoding="utf-8-sig") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames, delimiter=";")
        writer.writeheader()
        for label, values in sorted(summary.items()):
            final_value = values["final_ai_forecast"]
            writer.writerow({
                "month": label,
                "actual_sales": round(values["actual_sales"], 2),
                "open_backlog": round(values["open_backlog"], 2),
                "expected_backlog_revenue": round(values["expected_backlog_revenue"], 2),
                "budget": round(values["budget"], 2),
                "roll_forecast": round(values["roll_forecast"], 2),
                "statistical_demand_forecast": round(values["statistical_demand_forecast"], 2),
                "raw_ai_forecast": round(values["raw_ai_forecast"], 2),
                "final_ai_forecast": round(final_value, 2),
                "delta_ai_vs_roll": round(final_value - values["roll_forecast"], 2),
                "delta_ai_vs_budget": round(final_value - values["budget"], 2),
            })


def write_top_delta_csv(path, rows, limit=200):
    path.parent.mkdir(parents=True, exist_ok=True)
    ranked = sorted(rows, key=lambda row: abs(num(row["final_ai_forecast"]) - num(row["roll_forecast"])), reverse=True)
    write_csv(path, ranked[:limit])
```

Modify `main()`:

```python
detail_path = output_dir / "ai-forecast-detail.csv"
summary_path = output_dir / "ai-forecast-summary.csv"
top_delta_path = output_dir / "ai-forecast-top-deltas.csv"
write_csv(detail_path, rows)
write_summary_csv(summary_path, rows)
write_top_delta_csv(top_delta_path, rows)
summary = {
    "schema": "codex.powerbi.aiForecast.v1",
    "rowCount": len(rows),
    "detailPath": str(detail_path),
    "summaryPath": str(summary_path),
    "topDeltaPath": str(top_delta_path),
    "forecastYear": args.forecast_year,
    "startMonth": args.start_month,
    "endMonth": args.end_month,
}
```

- [ ] **Step 4: Run Pester test and verify it passes**

Run:

```powershell
Invoke-Pester .\plugins\powerbi-desktop\tests\pester\AIForecast.Tests.ps1
```

Expected: PASS.

- [ ] **Step 5: Commit**

```powershell
git add .\plugins\powerbi-desktop\scripts\support\powerbi_ai_forecast.py `
        .\plugins\powerbi-desktop\tests\pester\AIForecast.Tests.ps1
git commit -m "Add AI forecast summaries"
```

## Task 4: Add Plugin Smoke Coverage and Documentation

**Files:**
- Modify: `plugins/powerbi-desktop/tests/pester/PowerBIPlugin.Tests.ps1`
- Modify: `plugins/powerbi-desktop/skills/powerbi-desktop/SKILL.md`
- Modify: `docs/script-catalog.md`

- [ ] **Step 1: Add smoke test**

Append this test inside `Describe 'Power BI Desktop plugin'` in `PowerBIPlugin.Tests.ps1`:

```powershell
It 'includes the AI forecast entrypoint' {
    $scriptPath = Join-Path $scriptsPath 'Invoke-PowerBIAIForecast.ps1'
    Test-Path -LiteralPath $scriptPath | Should Be $true
    { & $scriptPath -DryRun -Json | ConvertFrom-Json } | Should Not Throw
}
```

- [ ] **Step 2: Document skill workflow**

Add this section to `plugins/powerbi-desktop/skills/powerbi-desktop/SKILL.md` near live model workflows:

```markdown
### Generate an AI/KI sales forecast

Run:

```powershell
.\plugins\powerbi-desktop\scripts\Invoke-PowerBIAIForecast.ps1 -OutputDirectory .\powerbi-ai-forecast
```

Use this for read-only forecasting from an open Power BI Desktop model. It exports live customer-hierarchy/product-line monthly data, blends backlog conversion, seasonality, budget, roll forecast, and sparse-series shrinkage, then writes detail, summary, and top-delta CSV artifacts. Import the output as a separate forecast table before drafting DAX measures.
```

- [ ] **Step 3: Document script catalog**

Add this entry to `docs/script-catalog.md`:

```markdown
### `Invoke-PowerBIAIForecast.ps1`

Creates a read-only AI/KI sales forecast from the open Power BI Desktop model or a saved extract. Outputs detail, monthly summary, and top-delta CSV files for Power BI import. The forecast combines actuals, backlog conversion, segment demand, budget/roll anchors, and monthly reconciliation.
```

- [ ] **Step 4: Run targeted tests**

Run:

```powershell
.\plugins\powerbi-desktop\tests\Run-PowerBITests.ps1 -SkipPester
Invoke-Pester .\plugins\powerbi-desktop\tests\pester\AIForecast.Tests.ps1
```

Expected: both commands pass. If `Invoke-Pester` is unavailable, record that Pester could not run and keep the fixture worker command as fallback verification.

- [ ] **Step 5: Commit**

```powershell
git add .\plugins\powerbi-desktop\tests\pester\PowerBIPlugin.Tests.ps1 `
        .\plugins\powerbi-desktop\skills\powerbi-desktop\SKILL.md `
        .\docs\script-catalog.md
git commit -m "Document AI forecast workflow"
```

## Task 5: Live Model Validation

**Files:**
- No code changes unless a defect is found.
- Output: `powerbi-ai-forecast` artifact directory.

- [ ] **Step 1: Run dry-run live query plan**

Run:

```powershell
.\plugins\powerbi-desktop\scripts\Invoke-PowerBIAIForecast.ps1 `
  -OutputDirectory .\powerbi-ai-forecast `
  -ForecastYear 2026 `
  -StartMonth 5 `
  -EndMonth 12 `
  -DryRun `
  -Json
```

Expected: JSON with schema `codex.powerbi.aiForecast.plan.v1` and a DAX query containing `Backlog`.

- [ ] **Step 2: Run live forecast against open Power BI Desktop**

Run:

```powershell
.\plugins\powerbi-desktop\scripts\Invoke-PowerBIAIForecast.ps1 `
  -OutputDirectory .\powerbi-ai-forecast `
  -ForecastYear 2026 `
  -StartMonth 5 `
  -EndMonth 12 `
  -Json
```

Expected: JSON with schema `codex.powerbi.aiForecast.v1`, `rowCount` greater than `0`, and paths to detail, summary, and top-delta CSV files.

- [ ] **Step 3: Inspect summary totals**

Run:

```powershell
Import-Csv .\powerbi-ai-forecast\ai-forecast-summary.csv -Delimiter ';' |
  Select-Object month, final_ai_forecast, roll_forecast, budget, delta_ai_vs_roll, delta_ai_vs_budget |
  Format-Table -AutoSize
```

Expected: May-Dec 2026 rows with plausible totals and no empty `final_ai_forecast`.

- [ ] **Step 4: Inspect largest deltas**

Run:

```powershell
Import-Csv .\powerbi-ai-forecast\ai-forecast-top-deltas.csv -Delimiter ';' |
  Select-Object -First 20 customer_hierarchy, product_line, month, final_ai_forecast, roll_forecast, confidence, risk_flag |
  Format-Table -AutoSize
```

Expected: High-delta segments include explanations, confidence, and risk flags.

- [ ] **Step 5: Commit defect fixes only**

If Task 5 finds code defects, fix them in the smallest relevant file and commit:

```powershell
git add .\plugins\powerbi-desktop\scripts\Invoke-PowerBIAIForecast.ps1 `
        .\plugins\powerbi-desktop\scripts\support\powerbi_ai_forecast.py `
        .\plugins\powerbi-desktop\tests\pester\AIForecast.Tests.ps1
git commit -m "Fix AI forecast live validation"
```

If Task 5 only produces runtime artifacts, do not commit generated forecast CSV/JSON outputs.

## Self-Review

- Spec coverage: The plan covers the read-only workflow, backlog conversion signal, granular demand forecast, confidence/explanation columns, output table shape, and validation. Direct PBIX write-back is intentionally excluded.
- Completeness scan: The plan contains no unresolved markers. Each implementation task includes file paths, commands, expected results, and concrete code.
- Type consistency: The worker returns `detailPath`, `summaryPath`, and `topDeltaPath`; tests assert those exact properties. CSV column names are stable across worker and inspection commands.

import csv
import json
import math
from collections import defaultdict


SOURCE = "forecast-segment-monthly.json"
DETAIL_OUT = "forecast-segment-recommended-2026.csv"
SUMMARY_OUT = "forecast-segment-summary-2026.csv"
TOP_OUT = "forecast-segment-top-deltas-2026.csv"
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


with open(SOURCE, "r", encoding="utf-8-sig") as handle:
    payload = json.load(handle)

rows = payload["rows"]
series = defaultdict(dict)
monthly_totals = defaultdict(lambda: defaultdict(float))

for row in rows:
    customer_hierarchy = row.get("dw Custtable[CustHierachy01]") or "n/a"
    product_line = row.get("dw Inventtable[ProductLineHerachy01]") or "n/a"
    year = int(row["Dates[Calendar Year]"])
    month_no = int(row["Dates[Calendar MonthNumber]"])
    month_label = row["Dates[Calendar Month Year]"]
    key = (customer_hierarchy, product_line)
    values = {
        "month": month_label,
        "sales": num(row.get("[Sales]")),
        "qty": num(row.get("[Qty]")),
        "budget": num(row.get("[Budget]")),
        "roll": num(row.get("[ForecastRoll]")),
    }
    series[key][(year, month_no)] = values
    monthly_totals[(year, month_no)]["sales"] += values["sales"]
    monthly_totals[(year, month_no)]["budget"] += values["budget"]
    monthly_totals[(year, month_no)]["roll"] += values["roll"]


def value_for(points, year, month, metric):
    return points.get((year, month), {}).get(metric, 0.0)


global_ytd_2026 = sum(monthly_totals[(2026, m)]["sales"] for m in range(1, 5))
global_ytd_2025 = sum(monthly_totals[(2025, m)]["sales"] for m in range(1, 5))
global_growth = global_ytd_2026 / global_ytd_2025 - 1 if global_ytd_2025 else 0.0

year_2025 = sum(monthly_totals[(2025, m)]["sales"] for m in range(1, 13))
year_2024 = sum(monthly_totals[(2024, m)]["sales"] for m in range(1, 13))
global_annual_growth = year_2025 / year_2024 - 1 if year_2024 else 0.0

detail_rows = []
summary = defaultdict(lambda: defaultdict(float))
raw_month_totals = defaultdict(float)
top_down_targets = {}

for month in range(5, 13):
    actual = monthly_totals[(2026, month)]["sales"]
    budget = monthly_totals[(2026, month)]["budget"]
    roll = monthly_totals[(2026, month)]["roll"]
    last_year = monthly_totals[(2025, month)]["sales"]
    same_month_values = [
        monthly_totals[(year, month)]["sales"]
        for year in (2023, 2024, 2025)
        if monthly_totals[(year, month)]["sales"] > 0
    ]
    seasonal_avg = sum(same_month_values) / len(same_month_values) if same_month_values else 0.0
    seasonal_ytd = last_year * (1 + global_growth) if last_year > 0 else seasonal_avg * (1 + global_growth)
    trend = seasonal_avg * (1 + global_annual_growth) if seasonal_avg > 0 else seasonal_ytd

    if month == 5:
        run_rate = actual * 18.0 / 5.0 if actual > 0 else 0.0
        anchor_candidates = [v for v in (roll, budget, seasonal_ytd, trend) if v > 0]
        anchor = sum(anchor_candidates) / len(anchor_candidates) if anchor_candidates else run_rate
        if anchor > 0 and run_rate > 0:
            run_rate = clamp(run_rate, anchor * 0.35, anchor * 2.25)
        top_down_targets[month] = (
            0.50 * run_rate
            + 0.20 * seasonal_ytd
            + 0.15 * budget
            + 0.15 * roll
        )
    else:
        components = []
        if seasonal_ytd > 0:
            components.append((0.35, seasonal_ytd))
        if budget > 0:
            components.append((0.25, budget))
        if roll > 0:
            components.append((0.25, roll))
        if trend > 0:
            components.append((0.15, trend))
        weight_sum = sum(weight for weight, _ in components)
        top_down_targets[month] = sum(weight * value for weight, value in components) / weight_sum if weight_sum else 0.0

for (customer_hierarchy, product_line), points in series.items():
    ytd_2026 = sum(value_for(points, 2026, m, "sales") for m in range(1, 5))
    ytd_2025 = sum(value_for(points, 2025, m, "sales") for m in range(1, 5))
    raw_growth = ytd_2026 / ytd_2025 - 1 if ytd_2025 > 0 else global_growth
    shrink_weight = clamp(ytd_2025 / 100_000.0, 0.0, 1.0)
    ytd_growth = clamp(
        (shrink_weight * raw_growth) + ((1 - shrink_weight) * global_growth),
        -0.40,
        0.60,
    )

    annual_2025 = sum(value_for(points, 2025, m, "sales") for m in range(1, 13))
    annual_2024 = sum(value_for(points, 2024, m, "sales") for m in range(1, 13))
    raw_annual_growth = annual_2025 / annual_2024 - 1 if annual_2024 > 0 else global_annual_growth
    annual_weight = clamp(annual_2024 / 250_000.0, 0.0, 1.0)
    annual_growth = clamp(
        (annual_weight * raw_annual_growth) + ((1 - annual_weight) * global_annual_growth),
        -0.35,
        0.45,
    )

    for month in range(5, 13):
        label = MONTH_LABELS[month]
        actual = value_for(points, 2026, month, "sales")
        budget = value_for(points, 2026, month, "budget")
        roll = value_for(points, 2026, month, "roll")
        last_year = value_for(points, 2025, month, "sales")
        same_month_values = [
            value_for(points, year, month, "sales")
            for year in (2023, 2024, 2025)
            if value_for(points, year, month, "sales") > 0
        ]
        seasonal_avg = sum(same_month_values) / len(same_month_values) if same_month_values else 0.0
        seasonal_ytd = last_year * (1 + ytd_growth) if last_year > 0 else seasonal_avg * (1 + ytd_growth)
        trend = seasonal_avg * (1 + annual_growth) if seasonal_avg > 0 else seasonal_ytd

        if month == 5:
            # Last actual date in the live model is 2026-05-08: 5 elapsed working days,
            # 18 working days in May. Run-rate is useful, but clipped to avoid sparse-series explosions.
            run_rate = actual * 18.0 / 5.0 if actual > 0 else 0.0
            anchor_candidates = [v for v in (roll, budget, seasonal_ytd, trend) if v > 0]
            anchor = sum(anchor_candidates) / len(anchor_candidates) if anchor_candidates else run_rate
            if anchor > 0 and run_rate > 0:
                run_rate = clamp(run_rate, anchor * 0.35, anchor * 2.25)
            recommended = (
                0.50 * run_rate
                + 0.20 * seasonal_ytd
                + 0.15 * budget
                + 0.15 * roll
            )
            method = "may_runrate_blend"
        else:
            # Future months: segment-level seasonal signal, current budget, existing roll forecast,
            # and 3-year trend. Weights favor signals available at the segment grain.
            components = []
            if seasonal_ytd > 0:
                components.append((0.35, seasonal_ytd))
            if budget > 0:
                components.append((0.25, budget))
            if roll > 0:
                components.append((0.25, roll))
            if trend > 0:
                components.append((0.15, trend))
            weight_sum = sum(weight for weight, _ in components)
            recommended = sum(weight * value for weight, value in components) / weight_sum if weight_sum else 0.0
            method = "segment_ensemble"

        risk = "normal"
        active_months = sum(1 for (year, _month), vals in points.items() if year <= 2025 and vals["sales"] > 0)
        if active_months < 6:
            risk = "sparse"
        elif abs(ytd_growth) > 0.30:
            risk = "volatile"

        detail = {
            "customer_hierarchy": customer_hierarchy,
            "product_line": product_line,
            "month": label,
            "month_no": month,
            "actual_sales": round(actual, 2),
            "budget": round(budget, 2),
            "roll_forecast": round(roll, 2),
            "seasonal_ytd_forecast": round(seasonal_ytd, 2),
            "trend_3y_forecast": round(trend, 2),
            "recommended_forecast": round(recommended, 2),
            "reconciled_forecast": 0.0,
            "delta_vs_roll": round(recommended - roll, 2),
            "delta_vs_budget": round(recommended - budget, 2),
            "method": method,
            "risk": risk,
            "active_history_months": active_months,
            "ytd_growth_used": round(ytd_growth, 6),
        }
        detail_rows.append(detail)
        raw_month_totals[month] += recommended

for detail in detail_rows:
    month = int(detail["month_no"])
    raw_total = raw_month_totals[month]
    target = top_down_targets[month]
    factor = target / raw_total if raw_total else 0.0
    reconciled = detail["recommended_forecast"] * factor
    detail["top_down_target_month"] = round(target, 2)
    detail["reconciliation_factor"] = round(factor, 8)
    detail["reconciled_forecast"] = round(reconciled, 2)
    detail["delta_reconciled_vs_roll"] = round(reconciled - detail["roll_forecast"], 2)
    detail["delta_reconciled_vs_budget"] = round(reconciled - detail["budget"], 2)

    label = detail["month"]
    summary[label]["recommended"] += detail["recommended_forecast"]
    summary[label]["reconciled"] += reconciled
    summary[label]["roll"] += detail["roll_forecast"]
    summary[label]["budget"] += detail["budget"]
    summary[label]["actual"] += detail["actual_sales"]
    summary[label]["seasonal_ytd"] += detail["seasonal_ytd_forecast"]
    summary[label]["trend"] += detail["trend_3y_forecast"]


fieldnames = [
    "customer_hierarchy",
    "product_line",
    "month",
    "month_no",
    "actual_sales",
    "budget",
    "roll_forecast",
    "seasonal_ytd_forecast",
    "trend_3y_forecast",
    "recommended_forecast",
    "reconciled_forecast",
    "top_down_target_month",
    "reconciliation_factor",
    "delta_vs_roll",
    "delta_vs_budget",
    "delta_reconciled_vs_roll",
    "delta_reconciled_vs_budget",
    "method",
    "risk",
    "active_history_months",
    "ytd_growth_used",
]

with open(DETAIL_OUT, "w", newline="", encoding="utf-8-sig") as handle:
    writer = csv.DictWriter(handle, fieldnames=fieldnames, delimiter=";")
    writer.writeheader()
    writer.writerows(detail_rows)

with open(SUMMARY_OUT, "w", newline="", encoding="utf-8-sig") as handle:
    writer = csv.DictWriter(
        handle,
        fieldnames=[
            "month",
            "actual_sales",
            "budget",
            "roll_forecast",
            "seasonal_ytd_forecast",
            "trend_3y_forecast",
            "recommended_forecast",
            "reconciled_forecast",
            "delta_vs_roll",
            "delta_vs_budget",
            "delta_reconciled_vs_roll",
            "delta_reconciled_vs_budget",
        ],
        delimiter=";",
    )
    writer.writeheader()
    for label, vals in sorted(summary.items(), key=lambda item: next(k for k, v in MONTH_LABELS.items() if v == item[0])):
        writer.writerow(
            {
                "month": label,
                "actual_sales": round(vals["actual"], 2),
                "budget": round(vals["budget"], 2),
                "roll_forecast": round(vals["roll"], 2),
                "seasonal_ytd_forecast": round(vals["seasonal_ytd"], 2),
                "trend_3y_forecast": round(vals["trend"], 2),
                "recommended_forecast": round(vals["recommended"], 2),
                "reconciled_forecast": round(vals["reconciled"], 2),
                "delta_vs_roll": round(vals["recommended"] - vals["roll"], 2),
                "delta_vs_budget": round(vals["recommended"] - vals["budget"], 2),
                "delta_reconciled_vs_roll": round(vals["reconciled"] - vals["roll"], 2),
                "delta_reconciled_vs_budget": round(vals["reconciled"] - vals["budget"], 2),
            }
        )

top = sorted(detail_rows, key=lambda r: abs(r["delta_reconciled_vs_roll"]), reverse=True)[:200]
with open(TOP_OUT, "w", newline="", encoding="utf-8-sig") as handle:
    writer = csv.DictWriter(handle, fieldnames=fieldnames, delimiter=";")
    writer.writeheader()
    writer.writerows(top)

print(f"Input rows: {len(rows):,}")
print(f"Segment series: {len(series):,}")
print(f"Forecast rows: {len(detail_rows):,}")
print(f"Global Jan-Apr growth used: {global_growth:.4%}")
print(f"Global annual growth used: {global_annual_growth:.4%}")
print(f"Wrote {DETAIL_OUT}, {SUMMARY_OUT}, {TOP_OUT}")

import argparse
import csv
import json
import math
from collections import defaultdict
from pathlib import Path


MONTH_NAMES = {
    1: "Jan",
    2: "Feb",
    3: "Mar",
    4: "Apr",
    5: "May",
    6: "Jun",
    7: "Jul",
    8: "Aug",
    9: "Sep",
    10: "Oct",
    11: "Nov",
    12: "Dec",
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


def month_label(year, month):
    month_name = MONTH_NAMES.get(month)
    return f"{month_name} {year}" if month_name else f"{month:02d}/{year}"


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
                "month": month_label(forecast_year, month),
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

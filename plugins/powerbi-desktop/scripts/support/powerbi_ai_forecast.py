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


def first_value(row, names):
    for name in names:
        value = row.get(name)
        if value not in (None, ""):
            return value
    return None


def build_series(rows, grain):
    series = defaultdict(dict)
    monthly_totals = defaultdict(lambda: defaultdict(float))
    for row in rows:
        customer_hierarchy = row.get("dw Custtable[CustHierachy01]") or "n/a"
        product_line = row.get("dw Inventtable[ProductLineHerachy01]") or "n/a"
        customer = first_value(row, ["dw Custtable[AccountNum_nk]", "dw Custtable[AccountNum_sk]", "customer"]) or customer_hierarchy
        product = first_value(row, ["dw Inventtable[ItemId_nk]", "dw Inventtable[ItemId_sk]", "product"]) or product_line
        year = int(row["Dates[Calendar Year]"])
        month_no = int(row["Dates[Calendar MonthNumber]"])
        key = (customer, product) if grain == "CustomerProduct" else (customer_hierarchy, product_line)
        values = {
            "sales": num(row.get("[Sales]")),
            "qty": num(row.get("[Qty]")),
            "budget": num(row.get("[Budget]")),
            "roll": num(row.get("[ForecastRoll]")),
            "backlog": num(row.get("[Backlog]")),
        }
        point = series[key].setdefault(
            (year, month_no),
            {"sales": 0.0, "qty": 0.0, "budget": 0.0, "roll": 0.0, "backlog": 0.0},
        )
        for metric, value in values.items():
            point[metric] += value
            monthly_totals[(year, month_no)][metric] += value
        point["customer_hierarchy"] = customer_hierarchy
        point["product_line"] = product_line
        point["customer"] = customer
        point["product"] = product
    return series, monthly_totals


def value_for(points, year, month, metric):
    return points.get((year, month), {}).get(metric, 0.0)


def month_label(year, month):
    month_name = MONTH_NAMES.get(month)
    return f"{month_name} {year}" if month_name else f"{month:02d}/{year}"


def conversion_probability(backlog, realized_sales, fallback):
    if backlog <= 0:
        return 0.0
    observed = realized_sales / backlog
    if observed > 0:
        return clamp(observed, 0.10, 0.95)
    return fallback


def build_conversion_rates(series, forecast_year, start_month):
    global_rates = []
    segment_rates = {}
    for key, points in series.items():
        rates = []
        for year in range(forecast_year - 3, forecast_year + 1):
            for month in range(1, 13):
                if year == forecast_year and month >= start_month:
                    continue
                backlog = value_for(points, year, month, "backlog")
                if backlog <= 0:
                    continue
                realized = value_for(points, year, month, "sales")
                if realized > 0:
                    rate = clamp(realized / backlog, 0.10, 0.95)
                    rates.append(rate)
                    global_rates.append(rate)
        if rates:
            segment_rates[key] = sum(rates) / len(rates)
    global_rate = sum(global_rates) / len(global_rates) if global_rates else 0.50
    return segment_rates, clamp(global_rate, 0.10, 0.90)


def calculate_forecast(rows, forecast_year, start_month, end_month, as_of_date, horizon_months, grain):
    series, monthly_totals = build_series(rows, grain)
    segment_conversion_rates, global_conversion_rate = build_conversion_rates(series, forecast_year, start_month)
    ytd_months = range(1, max(1, start_month))
    global_ytd_current = sum(monthly_totals[(forecast_year, m)]["sales"] for m in ytd_months)
    global_ytd_prior = sum(monthly_totals[(forecast_year - 1, m)]["sales"] for m in ytd_months)
    global_growth = global_ytd_current / global_ytd_prior - 1 if global_ytd_prior else 0.0
    annual_current = sum(monthly_totals[(forecast_year - 1, m)]["sales"] for m in range(1, 13))
    annual_prior = sum(monthly_totals[(forecast_year - 2, m)]["sales"] for m in range(1, 13))
    global_annual_growth = annual_current / annual_prior - 1 if annual_prior else 0.0
    global_monthly_fallback = annual_current / 12.0 if annual_current else 0.0

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
        backlog_probability = conversion_probability(backlog, actual, global_conversion_rate)
        backlog_expected = backlog * backlog_probability
        if month == start_month and actual > 0:
            run_rate = actual * 18.0 / 5.0
            top_down_targets[month] = 0.35 * run_rate + 0.25 * seasonal_ytd + 0.20 * budget + 0.10 * roll + 0.10 * backlog_expected
        else:
            top_down_targets[month] = 0.30 * seasonal_ytd + 0.20 * budget + 0.20 * roll + 0.20 * backlog_expected + 0.10 * trend
        if top_down_targets[month] <= 0 and global_monthly_fallback > 0:
            top_down_targets[month] = global_monthly_fallback

    for customer_hierarchy, product_line in sorted(series.keys()):
        key = (customer_hierarchy, product_line)
        points = series[key]
        sample = next(iter(points.values()))
        output_customer_hierarchy = sample.get("customer_hierarchy", customer_hierarchy)
        output_product_line = sample.get("product_line", product_line)
        output_customer = sample.get("customer", customer_hierarchy)
        output_product = sample.get("product", product_line)
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
            base_probability = segment_conversion_rates.get(key, global_conversion_rate)
            backlog_probability = conversion_probability(backlog, actual, base_probability)
            backlog_expected = backlog * backlog_probability
            active_history_months = sum(1 for (year, _), vals in points.items() if year < forecast_year and vals["sales"] > 0)
            active_history_sales = sum(vals["sales"] for (year, _), vals in points.items() if year < forecast_year)
            intermittent_demand = (
                (active_history_sales / active_history_months) * clamp(active_history_months / 12.0, 0.05, 1.0)
                if active_history_months > 0
                else 0.0
            )
            sparse_fallback = active_history_months < 6 and active_history_sales < 50000

            components = []
            if seasonal > 0:
                components.append((0.25, seasonal))
            if trend > 0:
                components.append((0.15, trend))
            if intermittent_demand > 0:
                components.append((0.10, intermittent_demand))
            if budget > 0:
                components.append((0.15, budget))
            if roll > 0:
                components.append((0.15, roll))
            if backlog_expected > 0:
                components.append((0.35 if month <= start_month + 2 else 0.20, backlog_expected))
            if actual > 0 and month == start_month:
                components.append((0.25, actual * 18.0 / 5.0))
            weight_sum = sum(weight for weight, _ in components)
            raw_forecast = sum(weight * value for weight, value in components) / weight_sum if weight_sum else 0.0
            risk = "sparse" if sparse_fallback else "volatile" if abs(ytd_growth) > 0.30 else "normal"
            confidence = "low" if risk == "sparse" else "medium" if risk == "volatile" else "high"
            residual_demand = max(0.0, raw_forecast - backlog_expected - actual)

            row = {
                "as_of_date": as_of_date,
                "forecast_month": month_label(forecast_year, month),
                "grain": grain if not sparse_fallback else "HierarchyProductLineFallback",
                "customer": output_customer,
                "product": output_product,
                "customer_hierarchy": output_customer_hierarchy,
                "product_line": output_product_line,
                "month": month_label(forecast_year, month),
                "month_no": month,
                "actual_sales": round(actual, 2),
                "open_backlog": round(backlog, 2),
                "backlog_conversion_probability": round(backlog_probability, 4),
                "expected_backlog_revenue": round(backlog_expected, 2),
                "budget": round(budget, 2),
                "roll_forecast": round(roll, 2),
                "statistical_demand_forecast": round(max(seasonal, trend, intermittent_demand), 2),
                "residual_demand_forecast": round(residual_demand, 2),
                "raw_ai_forecast": round(raw_forecast, 2),
                "final_ai_forecast": 0.0,
                "forecast_low": 0.0,
                "forecast_high": 0.0,
                "confidence": confidence,
                "risk_flag": risk,
                "explanation": f"{risk} segment; learned backlog probability {backlog_probability:.0%}; blended backlog, residual demand, budget, and roll forecast.",
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


DETAIL_FIELDNAMES = [
    "as_of_date",
    "forecast_month",
    "grain",
    "customer",
    "product",
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
    "residual_demand_forecast",
    "raw_ai_forecast",
    "final_ai_forecast",
    "forecast_low",
    "forecast_high",
    "confidence",
    "risk_flag",
    "explanation",
]

SUMMARY_FIELDNAMES = [
    "forecast_month",
    "month",
    "actual_sales",
    "open_backlog",
    "expected_backlog_revenue",
    "budget",
    "roll_forecast",
    "statistical_demand_forecast",
    "residual_demand_forecast",
    "raw_ai_forecast",
    "final_ai_forecast",
    "delta_ai_vs_roll",
    "delta_ai_vs_budget",
]


def build_summary_rows(detail_rows):
    by_month = defaultdict(lambda: defaultdict(float))
    labels = {}
    for row in detail_rows:
        month_no = int(row["month_no"])
        labels[month_no] = row["forecast_month"]
        for fieldname in SUMMARY_FIELDNAMES:
            if fieldname not in ("month", "forecast_month"):
                by_month[month_no][fieldname] += num(row.get(fieldname))

    summary_rows = []
    for month_no in sorted(by_month.keys()):
        values = by_month[month_no]
        values["delta_ai_vs_roll"] = values["final_ai_forecast"] - values["roll_forecast"]
        values["delta_ai_vs_budget"] = values["final_ai_forecast"] - values["budget"]
        summary_rows.append(
            {
                "forecast_month": labels[month_no],
                "month": labels[month_no],
                "actual_sales": round(values["actual_sales"], 2),
                "open_backlog": round(values["open_backlog"], 2),
                "expected_backlog_revenue": round(values["expected_backlog_revenue"], 2),
                "budget": round(values["budget"], 2),
                "roll_forecast": round(values["roll_forecast"], 2),
                "statistical_demand_forecast": round(values["statistical_demand_forecast"], 2),
                "residual_demand_forecast": round(values["residual_demand_forecast"], 2),
                "raw_ai_forecast": round(values["raw_ai_forecast"], 2),
                "final_ai_forecast": round(values["final_ai_forecast"], 2),
                "delta_ai_vs_roll": round(values["delta_ai_vs_roll"], 2),
                "delta_ai_vs_budget": round(values["delta_ai_vs_budget"], 2),
            }
        )
    return summary_rows


def build_top_delta_rows(detail_rows, limit=200):
    return sorted(
        detail_rows,
        key=lambda row: abs(num(row.get("final_ai_forecast")) - num(row.get("roll_forecast"))),
        reverse=True,
    )[:limit]


BACKTEST_FIELDNAMES = [
    "as_of_month",
    "forecast_month",
    "horizon_months",
    "actual_sales",
    "ai_forecast",
    "roll_forecast",
    "absolute_error",
    "roll_absolute_error",
    "bias",
]

QUALITY_FIELDNAMES = [
    "horizon_months",
    "segment",
    "actual_sales",
    "ai_forecast",
    "roll_forecast",
    "wape",
    "roll_wape",
    "bias",
    "risk_flag",
]


def build_backtest_rows(rows, forecast_year, start_month, horizon_months, grain):
    detail_rows = []
    for as_of_month in range(1, max(1, start_month)):
        horizon_end = min(12, as_of_month + horizon_months)
        simulated = calculate_forecast(rows, forecast_year, as_of_month + 1, horizon_end, month_label(forecast_year, as_of_month), horizon_months, grain)
        summary = build_summary_rows(simulated)
        for row in summary:
            forecast_month_no = next((num for num, name in MONTH_NAMES.items() if row["forecast_month"].startswith(name)), 0)
            horizon_value = forecast_month_no - as_of_month
            actual = num(row["actual_sales"])
            ai_forecast = num(row["final_ai_forecast"])
            roll = num(row["roll_forecast"])
            detail_rows.append(
                {
                    "as_of_month": month_label(forecast_year, as_of_month),
                    "forecast_month": row["forecast_month"],
                    "horizon_months": horizon_value,
                    "actual_sales": round(actual, 2),
                    "ai_forecast": round(ai_forecast, 2),
                    "roll_forecast": round(roll, 2),
                    "absolute_error": round(abs(ai_forecast - actual), 2),
                    "roll_absolute_error": round(abs(roll - actual), 2),
                    "bias": round(ai_forecast - actual, 2),
                }
            )
    return detail_rows


def build_quality_rows(backtest_rows):
    by_horizon = defaultdict(lambda: defaultdict(float))
    for row in backtest_rows:
        horizon = int(row["horizon_months"])
        by_horizon[horizon]["actual_sales"] += num(row["actual_sales"])
        by_horizon[horizon]["ai_forecast"] += num(row["ai_forecast"])
        by_horizon[horizon]["roll_forecast"] += num(row["roll_forecast"])
        by_horizon[horizon]["absolute_error"] += num(row["absolute_error"])
        by_horizon[horizon]["roll_absolute_error"] += num(row["roll_absolute_error"])
    quality_rows = []
    for horizon in sorted(by_horizon.keys()):
        values = by_horizon[horizon]
        actual = values["actual_sales"]
        bias = values["ai_forecast"] - actual
        bias_ratio = bias / actual if actual else 0.0
        wape = values["absolute_error"] / actual if actual else 0.0
        roll_wape = values["roll_absolute_error"] / actual if actual else 0.0
        risk_flag = "advisory_only" if wape > roll_wape else "biased" if abs(bias_ratio) > 0.03 else "normal"
        quality_rows.append(
            {
                "horizon_months": horizon,
                "segment": "Total",
                "actual_sales": round(actual, 2),
                "ai_forecast": round(values["ai_forecast"], 2),
                "roll_forecast": round(values["roll_forecast"], 2),
                "wape": round(wape, 6),
                "roll_wape": round(roll_wape, 6),
                "bias": round(bias_ratio, 6),
                "risk_flag": risk_flag,
            }
        )
    if not quality_rows:
        quality_rows.append(
            {
                "horizon_months": 1,
                "segment": "Total",
                "actual_sales": 0.0,
                "ai_forecast": 0.0,
                "roll_forecast": 0.0,
                "wape": 0.0,
                "roll_wape": 0.0,
                "bias": 0.0,
                "risk_flag": "insufficient_history",
            }
        )
    return quality_rows


def write_csv(path, rows, fieldnames):
    path.parent.mkdir(parents=True, exist_ok=True)
    with open(path, "w", newline="", encoding="utf-8-sig") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames, delimiter=";")
        writer.writeheader()
        writer.writerows(rows)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", required=True)
    parser.add_argument("--output-directory", required=True)
    parser.add_argument("--as-of-date", default="")
    parser.add_argument("--forecast-year", type=int, default=2026)
    parser.add_argument("--start-month", type=int, default=5)
    parser.add_argument("--end-month", type=int, default=12)
    parser.add_argument("--horizon-months", type=int, default=3)
    parser.add_argument("--grain", choices=["CustomerProduct", "HierarchyProductLine"], default="CustomerProduct")
    parser.add_argument("--backtest", action="store_true")
    args = parser.parse_args()
    input_rows = load_rows(args.input)
    rows = calculate_forecast(input_rows, args.forecast_year, args.start_month, args.end_month, args.as_of_date, args.horizon_months, args.grain)
    output_dir = Path(args.output_directory)
    detail_path = output_dir / "ai-forecast-detail.csv"
    summary_path = output_dir / "ai-forecast-summary.csv"
    top_delta_path = output_dir / "ai-forecast-top-deltas.csv"
    backtest_path = output_dir / "ai-forecast-backtest.csv"
    quality_path = output_dir / "ai-forecast-model-quality.csv"
    backtest_rows = build_backtest_rows(input_rows, args.forecast_year, args.start_month, args.horizon_months, args.grain)
    write_csv(detail_path, rows, DETAIL_FIELDNAMES)
    write_csv(summary_path, build_summary_rows(rows), SUMMARY_FIELDNAMES)
    write_csv(top_delta_path, build_top_delta_rows(rows), DETAIL_FIELDNAMES)
    write_csv(backtest_path, backtest_rows, BACKTEST_FIELDNAMES)
    write_csv(quality_path, build_quality_rows(backtest_rows), QUALITY_FIELDNAMES)
    summary = {
        "schema": "codex.powerbi.aiForecast.v1",
        "rowCount": len(rows),
        "detailPath": str(detail_path),
        "summaryPath": str(summary_path),
        "topDeltaPath": str(top_delta_path),
        "backtestPath": str(backtest_path),
        "modelQualityPath": str(quality_path),
        "forecastYear": args.forecast_year,
        "startMonth": args.start_month,
        "endMonth": args.end_month,
        "asOfDate": args.as_of_date,
        "horizonMonths": args.horizon_months,
        "grain": args.grain,
    }
    print(json.dumps(summary, indent=2))


if __name__ == "__main__":
    main()

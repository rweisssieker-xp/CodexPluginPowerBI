# AI Forecast Design

Date: 2026-05-11

## Goal

Build a high-accuracy Power BI sales forecast focused on:

- Short-term accuracy for the next 1-3 months.
- Smallest practical granularity, targeting `Customer x Product x Month`.
- Explainable output that business users can compare against the existing roll forecast and budget.

The design uses the opened Power BI Desktop model as the source. Current live-model context includes sales invoices, dates, customers, products, budget, roll forecast, and sales order backlog.

## Recommended Approach

Use a hybrid AI/KI forecast:

```text
Final AI Forecast =
Actual Sales
+ Backlog Conversion Forecast
+ Statistical Demand Forecast
+ Hierarchical Reconciliation
```

Short-term months should be driven primarily by backlog conversion and current run-rate. Later months should use intermittent demand, seasonality, budget anchors, roll forecast anchors, and hierarchy fallback.

## Forecast Grain

Primary target grain:

```text
Customer x Product x Month
```

Fallback hierarchy:

```text
Customer x Product
-> CustomerHierarchy x ProductLine
-> CustomerHierarchy
-> ProductLine
-> Month total
```

The system must not force sparse customer-product pairs into unstable time-series models. Sparse combinations use higher-level fallback and shrinkage.

## Model Components

### 1. Actuals Layer

Purpose: Preserve known facts.

Rules:

- Use actual invoiced sales through the latest reliable invoice date.
- Do not forecast periods already fully actualized.
- For the current month, split into actual-to-date and remaining-month forecast.

### 2. Backlog Conversion Model

Purpose: Maximize accuracy for the next 1-3 months.

Inputs:

- Open backlog amount and quantity.
- Order date, requested ship date, receipt date, and age where available.
- Customer, customer hierarchy, product, product line, sales taker, region, and channel fields where available.
- Historical order-to-invoice behavior.

Predictions:

- Probability that backlog converts into invoice revenue by month.
- Expected converted revenue.
- Expected converted quantity.

Preferred models:

- LightGBM or XGBoost classifier for conversion probability.
- LightGBM or XGBoost regressor for expected revenue.
- Optional survival model for expected invoice timing.

### 3. Intermittent Demand Model

Purpose: Handle sparse customer-product demand.

Model selection by segment:

- Regular demand: seasonal trend or ML regression.
- Intermittent demand: Croston, SBA, TSB, or ADIDA.
- New or very sparse demand: hierarchy fallback.
- Top revenue segments: dedicated ML features and stronger validation.

### 4. ML Demand Model

Purpose: Predict residual demand not explained by backlog.

Features:

- Calendar month, working days, month position, quarter.
- Same month last year.
- Rolling 3/6/12 month sales and quantity.
- YTD growth vs prior year.
- Product, product line, customer, customer hierarchy.
- Budget and existing roll forecast.
- Price, discount, gross profit, and cost signals where available.
- Backlog coverage ratio.

Preferred models:

- LightGBM or XGBoost for tabular forecasting.
- Quantile regression for low/base/high scenarios.
- Optional global model across all segments rather than one model per segment.

### 5. Ensemble Layer

Purpose: Avoid over-reliance on one method.

Candidate signals:

- Existing roll forecast.
- Budget.
- Same month prior year plus current YTD growth.
- 3-year seasonal trend.
- Backlog conversion forecast.
- Intermittent demand forecast.
- ML demand forecast.

Weights should be learned through rolling-origin backtesting when enough historical forecast snapshots exist. Until then, use conservative default weights and mark confidence levels.

### 6. Reconciliation Layer

Purpose: Ensure detail forecasts sum to plausible month and year totals.

Process:

- Generate bottom-up forecasts at the finest stable grain.
- Generate top-down monthly targets from robust aggregate methods.
- Reconcile detailed forecasts to monthly targets while preserving segment proportions.
- Flag large segment-level movements versus roll forecast and budget.

## Output Table

Create an importable forecast table:

```text
AI_Forecast_CustomerProductMonth
```

Columns:

- ForecastVersion
- ForecastRunDate
- CustomerKey
- ProductKey
- CustomerHierarchy
- ProductLine
- Month
- ActualSales
- OpenBacklog
- BacklogConversionProbability
- ExpectedBacklogRevenue
- StatisticalDemandForecast
- ExistingRollForecast
- Budget
- FinalAIForecast
- ForecastLow
- ForecastHigh
- Confidence
- RiskFlag
- Explanation

## Power BI Measures

Add measures after the table exists:

- `_AI Forecast Sales`
- `_AI Forecast Low`
- `_AI Forecast High`
- `_AI Forecast vs Roll`
- `_AI Forecast vs Budget`
- `_AI Forecast Confidence`
- `_AI Forecast Backlog Revenue`
- `_AI Forecast Statistical Demand`

## Validation

Use rolling-origin backtesting:

- Train using data available up to a historical cutoff.
- Forecast the next 1, 2, and 3 months.
- Compare against actual invoice outcomes.

Metrics:

- WAPE for business-level accuracy.
- Bias for over/under-forecast tendency.
- MAE/RMSE for absolute error.
- Serviceable segment coverage.
- Error by customer hierarchy, product line, and top accounts.

Acceptance criteria:

- Beats existing roll forecast on 1-3 month WAPE for major segments.
- Does not materially increase bias.
- Produces confidence and explanation for every forecast row.
- Reconciled totals match defined monthly targets.

## Risks

- Customer-product grain can create sparse, noisy series.
- Historical forecast snapshots may be missing, limiting direct roll-forecast accuracy comparison.
- Backlog conversion requires reliable order-to-invoice linkage.
- Very large exports can be slow from live Power BI Desktop.

Mitigations:

- Use hierarchy fallback and shrinkage.
- Start with `CustomerHierarchy x ProductLine x Month`, then drill into `Customer x Product x Month`.
- Cache extracts locally.
- Keep the first implementation read-only and import results as a separate forecast table.

## Implementation Boundary

The first implementation should not modify the PBIX directly. It should:

- Read live model data.
- Generate reproducible forecast artifacts.
- Export forecast CSV or parquet.
- Provide DAX measure drafts separately.

Writing into the model should be a later explicit step through PBIP/TMDL or manual import.

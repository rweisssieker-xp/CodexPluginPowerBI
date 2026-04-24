# Power BI Metric Catalog

Schema: `codex.powerbi.metricCatalog.v1`
Root: `D:\temp\CodexPluginPowerBI\plugins\powerbi-desktop\examples\sample-model`
Generated: 2026-04-23T13:07:20
Metrics: 5

## Sales[All Customer Sales]

- ID: `sales.all-customer-sales`
- Source: `Risky.Measures.dax`
- Tags: finance, customer
- Risk level: review
- Risks: performance: FILTER over ALL
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]
- Validation question: Does `All Customer Sales` reconcile to the accepted business source for the selected filter context?

```DAX
CALCULATE (
    [Total Sales],
    FILTER ( ALL ( 'Customer' ), 'Customer'[IsActive] = TRUE () )
)
```

## Sales[Refresh Sensitive Sales]

- ID: `sales.refresh-sensitive-sales`
- Source: `Risky.Measures.dax`
- Tags: finance
- Risk level: review
- Risks: determinism: volatile date/time
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]
- Validation question: Does `Refresh Sensitive Sales` reconcile to the accepted business source for the selected filter context?

```DAX
IF ( TODAY () > DATE ( 2026, 1, 1 ), [Total Sales], BLANK () )
```

## Sales[Total Sales]

- ID: `sales.total-sales`
- Source: `Sales.Measures.dax`
- Tags: finance
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]
- Validation question: Does `Total Sales` reconcile to the accepted business source for the selected filter context?

```DAX
SUM ( 'Sales'[Sales Amount] )
```

## Sales[Sales YoY %]

- ID: `sales.sales-yoy-pct`
- Source: `Sales.Measures.dax`
- Tags: finance, time-intelligence, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]
- Validation question: Does `Sales YoY %` reconcile to the accepted business source for the selected filter context?

```DAX
DIVIDE (
    [Total Sales] - [Total Sales Prior Year],
    [Total Sales Prior Year]
)
```

## Sales[Total Sales Prior Year]

- ID: `sales.total-sales-prior-year`
- Source: `Sales.Measures.dax`
- Tags: finance, time-intelligence
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]
- Validation question: Does `Total Sales Prior Year` reconcile to the accepted business source for the selected filter context?

```DAX
CALCULATE (
    [Total Sales],
    SAMEPERIODLASTYEAR ( 'Date'[Date] )
)
```



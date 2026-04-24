# Power BI Model Summary

Root: `D:\temp\CodexPluginPowerBI\plugins\powerbi-desktop\examples\sample-model`
Generated: 2026-04-23 13:07:20

## Files

- `model.tmdl`
- `Risky.Measures.dax`
- `Sales.Measures.dax`
- `SalesQuery.pq`

## TMDL Objects

### column
- `OrderDate` from `model.tmdl`
- `Sales Amount` from `model.tmdl`
- `Date` from `model.tmdl`

### measure
- `Total Sales` from `model.tmdl`
- `Sales YoY %` from `model.tmdl`

### relationship
- `8f0d3c55-9976-4d16-8db4-9dd01ff9b43f` from `model.tmdl`

### table
- `Sales` from `model.tmdl`
- `Date` from `model.tmdl`


## DAX Measures

### 'Sales'[All Customer Sales]

Source: `Risky.Measures.dax`

```DAX
CALCULATE (
    [Total Sales],
    FILTER ( ALL ( 'Customer' ), 'Customer'[IsActive] = TRUE () )
)
```

### 'Sales'[Refresh Sensitive Sales]

Source: `Risky.Measures.dax`

```DAX
IF ( TODAY () > DATE ( 2026, 1, 1 ), [Total Sales], BLANK () )
```

### 'Sales'[Total Sales]

Source: `Sales.Measures.dax`

```DAX
SUM ( 'Sales'[Sales Amount] )
```

### 'Sales'[Sales YoY %]

Source: `Sales.Measures.dax`

```DAX
DIVIDE (
    [Total Sales] - [Total Sales Prior Year],
    [Total Sales Prior Year]
)
```

### 'Sales'[Total Sales Prior Year]

Source: `Sales.Measures.dax`

```DAX
CALCULATE (
    [Total Sales],
    SAMEPERIODLASTYEAR ( 'Date'[Date] )
)
```


## Power Query

- `SalesQuery` from `SalesQuery.pq`

## model.bim

No parseable model.bim files found.


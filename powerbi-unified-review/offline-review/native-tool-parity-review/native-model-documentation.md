# Power BI Native Model Documentation

Readiness: **Limited**
Metrics: 5
Dependencies: 5

## Metrics
- $(@{id=sales.all-customer-sales; name=All Customer Sales; table=Sales; source=Risky.Measures.dax; tags=System.Object[]; riskLevel=review; risks=System.Object[]; owner=[TODO: metric owner]; businessDefinition=[TODO: business definition]; validationQuestion=Does `All Customer Sales` reconcile to the accepted business source for the selected filter context?; expression=CALCULATE (
    [Total Sales],
    FILTER ( ALL ( 'Customer' ), 'Customer'[IsActive] = TRUE () )
)}.table)[All Customer Sales]: Does `All Customer Sales` reconcile to the accepted business source for the selected filter context?
- $(@{id=sales.refresh-sensitive-sales; name=Refresh Sensitive Sales; table=Sales; source=Risky.Measures.dax; tags=System.Object[]; riskLevel=review; risks=System.Object[]; owner=[TODO: metric owner]; businessDefinition=[TODO: business definition]; validationQuestion=Does `Refresh Sensitive Sales` reconcile to the accepted business source for the selected filter context?; expression=IF ( TODAY () > DATE ( 2026, 1, 1 ), [Total Sales], BLANK () )}.table)[Refresh Sensitive Sales]: Does `Refresh Sensitive Sales` reconcile to the accepted business source for the selected filter context?
- $(@{id=sales.total-sales; name=Total Sales; table=Sales; source=Sales.Measures.dax; tags=System.Object[]; riskLevel=normal; risks=System.Object[]; owner=[TODO: metric owner]; businessDefinition=[TODO: business definition]; validationQuestion=Does `Total Sales` reconcile to the accepted business source for the selected filter context?; expression=SUM ( 'Sales'[Sales Amount] )}.table)[Total Sales]: Does `Total Sales` reconcile to the accepted business source for the selected filter context?
- $(@{id=sales.sales-yoy-pct; name=Sales YoY %; table=Sales; source=Sales.Measures.dax; tags=System.Object[]; riskLevel=normal; risks=System.Object[]; owner=[TODO: metric owner]; businessDefinition=[TODO: business definition]; validationQuestion=Does `Sales YoY %` reconcile to the accepted business source for the selected filter context?; expression=DIVIDE (
    [Total Sales] - [Total Sales Prior Year],
    [Total Sales Prior Year]
)}.table)[Sales YoY %]: Does `Sales YoY %` reconcile to the accepted business source for the selected filter context?
- $(@{id=sales.total-sales-prior-year; name=Total Sales Prior Year; table=Sales; source=Sales.Measures.dax; tags=System.Object[]; riskLevel=normal; risks=System.Object[]; owner=[TODO: metric owner]; businessDefinition=[TODO: business definition]; validationQuestion=Does `Total Sales Prior Year` reconcile to the accepted business source for the selected filter context?; expression=CALCULATE (
    [Total Sales],
    SAMEPERIODLASTYEAR ( 'Date'[Date] )
)}.table)[Total Sales Prior Year]: Does `Total Sales Prior Year` reconcile to the accepted business source for the selected filter context?


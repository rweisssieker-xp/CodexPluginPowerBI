# DAX Studio Workflow

Installed: True

## Guidance
- Open DAX Studio against the Desktop model.
- Enable Server Timings and Query Plan for performance diagnostics.
- Run generated validation queries before and after DAX changes.

## Query Drafts
```DAX
EVALUATE ROW("All Customer Sales", [All Customer Sales])
```
```DAX
EVALUATE ROW("IsBlank", ISBLANK([All Customer Sales]), "Value", [All Customer Sales])
```
```DAX
EVALUATE TOPN(10, SUMMARIZECOLUMNS("All Customer Sales", [All Customer Sales]))
```
```DAX
EVALUATE ROW("Refresh Sensitive Sales", [Refresh Sensitive Sales])
```
```DAX
EVALUATE ROW("IsBlank", ISBLANK([Refresh Sensitive Sales]), "Value", [Refresh Sensitive Sales])
```
```DAX
EVALUATE TOPN(10, SUMMARIZECOLUMNS("Refresh Sensitive Sales", [Refresh Sensitive Sales]))
```
```DAX
EVALUATE ROW("Total Sales", [Total Sales])
```
```DAX
EVALUATE ROW("IsBlank", ISBLANK([Total Sales]), "Value", [Total Sales])
```
```DAX
EVALUATE TOPN(10, SUMMARIZECOLUMNS("Total Sales", [Total Sales]))
```
```DAX
EVALUATE ROW("Sales YoY %", [Sales YoY %])
```
```DAX
EVALUATE ROW("IsBlank", ISBLANK([Sales YoY %]), "Value", [Sales YoY %])
```
```DAX
EVALUATE TOPN(10, SUMMARIZECOLUMNS("Sales YoY %", [Sales YoY %]))
```
```DAX
EVALUATE ROW("BelowZero", [Sales YoY %] < 0, "AboveOne", [Sales YoY %] > 1, "Value", [Sales YoY %])
```
```DAX
EVALUATE ROW("Total Sales Prior Year", [Total Sales Prior Year])
```
```DAX
EVALUATE ROW("IsBlank", ISBLANK([Total Sales Prior Year]), "Value", [Total Sales Prior Year])
```
```DAX
EVALUATE TOPN(10, SUMMARIZECOLUMNS("Total Sales Prior Year", [Total Sales Prior Year]))
```


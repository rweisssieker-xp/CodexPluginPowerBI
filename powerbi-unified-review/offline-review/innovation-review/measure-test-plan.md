# Power BI Measure Test Plan

Measures: 5
Tests: 16

## All Customer Sales: Smoke
Measure evaluates without an exception in the default filter context.

```DAX
EVALUATE ROW("All Customer Sales", [All Customer Sales])
```

## All Customer Sales: BlankOrZero
Measure returns a value, blank, or zero intentionally; reviewer confirms semantics.

```DAX
EVALUATE ROW("IsBlank", ISBLANK([All Customer Sales]), "Value", [All Customer Sales])
```

## All Customer Sales: FilterContext
Measure is stable under a summarized table context.

```DAX
EVALUATE TOPN(10, SUMMARIZECOLUMNS("All Customer Sales", [All Customer Sales]))
```

## Refresh Sensitive Sales: Smoke
Measure evaluates without an exception in the default filter context.

```DAX
EVALUATE ROW("Refresh Sensitive Sales", [Refresh Sensitive Sales])
```

## Refresh Sensitive Sales: BlankOrZero
Measure returns a value, blank, or zero intentionally; reviewer confirms semantics.

```DAX
EVALUATE ROW("IsBlank", ISBLANK([Refresh Sensitive Sales]), "Value", [Refresh Sensitive Sales])
```

## Refresh Sensitive Sales: FilterContext
Measure is stable under a summarized table context.

```DAX
EVALUATE TOPN(10, SUMMARIZECOLUMNS("Refresh Sensitive Sales", [Refresh Sensitive Sales]))
```

## Total Sales: Smoke
Measure evaluates without an exception in the default filter context.

```DAX
EVALUATE ROW("Total Sales", [Total Sales])
```

## Total Sales: BlankOrZero
Measure returns a value, blank, or zero intentionally; reviewer confirms semantics.

```DAX
EVALUATE ROW("IsBlank", ISBLANK([Total Sales]), "Value", [Total Sales])
```

## Total Sales: FilterContext
Measure is stable under a summarized table context.

```DAX
EVALUATE TOPN(10, SUMMARIZECOLUMNS("Total Sales", [Total Sales]))
```

## Sales YoY %: Smoke
Measure evaluates without an exception in the default filter context.

```DAX
EVALUATE ROW("Sales YoY %", [Sales YoY %])
```

## Sales YoY %: BlankOrZero
Measure returns a value, blank, or zero intentionally; reviewer confirms semantics.

```DAX
EVALUATE ROW("IsBlank", ISBLANK([Sales YoY %]), "Value", [Sales YoY %])
```

## Sales YoY %: FilterContext
Measure is stable under a summarized table context.

```DAX
EVALUATE TOPN(10, SUMMARIZECOLUMNS("Sales YoY %", [Sales YoY %]))
```

## Sales YoY %: Range
Ratio-like measure should be reviewed for expected bounds.

```DAX
EVALUATE ROW("BelowZero", [Sales YoY %] < 0, "AboveOne", [Sales YoY %] > 1, "Value", [Sales YoY %])
```

## Total Sales Prior Year: Smoke
Measure evaluates without an exception in the default filter context.

```DAX
EVALUATE ROW("Total Sales Prior Year", [Total Sales Prior Year])
```

## Total Sales Prior Year: BlankOrZero
Measure returns a value, blank, or zero intentionally; reviewer confirms semantics.

```DAX
EVALUATE ROW("IsBlank", ISBLANK([Total Sales Prior Year]), "Value", [Total Sales Prior Year])
```

## Total Sales Prior Year: FilterContext
Measure is stable under a summarized table context.

```DAX
EVALUATE TOPN(10, SUMMARIZECOLUMNS("Total Sales Prior Year", [Total Sales Prior Year]))
```



# Power BI Measure Lineage Impact

Measures: 5

## Total Sales
- Impact score: 12
- Upstream: none
- Downstream: All Customer Sales, Refresh Sensitive Sales, Sales YoY %, Total Sales Prior Year
- Guidance: Validate dependent measures before publishing.

## Total Sales Prior Year
- Impact score: 4
- Upstream: Total Sales
- Downstream: Sales YoY %
- Guidance: Validate dependent measures before publishing.

## All Customer Sales
- Impact score: 3
- Upstream: Total Sales
- Downstream: none
- Guidance: Validate direct business result and formatting.

## Refresh Sensitive Sales
- Impact score: 3
- Upstream: Total Sales
- Downstream: none
- Guidance: Validate direct business result and formatting.

## Sales YoY %
- Impact score: 2
- Upstream: Total Sales, Total Sales Prior Year
- Downstream: none
- Guidance: Validate direct business result and formatting.



# Power BI DAX Dependency Graph

Schema: `codex.powerbi.dependencyGraph.v1`
Metrics: 5
Dependencies: 5

## Hub Metrics

- `Total Sales`: incoming 4, outgoing 0, risk normal
- `Sales YoY %`: incoming 0, outgoing 2, risk normal
- `Total Sales Prior Year`: incoming 1, outgoing 1, risk normal
- `All Customer Sales`: incoming 0, outgoing 1, risk review
- `Refresh Sensitive Sales`: incoming 0, outgoing 1, risk review

## Dependencies

- `All Customer Sales` depends on `Total Sales`
- `Refresh Sensitive Sales` depends on `Total Sales`
- `Sales YoY %` depends on `Total Sales`
- `Sales YoY %` depends on `Total Sales Prior Year`
- `Total Sales Prior Year` depends on `Total Sales`


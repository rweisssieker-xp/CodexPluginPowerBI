# Power BI Live Insight Scan

Server: `Data Source=localhost:64728`
- Risk level: **High**
- Risk score: **44**
- Tables: 80
- Measures: 170
- Relationships: 76
- Dependency edges: 214

## Findings

### [Medium] Many auto date tables
- Category: Model Design
- Source: `model`
- Detail: Detected 72 hidden LocalDateTable objects. Consider a governed date table and disabling auto date/time.

### [Medium] maintainability: long expression
- Category: Measure Risk
- Source: `Gleitender Durchschnitt für "_CountIncidents"`
- Detail: Review measure `Gleitender Durchschnitt für "_CountIncidents"` in table `IncidentsAllFields`.

### [Medium] maintainability: long expression
- Category: Measure Risk
- Source: `_SRA_Top Driver Theme`
- Detail: Review measure `_SRA_Top Driver Theme` in table `IncidentsAllFields`.

### [Medium] maintainability: long expression
- Category: Measure Risk
- Source: `_SRA_Ticket Recommended Action`
- Detail: Review measure `_SRA_Ticket Recommended Action` in table `IncidentsAllFields`.

### [Medium] maintainability: long expression
- Category: Measure Risk
- Source: `_SRA_Ticket Risk Score`
- Detail: Review measure `_SRA_Ticket Risk Score` in table `IncidentsAllFields`.

### [Medium] determinism: volatile date/time
- Category: Measure Risk
- Source: `_SRA_Ticket Recommended Action`
- Detail: Review measure `_SRA_Ticket Recommended Action` in table `IncidentsAllFields`.

### [Medium] determinism: volatile date/time
- Category: Measure Risk
- Source: `_SRA_Overdue Open Tickets`
- Detail: Review measure `_SRA_Overdue Open Tickets` in table `IncidentsAllFields`.

### [Medium] determinism: volatile date/time
- Category: Measure Risk
- Source: `_SRA_SLA Due Next 24h`
- Detail: Review measure `_SRA_SLA Due Next 24h` in table `IncidentsAllFields`.

### [Medium] determinism: volatile date/time
- Category: Measure Risk
- Source: `_SRA_Ticket Risk Score`
- Detail: Review measure `_SRA_Ticket Risk Score` in table `IncidentsAllFields`.

### [Medium] determinism: volatile date/time
- Category: Measure Risk
- Source: `_Quarter_Performance_Trend`
- Detail: Review measure `_Quarter_Performance_Trend` in table `IncidentsAllFields`.

### [Medium] determinism: volatile date/time
- Category: Measure Risk
- Source: `_Cyclical_Pattern_Detected`
- Detail: Review measure `_Cyclical_Pattern_Detected` in table `IncidentsAllFields`.

### [Medium] determinism: volatile date/time
- Category: Measure Risk
- Source: `_Holiday_Impact_Index`
- Detail: Review measure `_Holiday_Impact_Index` in table `IncidentsAllFields`.

### [Medium] determinism: volatile date/time
- Category: Measure Risk
- Source: `_Overdue_Tickets_Count`
- Detail: Review measure `_Overdue_Tickets_Count` in table `IncidentsAllFields`.

### [Medium] determinism: volatile date/time
- Category: Measure Risk
- Source: `_Status_Date_Mismatch_Count`
- Detail: Review measure `_Status_Date_Mismatch_Count` in table `IncidentsAllFields`.

### [Medium] determinism: volatile date/time
- Category: Measure Risk
- Source: `_Potential_SLA_Breach_24h`
- Detail: Review measure `_Potential_SLA_Breach_24h` in table `IncidentsAllFields`.

### [Medium] High-impact hub measure
- Category: Impact Analysis
- Source: `_SLA_Compliance`
- Detail: Measure _SLA_Compliance has dependency hub score 18. Validate downstream impact before changing it.

### [Medium] High-impact hub measure
- Category: Impact Analysis
- Source: `_CountIncidents`
- Detail: Measure _CountIncidents has dependency hub score 46. Validate downstream impact before changing it.

### [Medium] High-impact hub measure
- Category: Impact Analysis
- Source: `_FirstContactResolutionRate_FCR`
- Detail: Measure _FirstContactResolutionRate_FCR has dependency hub score 14. Validate downstream impact before changing it.

### [Medium] High-impact hub measure
- Category: Impact Analysis
- Source: `_Open_Incidents`
- Detail: Measure _Open_Incidents has dependency hub score 10. Validate downstream impact before changing it.

### [Medium] High-impact hub measure
- Category: Impact Analysis
- Source: `_AVG TTS`
- Detail: Measure _AVG TTS has dependency hub score 11. Validate downstream impact before changing it.

### [Low] Missing measure description
- Category: Metric Governance
- Source: `_DurationTicket`
- Detail: Measure has no model description. Add a business definition for governed use.

### [Low] Missing measure description
- Category: Metric Governance
- Source: `_SumUsedHours`
- Detail: Measure has no model description. Add a business definition for governed use.

### [Low] Missing measure description
- Category: Metric Governance
- Source: `_CountDescription`
- Detail: Measure has no model description. Add a business definition for governed use.

### [Low] usability: measure can intentionally raise ERROR
- Category: Measure Risk
- Source: `Gleitender Durchschnitt für "_CountIncidents"`
- Detail: Review measure `Gleitender Durchschnitt für "_CountIncidents"` in table `IncidentsAllFields`.



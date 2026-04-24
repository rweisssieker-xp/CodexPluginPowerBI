# Power BI Live Insight Scan

Server: `Data Source=localhost:63952`
- Risk level: **High**
- Risk score: **121**
- Tables: 80
- Measures: 139
- Relationships: 76
- Dependency edges: 170

## Findings

### [High] performance: FILTER over ALL
- Category: Measure Risk
- Source: `_Tickets_3_7Days`
- Detail: Review measure `_Tickets_3_7Days` in table `IncidentsAllFields`.

### [High] performance: FILTER over ALL
- Category: Measure Risk
- Source: `_Tickets_1_3Days`
- Detail: Review measure `_Tickets_1_3Days` in table `IncidentsAllFields`.

### [High] performance: FILTER over ALL
- Category: Measure Risk
- Source: `_Tickets_Over_7Days`
- Detail: Review measure `_Tickets_Over_7Days` in table `IncidentsAllFields`.

### [High] performance: FILTER over ALL
- Category: Measure Risk
- Source: `_Tickets_0_1Day`
- Detail: Review measure `_Tickets_0_1Day` in table `IncidentsAllFields`.

### [High] performance: FILTER over ALL
- Category: Measure Risk
- Source: `_Anomaly_High_Resolution_Time`
- Detail: Review measure `_Anomaly_High_Resolution_Time` in table `IncidentsAllFields`.

### [High] performance: FILTER over ALL
- Category: Measure Risk
- Source: `_Repeat_Customer_Rate`
- Detail: Review measure `_Repeat_Customer_Rate` in table `IncidentsAllFields`.

### [High] performance: ALL over fact table
- Category: Measure Risk
- Source: `_Anomaly_High_Resolution_Time`
- Detail: Review measure `_Anomaly_High_Resolution_Time` in table `IncidentsAllFields`.

### [High] performance: ALL over fact table
- Category: Measure Risk
- Source: `_Resolution_Time_StdDev`
- Detail: Review measure `_Resolution_Time_StdDev` in table `IncidentsAllFields`.

### [High] performance: ALL over fact table
- Category: Measure Risk
- Source: `_Tickets_Over_7Days`
- Detail: Review measure `_Tickets_Over_7Days` in table `IncidentsAllFields`.

### [High] performance: ALL over fact table
- Category: Measure Risk
- Source: `_Volume_vs_Baseline_Index`
- Detail: Review measure `_Volume_vs_Baseline_Index` in table `IncidentsAllFields`.

### [High] performance: ALL over fact table
- Category: Measure Risk
- Source: `_Repeat_Customer_Rate`
- Detail: Review measure `_Repeat_Customer_Rate` in table `IncidentsAllFields`.

### [High] performance: ALL over fact table
- Category: Measure Risk
- Source: `_Tickets_3_7Days`
- Detail: Review measure `_Tickets_3_7Days` in table `IncidentsAllFields`.

### [High] performance: ALL over fact table
- Category: Measure Risk
- Source: `_Tickets_1_3Days`
- Detail: Review measure `_Tickets_1_3Days` in table `IncidentsAllFields`.

### [High] performance: ALL over fact table
- Category: Measure Risk
- Source: `_Tickets_0_1Day`
- Detail: Review measure `_Tickets_0_1Day` in table `IncidentsAllFields`.

### [High] correctness: Excel-style COUNTIF in DAX
- Category: Measure Risk
- Source: `_Handoff_Success_Rate`
- Detail: Review measure `_Handoff_Success_Rate` in table `IncidentsAllFields`.

### [High] correctness: Excel-style COUNTIF in DAX
- Category: Measure Risk
- Source: `_Ticket_Rework_Rate`
- Detail: Review measure `_Ticket_Rework_Rate` in table `IncidentsAllFields`.

### [High] correctness: Excel-style COUNTIF in DAX
- Category: Measure Risk
- Source: `_Peak_Business_Hours_Concentration`
- Detail: Review measure `_Peak_Business_Hours_Concentration` in table `IncidentsAllFields`.

### [High] correctness: Excel-style COUNTIF in DAX
- Category: Measure Risk
- Source: `_Ticket_Type_TTR_Prediction`
- Detail: Review measure `_Ticket_Type_TTR_Prediction` in table `IncidentsAllFields`.

### [High] correctness: Excel-style COUNTIF in DAX
- Category: Measure Risk
- Source: `_Root_Cause_Correlation_Score`
- Detail: Review measure `_Root_Cause_Correlation_Score` in table `IncidentsAllFields`.

### [High] correctness: Excel-style COUNTIF in DAX
- Category: Measure Risk
- Source: `_Channel_Performance_Email`
- Detail: Review measure `_Channel_Performance_Email` in table `IncidentsAllFields`.

### [High] correctness: Excel-style COUNTIF in DAX
- Category: Measure Risk
- Source: `_Data_Privacy_Compliance`
- Detail: Review measure `_Data_Privacy_Compliance` in table `IncidentsAllFields`.

### [High] correctness: Excel-style COUNTIF in DAX
- Category: Measure Risk
- Source: `_Escalation_Authority_Compliance`
- Detail: Review measure `_Escalation_Authority_Compliance` in table `IncidentsAllFields`.

### [High] correctness: Excel-style COUNTIF in DAX
- Category: Measure Risk
- Source: `_Context_Switching_Cost`
- Detail: Review measure `_Context_Switching_Cost` in table `IncidentsAllFields`.

### [High] correctness: Excel-style COUNTIF in DAX
- Category: Measure Risk
- Source: `_Preferred_Channel_Detection`
- Detail: Review measure `_Preferred_Channel_Detection` in table `IncidentsAllFields`.

### [High] correctness: Excel-style COUNTIF in DAX
- Category: Measure Risk
- Source: `_Channel_CSAT_Differential`
- Detail: Review measure `_Channel_CSAT_Differential` in table `IncidentsAllFields`.

### [High] correctness: Excel-style COUNTIF in DAX
- Category: Measure Risk
- Source: `_CSAT_Score`
- Detail: Review measure `_CSAT_Score` in table `IncidentsAllFields`.

### [High] correctness: Excel-style COUNTIF in DAX
- Category: Measure Risk
- Source: `_Root_Cause_Identification_Rate`
- Detail: Review measure `_Root_Cause_Identification_Rate` in table `IncidentsAllFields`.

### [High] correctness: Excel-style COUNTIF in DAX
- Category: Measure Risk
- Source: `_Top_Problem_Categories_Pareto`
- Detail: Review measure `_Top_Problem_Categories_Pareto` in table `IncidentsAllFields`.

### [High] correctness: Excel-style COUNTIF in DAX
- Category: Measure Risk
- Source: `_KB_Self_Service_Rate`
- Detail: Review measure `_KB_Self_Service_Rate` in table `IncidentsAllFields`.

### [High] correctness: Excel-style COUNTIF in DAX
- Category: Measure Risk
- Source: `_Agents_Needing_Training`
- Detail: Review measure `_Agents_Needing_Training` in table `IncidentsAllFields`.

### [High] correctness: Excel-style COUNTIF in DAX
- Category: Measure Risk
- Source: `_Recurring_Issue_Ratio`
- Detail: Review measure `_Recurring_Issue_Ratio` in table `IncidentsAllFields`.

### [Medium] Many auto date tables
- Category: Model Design
- Source: `model`
- Detail: Detected 72 hidden LocalDateTable objects. Consider a governed date table and disabling auto date/time.

### [Medium] maintainability: long expression
- Category: Measure Risk
- Source: `Gleitender Durchschnitt für "_CountIncidents"`
- Detail: Review measure `Gleitender Durchschnitt für "_CountIncidents"` in table `IncidentsAllFields`.

### [Medium] determinism: volatile date/time
- Category: Measure Risk
- Source: `_Cyclical_Pattern_Detected`
- Detail: Review measure `_Cyclical_Pattern_Detected` in table `IncidentsAllFields`.

### [Medium] determinism: volatile date/time
- Category: Measure Risk
- Source: `_Quarter_Performance_Trend`
- Detail: Review measure `_Quarter_Performance_Trend` in table `IncidentsAllFields`.

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
- Source: `_Holiday_Impact_Index`
- Detail: Review measure `_Holiday_Impact_Index` in table `IncidentsAllFields`.

### [Medium] determinism: volatile date/time
- Category: Measure Risk
- Source: `_Potential_SLA_Breach_24h`
- Detail: Review measure `_Potential_SLA_Breach_24h` in table `IncidentsAllFields`.

### [Medium] High-impact hub measure
- Category: Impact Analysis
- Source: `_FirstContactResolutionRate_FCR`
- Detail: Measure _FirstContactResolutionRate_FCR has dependency hub score 14. Validate downstream impact before changing it.

### [Medium] High-impact hub measure
- Category: Impact Analysis
- Source: `_CountIncidents`
- Detail: Measure _CountIncidents has dependency hub score 39. Validate downstream impact before changing it.

### [Medium] High-impact hub measure
- Category: Impact Analysis
- Source: `_SLA_Compliance`
- Detail: Measure _SLA_Compliance has dependency hub score 17. Validate downstream impact before changing it.

### [Medium] High-impact hub measure
- Category: Impact Analysis
- Source: `_AVG TTS`
- Detail: Measure _AVG TTS has dependency hub score 11. Validate downstream impact before changing it.

### [Low] Missing measure description
- Category: Metric Governance
- Source: `_SumUsedHours`
- Detail: Measure has no model description. Add a business definition for governed use.

### [Low] Missing measure description
- Category: Metric Governance
- Source: `_CountDescription`
- Detail: Measure has no model description. Add a business definition for governed use.

### [Low] Missing measure description
- Category: Metric Governance
- Source: `_DurationTicket`
- Detail: Measure has no model description. Add a business definition for governed use.

### [Low] usability: measure can intentionally raise ERROR
- Category: Measure Risk
- Source: `Gleitender Durchschnitt für "_CountIncidents"`
- Detail: Review measure `Gleitender Durchschnitt für "_CountIncidents"` in table `IncidentsAllFields`.



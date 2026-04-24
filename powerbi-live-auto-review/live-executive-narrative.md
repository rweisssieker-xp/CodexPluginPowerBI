# Power BI Live Executive Narrative

The open Power BI Desktop model is rated **High** risk with score **121**.
The live model contains **80** tables, **139** measures, **76** relationships, and **170** measure dependencies.

## Most Important Signals

- **performance: FILTER over ALL** on `_Tickets_3_7Days`: Review measure `_Tickets_3_7Days` in table `IncidentsAllFields`.
- **performance: FILTER over ALL** on `_Tickets_1_3Days`: Review measure `_Tickets_1_3Days` in table `IncidentsAllFields`.
- **performance: FILTER over ALL** on `_Tickets_Over_7Days`: Review measure `_Tickets_Over_7Days` in table `IncidentsAllFields`.
- **performance: FILTER over ALL** on `_Tickets_0_1Day`: Review measure `_Tickets_0_1Day` in table `IncidentsAllFields`.
- **performance: FILTER over ALL** on `_Anomaly_High_Resolution_Time`: Review measure `_Anomaly_High_Resolution_Time` in table `IncidentsAllFields`.
- **performance: FILTER over ALL** on `_Repeat_Customer_Rate`: Review measure `_Repeat_Customer_Rate` in table `IncidentsAllFields`.
- **performance: ALL over fact table** on `_Anomaly_High_Resolution_Time`: Review measure `_Anomaly_High_Resolution_Time` in table `IncidentsAllFields`.
- **performance: ALL over fact table** on `_Resolution_Time_StdDev`: Review measure `_Resolution_Time_StdDev` in table `IncidentsAllFields`.

## Highest-Impact Measures

- `_CountIncidents`: hub score 39, incoming 39, outgoing 0
- `_SLA_Compliance`: hub score 17, incoming 16, outgoing 1
- `_FirstContactResolutionRate_FCR`: hub score 14, incoming 14, outgoing 0
- `_AVG TTS`: hub score 11, incoming 11, outgoing 0
- `_Cost_Per_Resolution`: hub score 9, incoming 8, outgoing 1
- `_Churn_Risk_Indicator`: hub score 7, incoming 5, outgoing 2
- `_Team_Stress_Index`: hub score 7, incoming 4, outgoing 3
- `_Open_Incidents`: hub score 6, incoming 6, outgoing 0

## First Actions

- Add descriptions and owners to business-critical measures.
- Review high-risk DAX patterns before changing visuals.
- Validate hub measures before publishing because downstream metrics may change.


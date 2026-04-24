# Power BI Live Fix Backlog

Risk level: **High**
Risk score: **121**
Items: 45

## [P0] Fix failing measure `_Ticket_Velocity`
- Theme: Broken Measures
- Source: `_Ticket_Velocity`
- Why: Ausnahme beim Aufrufen von "Read" mit 0 Argument(en):  "MdxScript(Model) (129, 96) Von der Funktion 'DISTINCTCOUNT' wird nur ein Spaltenverweis als Argument akzeptiert."
- Action: Open the measure expression, remove invalid filter predicates, and rerun live validation before publishing.
- Validation: Run Test-PowerBILiveMeasures.ps1 and confirm `_Ticket_Velocity` passes.

## [P0] Fix failing measure `_Team_Stress_Index`
- Theme: Broken Measures
- Source: `_Team_Stress_Index`
- Why: Ausnahme beim Aufrufen von "Read" mit 0 Argument(en):  "MdxScript(Model) (126, 103) Berechnungsfehler in dem Measure "IncidentsAllFields"[_Escalation_Rate]: Die Spalte "escalationtime" in der Tabelle "IncidentsAllFields" wurde nicht gefunden oder darf in diesem Ausdruck nicht verwendet werden."
- Action: Open the measure expression, remove invalid filter predicates, and rerun live validation before publishing.
- Validation: Run Test-PowerBILiveMeasures.ps1 and confirm `_Team_Stress_Index` passes.

## [P0] Fix failing measure `_SLA_Compliance`
- Theme: Broken Measures
- Source: `_SLA_Compliance`
- Why: Ausnahme beim Aufrufen von "Read" mit 0 Argument(en):  "MdxScript(Model) (123, 102) Berechnungsfehler in dem Measure "IncidentsAllFields"[_SLA_Compliance]: Eine Funktion vom Typ 'PLACEHOLDER' wurde in einem True/False-Ausdruck verwendet, der als Tabellenfilterausdruck dient. Dies ist nicht zulässig."
- Action: Open the measure expression, remove invalid filter predicates, and rerun live validation before publishing.
- Validation: Run Test-PowerBILiveMeasures.ps1 and confirm `_SLA_Compliance` passes.

## [P0] Fix failing measure `_Executive_Health_Score`
- Theme: Broken Measures
- Source: `_Executive_Health_Score`
- Why: Ausnahme beim Aufrufen von "Read" mit 0 Argument(en):  "MdxScript(Model) (123, 102) Berechnungsfehler in dem Measure "IncidentsAllFields"[_SLA_Compliance]: Eine Funktion vom Typ 'PLACEHOLDER' wurde in einem True/False-Ausdruck verwendet, der als Tabellenfilterausdruck dient. Dies ist nicht zulässig."
- Action: Open the measure expression, remove invalid filter predicates, and rerun live validation before publishing.
- Validation: Run Test-PowerBILiveMeasures.ps1 and confirm `_Executive_Health_Score` passes.

## [P0] Fix failing measure `_Escalation_Rate`
- Theme: Broken Measures
- Source: `_Escalation_Rate`
- Why: Ausnahme beim Aufrufen von "Read" mit 0 Argument(en):  "MdxScript(Model) (126, 103) Berechnungsfehler in dem Measure "IncidentsAllFields"[_Escalation_Rate]: Die Spalte "escalationtime" in der Tabelle "IncidentsAllFields" wurde nicht gefunden oder darf in diesem Ausdruck nicht verwendet werden."
- Action: Open the measure expression, remove invalid filter predicates, and rerun live validation before publishing.
- Validation: Run Test-PowerBILiveMeasures.ps1 and confirm `_Escalation_Rate` passes.

## [P0] Fix failing measure `_Effort_Reduction_Opportunity`
- Theme: Broken Measures
- Source: `_Effort_Reduction_Opportunity`
- Why: Ausnahme beim Aufrufen von "Read" mit 0 Argument(en):  "MdxScript(Model) (182, 57) Fehler beim Auflösen des Namens "COUNTIF". Dies ist kein gültiger Tabellen-, Variablen- oder Funktionsname."
- Action: Open the measure expression, remove invalid filter predicates, and rerun live validation before publishing.
- Validation: Run Test-PowerBILiveMeasures.ps1 and confirm `_Effort_Reduction_Opportunity` passes.

## [P0] Fix failing measure `_Critical_Alerts_Count`
- Theme: Broken Measures
- Source: `_Critical_Alerts_Count`
- Why: Ausnahme beim Aufrufen von "Read" mit 0 Argument(en):  "MdxScript(Model) (123, 102) Berechnungsfehler in dem Measure "IncidentsAllFields"[_SLA_Compliance]: Eine Funktion vom Typ 'PLACEHOLDER' wurde in einem True/False-Ausdruck verwendet, der als Tabellenfilterausdruck dient. Dies ist nicht zulässig."
- Action: Open the measure expression, remove invalid filter predicates, and rerun live validation before publishing.
- Validation: Run Test-PowerBILiveMeasures.ps1 and confirm `_Critical_Alerts_Count` passes.

## [P0] Fix failing measure `_Cost_Savings_Potential`
- Theme: Broken Measures
- Source: `_Cost_Savings_Potential`
- Why: Ausnahme beim Aufrufen von "Read" mit 0 Argument(en):  "MdxScript(Model) (123, 102) Berechnungsfehler in dem Measure "IncidentsAllFields"[_SLA_Compliance]: Eine Funktion vom Typ 'PLACEHOLDER' wurde in einem True/False-Ausdruck verwendet, der als Tabellenfilterausdruck dient. Dies ist nicht zulässig."
- Action: Open the measure expression, remove invalid filter predicates, and rerun live validation before publishing.
- Validation: Run Test-PowerBILiveMeasures.ps1 and confirm `_Cost_Savings_Potential` passes.

## [P0] Fix failing measure `_Compliance_Audit_Ready_Index`
- Theme: Broken Measures
- Source: `_Compliance_Audit_Ready_Index`
- Why: Ausnahme beim Aufrufen von "Read" mit 0 Argument(en):  "MdxScript(Model) (123, 102) Berechnungsfehler in dem Measure "IncidentsAllFields"[_SLA_Compliance]: Eine Funktion vom Typ 'PLACEHOLDER' wurde in einem True/False-Ausdruck verwendet, der als Tabellenfilterausdruck dient. Dies ist nicht zulässig."
- Action: Open the measure expression, remove invalid filter predicates, and rerun live validation before publishing.
- Validation: Run Test-PowerBILiveMeasures.ps1 and confirm `_Compliance_Audit_Ready_Index` passes.

## [P0] Fix failing measure `_Agent_Burnout_Risk`
- Theme: Broken Measures
- Source: `_Agent_Burnout_Risk`
- Why: Ausnahme beim Aufrufen von "ExecuteReader" mit 0 Argument(en):  "MdxScript(Model) (126, 103) Berechnungsfehler in dem Measure "IncidentsAllFields"[_Escalation_Rate]: Die Spalte "escalationtime" in der Tabelle "IncidentsAllFields" wurde nicht gefunden oder darf in diesem Ausdruck nicht verwendet werden."
- Action: Open the measure expression, remove invalid filter predicates, and rerun live validation before publishing.
- Validation: Run Test-PowerBILiveMeasures.ps1 and confirm `_Agent_Burnout_Risk` passes.

## [P1] Replace auto date tables with a governed date table
- Theme: Model Design
- Source: `model`
- Why: Detected 72 hidden local date tables. Prefer a governed date table.
- Action: Create or designate a governed calendar table, mark it as date table, remap time-intelligence measures, then disable auto date/time where appropriate.
- Validation: Refresh the model and confirm LocalDateTable object count drops as expected.

## [P1] Refactor `_Volume_vs_Baseline_Index`: performance: ALL over fact table
- Theme: DAX Refactoring
- Source: `_Volume_vs_Baseline_Index`
- Why: Risk detected: performance: ALL over fact table
- Action: Avoid clearing filters on the full fact table. Clear only the required dimension or column filters.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [P1] Refactor `_Top_Problem_Categories_Pareto`: correctness: Excel-style COUNTIF in DAX
- Theme: DAX Refactoring
- Source: `_Top_Problem_Categories_Pareto`
- Why: Risk detected: correctness: Excel-style COUNTIF in DAX
- Action: Rewrite using CALCULATE with COUNTROWS/FILTER or a native DAX aggregation. COUNTIF is not a standard DAX function.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [P1] Refactor `_Tickets_Over_7Days`: performance: FILTER over ALL
- Theme: DAX Refactoring
- Source: `_Tickets_Over_7Days`
- Why: Risk detected: performance: FILTER over ALL
- Action: Benchmark a narrower filter expression. Prefer REMOVEFILTERS on required columns or KEEPFILTERS when semantics allow.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [P1] Refactor `_Tickets_Over_7Days`: performance: ALL over fact table
- Theme: DAX Refactoring
- Source: `_Tickets_Over_7Days`
- Why: Risk detected: performance: ALL over fact table
- Action: Avoid clearing filters on the full fact table. Clear only the required dimension or column filters.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [P1] Refactor `_Tickets_3_7Days`: performance: FILTER over ALL
- Theme: DAX Refactoring
- Source: `_Tickets_3_7Days`
- Why: Risk detected: performance: FILTER over ALL
- Action: Benchmark a narrower filter expression. Prefer REMOVEFILTERS on required columns or KEEPFILTERS when semantics allow.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [P1] Refactor `_Tickets_3_7Days`: performance: ALL over fact table
- Theme: DAX Refactoring
- Source: `_Tickets_3_7Days`
- Why: Risk detected: performance: ALL over fact table
- Action: Avoid clearing filters on the full fact table. Clear only the required dimension or column filters.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [P1] Refactor `_Tickets_1_3Days`: performance: FILTER over ALL
- Theme: DAX Refactoring
- Source: `_Tickets_1_3Days`
- Why: Risk detected: performance: FILTER over ALL
- Action: Benchmark a narrower filter expression. Prefer REMOVEFILTERS on required columns or KEEPFILTERS when semantics allow.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [P1] Refactor `_Tickets_1_3Days`: performance: ALL over fact table
- Theme: DAX Refactoring
- Source: `_Tickets_1_3Days`
- Why: Risk detected: performance: ALL over fact table
- Action: Avoid clearing filters on the full fact table. Clear only the required dimension or column filters.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [P1] Refactor `_Tickets_0_1Day`: performance: FILTER over ALL
- Theme: DAX Refactoring
- Source: `_Tickets_0_1Day`
- Why: Risk detected: performance: FILTER over ALL
- Action: Benchmark a narrower filter expression. Prefer REMOVEFILTERS on required columns or KEEPFILTERS when semantics allow.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [P1] Refactor `_Tickets_0_1Day`: performance: ALL over fact table
- Theme: DAX Refactoring
- Source: `_Tickets_0_1Day`
- Why: Risk detected: performance: ALL over fact table
- Action: Avoid clearing filters on the full fact table. Clear only the required dimension or column filters.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [P1] Refactor `_Ticket_Type_TTR_Prediction`: correctness: Excel-style COUNTIF in DAX
- Theme: DAX Refactoring
- Source: `_Ticket_Type_TTR_Prediction`
- Why: Risk detected: correctness: Excel-style COUNTIF in DAX
- Action: Rewrite using CALCULATE with COUNTROWS/FILTER or a native DAX aggregation. COUNTIF is not a standard DAX function.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [P1] Refactor `_Ticket_Rework_Rate`: correctness: Excel-style COUNTIF in DAX
- Theme: DAX Refactoring
- Source: `_Ticket_Rework_Rate`
- Why: Risk detected: correctness: Excel-style COUNTIF in DAX
- Action: Rewrite using CALCULATE with COUNTROWS/FILTER or a native DAX aggregation. COUNTIF is not a standard DAX function.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [P1] Refactor `_Root_Cause_Identification_Rate`: correctness: Excel-style COUNTIF in DAX
- Theme: DAX Refactoring
- Source: `_Root_Cause_Identification_Rate`
- Why: Risk detected: correctness: Excel-style COUNTIF in DAX
- Action: Rewrite using CALCULATE with COUNTROWS/FILTER or a native DAX aggregation. COUNTIF is not a standard DAX function.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [P1] Refactor `_Root_Cause_Correlation_Score`: correctness: Excel-style COUNTIF in DAX
- Theme: DAX Refactoring
- Source: `_Root_Cause_Correlation_Score`
- Why: Risk detected: correctness: Excel-style COUNTIF in DAX
- Action: Rewrite using CALCULATE with COUNTROWS/FILTER or a native DAX aggregation. COUNTIF is not a standard DAX function.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [P1] Refactor `_Resolution_Time_StdDev`: performance: ALL over fact table
- Theme: DAX Refactoring
- Source: `_Resolution_Time_StdDev`
- Why: Risk detected: performance: ALL over fact table
- Action: Avoid clearing filters on the full fact table. Clear only the required dimension or column filters.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [P1] Refactor `_Repeat_Customer_Rate`: performance: FILTER over ALL
- Theme: DAX Refactoring
- Source: `_Repeat_Customer_Rate`
- Why: Risk detected: performance: FILTER over ALL
- Action: Benchmark a narrower filter expression. Prefer REMOVEFILTERS on required columns or KEEPFILTERS when semantics allow.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [P1] Refactor `_Repeat_Customer_Rate`: performance: ALL over fact table
- Theme: DAX Refactoring
- Source: `_Repeat_Customer_Rate`
- Why: Risk detected: performance: ALL over fact table
- Action: Avoid clearing filters on the full fact table. Clear only the required dimension or column filters.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [P1] Refactor `_Recurring_Issue_Ratio`: correctness: Excel-style COUNTIF in DAX
- Theme: DAX Refactoring
- Source: `_Recurring_Issue_Ratio`
- Why: Risk detected: correctness: Excel-style COUNTIF in DAX
- Action: Rewrite using CALCULATE with COUNTROWS/FILTER or a native DAX aggregation. COUNTIF is not a standard DAX function.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [P1] Refactor `_Preferred_Channel_Detection`: correctness: Excel-style COUNTIF in DAX
- Theme: DAX Refactoring
- Source: `_Preferred_Channel_Detection`
- Why: Risk detected: correctness: Excel-style COUNTIF in DAX
- Action: Rewrite using CALCULATE with COUNTROWS/FILTER or a native DAX aggregation. COUNTIF is not a standard DAX function.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [P1] Refactor `_Peak_Business_Hours_Concentration`: correctness: Excel-style COUNTIF in DAX
- Theme: DAX Refactoring
- Source: `_Peak_Business_Hours_Concentration`
- Why: Risk detected: correctness: Excel-style COUNTIF in DAX
- Action: Rewrite using CALCULATE with COUNTROWS/FILTER or a native DAX aggregation. COUNTIF is not a standard DAX function.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [P1] Refactor `_KB_Self_Service_Rate`: correctness: Excel-style COUNTIF in DAX
- Theme: DAX Refactoring
- Source: `_KB_Self_Service_Rate`
- Why: Risk detected: correctness: Excel-style COUNTIF in DAX
- Action: Rewrite using CALCULATE with COUNTROWS/FILTER or a native DAX aggregation. COUNTIF is not a standard DAX function.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [P1] Refactor `_Handoff_Success_Rate`: correctness: Excel-style COUNTIF in DAX
- Theme: DAX Refactoring
- Source: `_Handoff_Success_Rate`
- Why: Risk detected: correctness: Excel-style COUNTIF in DAX
- Action: Rewrite using CALCULATE with COUNTROWS/FILTER or a native DAX aggregation. COUNTIF is not a standard DAX function.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [P1] Refactor `_Escalation_Authority_Compliance`: correctness: Excel-style COUNTIF in DAX
- Theme: DAX Refactoring
- Source: `_Escalation_Authority_Compliance`
- Why: Risk detected: correctness: Excel-style COUNTIF in DAX
- Action: Rewrite using CALCULATE with COUNTROWS/FILTER or a native DAX aggregation. COUNTIF is not a standard DAX function.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [P1] Refactor `_Data_Privacy_Compliance`: correctness: Excel-style COUNTIF in DAX
- Theme: DAX Refactoring
- Source: `_Data_Privacy_Compliance`
- Why: Risk detected: correctness: Excel-style COUNTIF in DAX
- Action: Rewrite using CALCULATE with COUNTROWS/FILTER or a native DAX aggregation. COUNTIF is not a standard DAX function.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [P1] Refactor `_CSAT_Score`: correctness: Excel-style COUNTIF in DAX
- Theme: DAX Refactoring
- Source: `_CSAT_Score`
- Why: Risk detected: correctness: Excel-style COUNTIF in DAX
- Action: Rewrite using CALCULATE with COUNTROWS/FILTER or a native DAX aggregation. COUNTIF is not a standard DAX function.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [P1] Refactor `_Context_Switching_Cost`: correctness: Excel-style COUNTIF in DAX
- Theme: DAX Refactoring
- Source: `_Context_Switching_Cost`
- Why: Risk detected: correctness: Excel-style COUNTIF in DAX
- Action: Rewrite using CALCULATE with COUNTROWS/FILTER or a native DAX aggregation. COUNTIF is not a standard DAX function.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [P1] Refactor `_Channel_Performance_Email`: correctness: Excel-style COUNTIF in DAX
- Theme: DAX Refactoring
- Source: `_Channel_Performance_Email`
- Why: Risk detected: correctness: Excel-style COUNTIF in DAX
- Action: Rewrite using CALCULATE with COUNTROWS/FILTER or a native DAX aggregation. COUNTIF is not a standard DAX function.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [P1] Refactor `_Channel_CSAT_Differential`: correctness: Excel-style COUNTIF in DAX
- Theme: DAX Refactoring
- Source: `_Channel_CSAT_Differential`
- Why: Risk detected: correctness: Excel-style COUNTIF in DAX
- Action: Rewrite using CALCULATE with COUNTROWS/FILTER or a native DAX aggregation. COUNTIF is not a standard DAX function.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [P1] Refactor `_Anomaly_High_Resolution_Time`: performance: ALL over fact table
- Theme: DAX Refactoring
- Source: `_Anomaly_High_Resolution_Time`
- Why: Risk detected: performance: ALL over fact table
- Action: Avoid clearing filters on the full fact table. Clear only the required dimension or column filters.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [P1] Refactor `_Anomaly_High_Resolution_Time`: performance: FILTER over ALL
- Theme: DAX Refactoring
- Source: `_Anomaly_High_Resolution_Time`
- Why: Risk detected: performance: FILTER over ALL
- Action: Benchmark a narrower filter expression. Prefer REMOVEFILTERS on required columns or KEEPFILTERS when semantics allow.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [P1] Refactor `_Agents_Needing_Training`: correctness: Excel-style COUNTIF in DAX
- Theme: DAX Refactoring
- Source: `_Agents_Needing_Training`
- Why: Risk detected: correctness: Excel-style COUNTIF in DAX
- Action: Rewrite using CALCULATE with COUNTROWS/FILTER or a native DAX aggregation. COUNTIF is not a standard DAX function.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [P2] Reduce metadata finding group: Missing measure description
- Theme: Metric Governance
- Source: `model`
- Why: Detected 3 occurrences.
- Action: Batch-update measure names, descriptions, visibility, or format strings according to the finding group.
- Validation: Rerun Test-PowerBILiveMetadataGovernance.ps1 and compare finding counts.

## [P2] Reduce metadata finding group: Missing format string
- Theme: Metric Governance
- Source: `model`
- Why: Detected 37 occurrences.
- Action: Batch-update measure names, descriptions, visibility, or format strings according to the finding group.
- Validation: Rerun Test-PowerBILiveMetadataGovernance.ps1 and compare finding counts.

## [P2] Reduce metadata finding group: Technical-looking visible measure
- Theme: Metric Governance
- Source: `model`
- Why: Detected 137 occurrences.
- Action: Batch-update measure names, descriptions, visibility, or format strings according to the finding group.
- Validation: Rerun Test-PowerBILiveMetadataGovernance.ps1 and compare finding counts.



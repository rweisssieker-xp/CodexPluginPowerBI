# Power BI Live Measure Validation

Tested: 25
Passed: 15
Failed: 10

## [Passed] _CountIncidents
- Table: IncidentsAllFields
- Elapsed ms: 910
- Value: ``

## [Failed] _SLA_Compliance
- Table: IncidentsAllFields
- Elapsed ms: 949
- Error: Ausnahme beim Aufrufen von "Read" mit 0 Argument(en):  "MdxScript(Model) (123, 102) Berechnungsfehler in dem Measure "IncidentsAllFields"[_SLA_Compliance]: Eine Funktion vom Typ 'PLACEHOLDER' wurde in einem True/False-Ausdruck verwendet, der als Tabellenfilterausdruck dient. Dies ist nicht zulässig."

## [Passed] _FirstContactResolutionRate_FCR
- Table: IncidentsAllFields
- Elapsed ms: 897
- Value: ``

## [Passed] _AVG TTS
- Table: IncidentsAllFields
- Elapsed ms: 921
- Value: ``

## [Passed] _Cost_Per_Resolution
- Table: IncidentsAllFields
- Elapsed ms: 902
- Value: ``

## [Passed] _Churn_Risk_Indicator
- Table: IncidentsAllFields
- Elapsed ms: 898
- Value: ``

## [Failed] _Team_Stress_Index
- Table: IncidentsAllFields
- Elapsed ms: 924
- Error: Ausnahme beim Aufrufen von "Read" mit 0 Argument(en):  "MdxScript(Model) (126, 103) Berechnungsfehler in dem Measure "IncidentsAllFields"[_Escalation_Rate]: Die Spalte "escalationtime" in der Tabelle "IncidentsAllFields" wurde nicht gefunden oder darf in diesem Ausdruck nicht verwendet werden."

## [Passed] _Open_Incidents
- Table: IncidentsAllFields
- Elapsed ms: 902
- Value: ``

## [Failed] _Agent_Burnout_Risk
- Table: IncidentsAllFields
- Elapsed ms: 904
- Error: Ausnahme beim Aufrufen von "ExecuteReader" mit 0 Argument(en):  "MdxScript(Model) (126, 103) Berechnungsfehler in dem Measure "IncidentsAllFields"[_Escalation_Rate]: Die Spalte "escalationtime" in der Tabelle "IncidentsAllFields" wurde nicht gefunden oder darf in diesem Ausdruck nicht verwendet werden."

## [Passed] _Avg_Cases_Per_Agent
- Table: IncidentsAllFields
- Elapsed ms: 864
- Value: ``

## [Failed] _Cost_Savings_Potential
- Table: IncidentsAllFields
- Elapsed ms: 897
- Error: Ausnahme beim Aufrufen von "Read" mit 0 Argument(en):  "MdxScript(Model) (123, 102) Berechnungsfehler in dem Measure "IncidentsAllFields"[_SLA_Compliance]: Eine Funktion vom Typ 'PLACEHOLDER' wurde in einem True/False-Ausdruck verwendet, der als Tabellenfilterausdruck dient. Dies ist nicht zulässig."

## [Failed] _Ticket_Velocity
- Table: IncidentsAllFields
- Elapsed ms: 924
- Error: Ausnahme beim Aufrufen von "Read" mit 0 Argument(en):  "MdxScript(Model) (129, 96) Von der Funktion 'DISTINCTCOUNT' wird nur ein Spaltenverweis als Argument akzeptiert."

## [Passed] _Potential_SLA_Breach_24h
- Table: IncidentsAllFields
- Elapsed ms: 881
- Value: ``

## [Failed] _Escalation_Rate
- Table: IncidentsAllFields
- Elapsed ms: 914
- Error: Ausnahme beim Aufrufen von "Read" mit 0 Argument(en):  "MdxScript(Model) (126, 103) Berechnungsfehler in dem Measure "IncidentsAllFields"[_Escalation_Rate]: Die Spalte "escalationtime" in der Tabelle "IncidentsAllFields" wurde nicht gefunden oder darf in diesem Ausdruck nicht verwendet werden."

## [Failed] _Effort_Reduction_Opportunity
- Table: IncidentsAllFields
- Elapsed ms: 899
- Error: Ausnahme beim Aufrufen von "Read" mit 0 Argument(en):  "MdxScript(Model) (182, 57) Fehler beim Auflösen des Namens "COUNTIF". Dies ist kein gültiger Tabellen-, Variablen- oder Funktionsname."

## [Failed] _Compliance_Audit_Ready_Index
- Table: IncidentsAllFields
- Elapsed ms: 901
- Error: Ausnahme beim Aufrufen von "Read" mit 0 Argument(en):  "MdxScript(Model) (123, 102) Berechnungsfehler in dem Measure "IncidentsAllFields"[_SLA_Compliance]: Eine Funktion vom Typ 'PLACEHOLDER' wurde in einem True/False-Ausdruck verwendet, der als Tabellenfilterausdruck dient. Dies ist nicht zulässig."

## [Failed] _Executive_Health_Score
- Table: IncidentsAllFields
- Elapsed ms: 910
- Error: Ausnahme beim Aufrufen von "Read" mit 0 Argument(en):  "MdxScript(Model) (123, 102) Berechnungsfehler in dem Measure "IncidentsAllFields"[_SLA_Compliance]: Eine Funktion vom Typ 'PLACEHOLDER' wurde in einem True/False-Ausdruck verwendet, der als Tabellenfilterausdruck dient. Dies ist nicht zulässig."

## [Passed] _Data_Quality_Score
- Table: IncidentsAllFields
- Elapsed ms: 883
- Value: ``

## [Failed] _Critical_Alerts_Count
- Table: IncidentsAllFields
- Elapsed ms: 901
- Error: Ausnahme beim Aufrufen von "Read" mit 0 Argument(en):  "MdxScript(Model) (123, 102) Berechnungsfehler in dem Measure "IncidentsAllFields"[_SLA_Compliance]: Eine Funktion vom Typ 'PLACEHOLDER' wurde in einem True/False-Ausdruck verwendet, der als Tabellenfilterausdruck dient. Dies ist nicht zulässig."

## [Passed] _Customer_Lifetime_Value
- Table: IncidentsAllFields
- Elapsed ms: 893
- Value: ``

## [Passed] Gleitender Durchschnitt für "_CountIncidents"
- Table: IncidentsAllFields
- Elapsed ms: 902
- Value: ``

## [Passed] _Repeat_Customer_Rate
- Table: IncidentsAllFields
- Elapsed ms: 895
- Value: ``

## [Passed] _Tickets_0_1Day
- Table: IncidentsAllFields
- Elapsed ms: 862
- Value: ``

## [Passed] _Tickets_1_3Days
- Table: IncidentsAllFields
- Elapsed ms: 904
- Value: ``

## [Passed] _Tickets_3_7Days
- Table: IncidentsAllFields
- Elapsed ms: 889
- Value: ``



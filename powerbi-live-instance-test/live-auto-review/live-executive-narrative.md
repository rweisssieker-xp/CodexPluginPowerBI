# Power BI Live Executive Narrative

The open Power BI Desktop model is rated **High** risk with score **44**.
The live model contains **80** tables, **170** measures, **76** relationships, and **214** measure dependencies.

## Most Important Signals

- **Many auto date tables** on `model`: Detected 72 hidden LocalDateTable objects. Consider a governed date table and disabling auto date/time.
- **maintainability: long expression** on `Gleitender Durchschnitt für "_CountIncidents"`: Review measure `Gleitender Durchschnitt für "_CountIncidents"` in table `IncidentsAllFields`.
- **maintainability: long expression** on `_SRA_Top Driver Theme`: Review measure `_SRA_Top Driver Theme` in table `IncidentsAllFields`.
- **maintainability: long expression** on `_SRA_Ticket Recommended Action`: Review measure `_SRA_Ticket Recommended Action` in table `IncidentsAllFields`.
- **maintainability: long expression** on `_SRA_Ticket Risk Score`: Review measure `_SRA_Ticket Risk Score` in table `IncidentsAllFields`.
- **determinism: volatile date/time** on `_SRA_Ticket Recommended Action`: Review measure `_SRA_Ticket Recommended Action` in table `IncidentsAllFields`.
- **determinism: volatile date/time** on `_SRA_Overdue Open Tickets`: Review measure `_SRA_Overdue Open Tickets` in table `IncidentsAllFields`.
- **determinism: volatile date/time** on `_SRA_SLA Due Next 24h`: Review measure `_SRA_SLA Due Next 24h` in table `IncidentsAllFields`.

## Highest-Impact Measures

- `_CountIncidents`: hub score 46, incoming 46, outgoing 0
- `_SLA_Compliance`: hub score 18, incoming 16, outgoing 2
- `_FirstContactResolutionRate_FCR`: hub score 14, incoming 14, outgoing 0
- `_AVG TTS`: hub score 11, incoming 11, outgoing 0
- `_Open_Incidents`: hub score 10, incoming 10, outgoing 0
- `_Cost_Per_Resolution`: hub score 9, incoming 8, outgoing 1
- `_SRA_Ticket Risk Band`: hub score 7, incoming 6, outgoing 1
- `_Team_Stress_Index`: hub score 7, incoming 4, outgoing 3

## First Actions

- Add descriptions and owners to business-critical measures.
- Review high-risk DAX patterns before changing visuals.
- Validate hub measures before publishing because downstream metrics may change.


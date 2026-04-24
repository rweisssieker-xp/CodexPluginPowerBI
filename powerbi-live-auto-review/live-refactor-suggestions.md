# Power BI Live Refactor Suggestions

Suggestions: 39

## [Low] Gleitender Durchschnitt für "_CountIncidents"
- Table: IncidentsAllFields
- Risk: usability: measure can intentionally raise ERROR
- Suggested action: Review and refactor with business-owner validation.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

```DAX

IF(
	ISFILTERED('IncidentsAllFields'[createdon - DateTime]),
	ERROR("Quickmeasures mit Zeitintelligenz können nur über die von Power BI bereitgestellte Datumshierarchie oder die primäre Datumsspalte gruppiert oder gefiltert werden."),
	VAR __LAST_DATE = ENDOFMONTH('IncidentsAllFields'[createdon - DateTime].[Date])
	VAR __DATE_PERIOD =
		DATESBETWEEN(
			'IncidentsAllFields'[createdon - DateTime].[Date],
			STARTOFMONTH(DATEADD(__LAST_DATE, -1, MONTH)),
			ENDOFMONTH(DATEADD(__LAST_DATE, 1, MONTH))
		)
	RETURN
		AVERAGEX(
			CALCULATETABLE(
				SUMMARIZE(
					VALUES('IncidentsAllFields'),
					'IncidentsAllFields'[createdon - DateTime].[Jahr],
					'IncidentsAllFields'[createdon - DateTime].[QuarterNo],
					'IncidentsAllFields'[createdon - DateTime].[Quartal],
					'IncidentsAllFields'[createdon - DateTime].[MonthNo],
					'IncidentsAllFields'[createdon - DateTime].[Monat]
				),
				__DATE_PERIOD
			),
			CALCULATE(
				[_CountIncidents],
				ALL('IncidentsAllFields'[createdon - DateTime].[Tag])
			)
		)
)
```

## [Medium] Gleitender Durchschnitt für "_CountIncidents"
- Table: IncidentsAllFields
- Risk: maintainability: long expression
- Suggested action: Extract reusable business logic into helper measures and add comments/description.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

```DAX

IF(
	ISFILTERED('IncidentsAllFields'[createdon - DateTime]),
	ERROR("Quickmeasures mit Zeitintelligenz können nur über die von Power BI bereitgestellte Datumshierarchie oder die primäre Datumsspalte gruppiert oder gefiltert werden."),
	VAR __LAST_DATE = ENDOFMONTH('IncidentsAllFields'[createdon - DateTime].[Date])
	VAR __DATE_PERIOD =
		DATESBETWEEN(
			'IncidentsAllFields'[createdon - DateTime].[Date],
			STARTOFMONTH(DATEADD(__LAST_DATE, -1, MONTH)),
			ENDOFMONTH(DATEADD(__LAST_DATE, 1, MONTH))
		)
	RETURN
		AVERAGEX(
			CALCULATETABLE(
				SUMMARIZE(
					VALUES('IncidentsAllFields'),
					'IncidentsAllFields'[createdon - DateTime].[Jahr],
					'IncidentsAllFields'[createdon - DateTime].[QuarterNo],
					'IncidentsAllFields'[createdon - DateTime].[Quartal],
					'IncidentsAllFields'[createdon - DateTime].[MonthNo],
					'IncidentsAllFields'[createdon - DateTime].[Monat]
				),
				__DATE_PERIOD
			),
			CALCULATE(
				[_CountIncidents],
				ALL('IncidentsAllFields'[createdon - DateTime].[Tag])
			)
		)
)
```

## [High] _Repeat_Customer_Rate
- Table: IncidentsAllFields
- Risk: performance: FILTER over ALL
- Suggested action: Benchmark a narrower filter expression. Prefer REMOVEFILTERS on required columns or KEEPFILTERS when semantics allow.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

```DAX
DIVIDE(CALCULATE(COUNTA(IncidentsAllFields[incidentid]),FILTER(ALL(IncidentsAllFields),CALCULATE(COUNTA(IncidentsAllFields[incidentid]))>1)),COUNTA(IncidentsAllFields[incidentid]),0)
```

## [High] _Repeat_Customer_Rate
- Table: IncidentsAllFields
- Risk: performance: ALL over fact table
- Suggested action: Avoid clearing filters on the full fact table. Clear only the required dimension or column filters.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

```DAX
DIVIDE(CALCULATE(COUNTA(IncidentsAllFields[incidentid]),FILTER(ALL(IncidentsAllFields),CALCULATE(COUNTA(IncidentsAllFields[incidentid]))>1)),COUNTA(IncidentsAllFields[incidentid]),0)
```

## [High] _Tickets_0_1Day
- Table: IncidentsAllFields
- Risk: performance: FILTER over ALL
- Suggested action: Benchmark a narrower filter expression. Prefer REMOVEFILTERS on required columns or KEEPFILTERS when semantics allow.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

```DAX
CALCULATE(COUNTA(IncidentsAllFields[incidentid]),FILTER(ALL(IncidentsAllFields),IncidentsAllFields[caseage]<1440))
```

## [High] _Tickets_0_1Day
- Table: IncidentsAllFields
- Risk: performance: ALL over fact table
- Suggested action: Avoid clearing filters on the full fact table. Clear only the required dimension or column filters.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

```DAX
CALCULATE(COUNTA(IncidentsAllFields[incidentid]),FILTER(ALL(IncidentsAllFields),IncidentsAllFields[caseage]<1440))
```

## [High] _Tickets_1_3Days
- Table: IncidentsAllFields
- Risk: performance: FILTER over ALL
- Suggested action: Benchmark a narrower filter expression. Prefer REMOVEFILTERS on required columns or KEEPFILTERS when semantics allow.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

```DAX
CALCULATE(COUNTA(IncidentsAllFields[incidentid]),FILTER(ALL(IncidentsAllFields),AND(IncidentsAllFields[caseage]>=1440,IncidentsAllFields[caseage]<4320)))
```

## [High] _Tickets_1_3Days
- Table: IncidentsAllFields
- Risk: performance: ALL over fact table
- Suggested action: Avoid clearing filters on the full fact table. Clear only the required dimension or column filters.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

```DAX
CALCULATE(COUNTA(IncidentsAllFields[incidentid]),FILTER(ALL(IncidentsAllFields),AND(IncidentsAllFields[caseage]>=1440,IncidentsAllFields[caseage]<4320)))
```

## [High] _Tickets_3_7Days
- Table: IncidentsAllFields
- Risk: performance: FILTER over ALL
- Suggested action: Benchmark a narrower filter expression. Prefer REMOVEFILTERS on required columns or KEEPFILTERS when semantics allow.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

```DAX
CALCULATE(COUNTA(IncidentsAllFields[incidentid]),FILTER(ALL(IncidentsAllFields),AND(IncidentsAllFields[caseage]>=4320,IncidentsAllFields[caseage]<10080)))
```

## [High] _Tickets_3_7Days
- Table: IncidentsAllFields
- Risk: performance: ALL over fact table
- Suggested action: Avoid clearing filters on the full fact table. Clear only the required dimension or column filters.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

```DAX
CALCULATE(COUNTA(IncidentsAllFields[incidentid]),FILTER(ALL(IncidentsAllFields),AND(IncidentsAllFields[caseage]>=4320,IncidentsAllFields[caseage]<10080)))
```

## [High] _Tickets_Over_7Days
- Table: IncidentsAllFields
- Risk: performance: FILTER over ALL
- Suggested action: Benchmark a narrower filter expression. Prefer REMOVEFILTERS on required columns or KEEPFILTERS when semantics allow.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

```DAX
CALCULATE(COUNTA(IncidentsAllFields[incidentid]),FILTER(ALL(IncidentsAllFields),IncidentsAllFields[caseage]>=10080))
```

## [High] _Tickets_Over_7Days
- Table: IncidentsAllFields
- Risk: performance: ALL over fact table
- Suggested action: Avoid clearing filters on the full fact table. Clear only the required dimension or column filters.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

```DAX
CALCULATE(COUNTA(IncidentsAllFields[incidentid]),FILTER(ALL(IncidentsAllFields),IncidentsAllFields[caseage]>=10080))
```

## [Medium] _Potential_SLA_Breach_24h
- Table: IncidentsAllFields
- Risk: determinism: volatile date/time
- Suggested action: Replace volatile TODAY/NOW logic with a governed refresh-date measure, model parameter, or date table filter.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

```DAX
DIVIDE(CALCULATE(COUNTA(IncidentsAllFields[incidentid]),IncidentsAllFields[resolveby]<=TODAY()+1,IncidentsAllFields[statuscodename]<>"Closed"),COUNTA(IncidentsAllFields[incidentid]),0)
```

## [Medium] _Status_Date_Mismatch_Count
- Table: IncidentsAllFields
- Risk: determinism: volatile date/time
- Suggested action: Replace volatile TODAY/NOW logic with a governed refresh-date measure, model parameter, or date table filter.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

```DAX
CALCULATE(COUNTA(IncidentsAllFields[incidentid]),IncidentsAllFields[pdw_resolutiondate]<TODAY(),IncidentsAllFields[statuscodename]<>"Closed")
```

## [Medium] _Overdue_Tickets_Count
- Table: IncidentsAllFields
- Risk: determinism: volatile date/time
- Suggested action: Replace volatile TODAY/NOW logic with a governed refresh-date measure, model parameter, or date table filter.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

```DAX
CALCULATE(COUNTA(IncidentsAllFields[incidentid]),IncidentsAllFields[resolveby]<TODAY(),IncidentsAllFields[statuscodename]<>"Closed")
```

## [High] _Resolution_Time_StdDev
- Table: IncidentsAllFields
- Risk: performance: ALL over fact table
- Suggested action: Avoid clearing filters on the full fact table. Clear only the required dimension or column filters.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

```DAX
STDEV.P(CALCULATE(IncidentsAllFields[pdw_totalresolutiontime_duration],ALL(IncidentsAllFields)))
```

## [High] _Anomaly_High_Resolution_Time
- Table: IncidentsAllFields
- Risk: performance: FILTER over ALL
- Suggested action: Benchmark a narrower filter expression. Prefer REMOVEFILTERS on required columns or KEEPFILTERS when semantics allow.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

```DAX
CALCULATE(COUNTA(IncidentsAllFields[incidentid]),FILTER(ALL(IncidentsAllFields),IncidentsAllFields[pdw_totalresolutiontime_duration]>([_AVG TTS]*2*60)))
```

## [High] _Anomaly_High_Resolution_Time
- Table: IncidentsAllFields
- Risk: performance: ALL over fact table
- Suggested action: Avoid clearing filters on the full fact table. Clear only the required dimension or column filters.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

```DAX
CALCULATE(COUNTA(IncidentsAllFields[incidentid]),FILTER(ALL(IncidentsAllFields),IncidentsAllFields[pdw_totalresolutiontime_duration]>([_AVG TTS]*2*60)))
```

## [High] _Volume_vs_Baseline_Index
- Table: IncidentsAllFields
- Risk: performance: ALL over fact table
- Suggested action: Avoid clearing filters on the full fact table. Clear only the required dimension or column filters.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

```DAX
DIVIDE([_CountIncidents],CALCULATE(AVERAGE(COUNTA(IncidentsAllFields[incidentid])),ALL(IncidentsAllFields)),0)
```

## [High] _CSAT_Score
- Table: IncidentsAllFields
- Risk: correctness: Excel-style COUNTIF in DAX
- Suggested action: Rewrite using CALCULATE with COUNTROWS/FILTER or a native DAX aggregation. COUNTIF is not a standard DAX function.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

```DAX
DIVIDE(COUNTIF(IncidentsAllFields[satisfactionindex], ">= 4"), COUNTIF(IncidentsAllFields[satisfactionindex], "<> -999"), 0) * 100
```

## [High] _Top_Problem_Categories_Pareto
- Table: IncidentsAllFields
- Risk: correctness: Excel-style COUNTIF in DAX
- Suggested action: Rewrite using CALCULATE with COUNTROWS/FILTER or a native DAX aggregation. COUNTIF is not a standard DAX function.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

```DAX
COUNTIF(IncidentsAllFields[type], "Problem") * 0.2
```

## [High] _Root_Cause_Identification_Rate
- Table: IncidentsAllFields
- Risk: correctness: Excel-style COUNTIF in DAX
- Suggested action: Rewrite using CALCULATE with COUNTROWS/FILTER or a native DAX aggregation. COUNTIF is not a standard DAX function.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

```DAX
DIVIDE(COUNTIF(IncidentsAllFields[description], "*Root Cause*"), [_CountIncidents], 0) * 100
```

## [High] _KB_Self_Service_Rate
- Table: IncidentsAllFields
- Risk: correctness: Excel-style COUNTIF in DAX
- Suggested action: Rewrite using CALCULATE with COUNTROWS/FILTER or a native DAX aggregation. COUNTIF is not a standard DAX function.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

```DAX
DIVIDE(COUNTIF(IncidentsAllFields[typename], "Knowledge Base"), [_CountIncidents], 0) * 100
```

## [High] _Recurring_Issue_Ratio
- Table: IncidentsAllFields
- Risk: correctness: Excel-style COUNTIF in DAX
- Suggested action: Rewrite using CALCULATE with COUNTROWS/FILTER or a native DAX aggregation. COUNTIF is not a standard DAX function.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

```DAX
DIVIDE(COUNTIF(IncidentsAllFields[resolvedbykbkbase], TRUE), [_CountIncidents], 0) * 100
```

## [High] _Agents_Needing_Training
- Table: IncidentsAllFields
- Risk: correctness: Excel-style COUNTIF in DAX
- Suggested action: Rewrite using CALCULATE with COUNTROWS/FILTER or a native DAX aggregation. COUNTIF is not a standard DAX function.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

```DAX
COUNTIF(IncidentsAllFields[ownerid], "<> BLANK") - COUNTX(FILTER(SUMMARIZE(IncidentsAllFields, IncidentsAllFields[ownerid]), [_Agent_Skill_Gap] < 1.2 && [_Agent_Burnout_Risk] < 60), 1)
```

## [High] _Handoff_Success_Rate
- Table: IncidentsAllFields
- Risk: correctness: Excel-style COUNTIF in DAX
- Suggested action: Rewrite using CALCULATE with COUNTROWS/FILTER or a native DAX aggregation. COUNTIF is not a standard DAX function.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

```DAX
DIVIDE(COUNTIF(IncidentsAllFields[isescalated], FALSE), [_CountIncidents], 0) * 100
```

## [High] _Ticket_Rework_Rate
- Table: IncidentsAllFields
- Risk: correctness: Excel-style COUNTIF in DAX
- Suggested action: Rewrite using CALCULATE with COUNTROWS/FILTER or a native DAX aggregation. COUNTIF is not a standard DAX function.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

```DAX
DIVIDE(COUNTIF(IncidentsAllFields[iserrorticket], TRUE), [_CountIncidents], 0) * 100
```

## [Medium] _Holiday_Impact_Index
- Table: IncidentsAllFields
- Risk: determinism: volatile date/time
- Suggested action: Replace volatile TODAY/NOW logic with a governed refresh-date measure, model parameter, or date table filter.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

```DAX
IF(MONTH(TODAY()) = 12 OR MONTH(TODAY()) = 1 OR MONTH(TODAY()) = 8, DIVIDE([_CountIncidents], AVERAGEX(VALUES(Calendar[Monat]), [_CountIncidents]), 1), 1)
```

## [High] _Peak_Business_Hours_Concentration
- Table: IncidentsAllFields
- Risk: correctness: Excel-style COUNTIF in DAX
- Suggested action: Rewrite using CALCULATE with COUNTROWS/FILTER or a native DAX aggregation. COUNTIF is not a standard DAX function.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

```DAX
DIVIDE(COUNTIF(IncidentsAllFields[createdon], ">= 8:00" & IncidentsAllFields[createdon], "<= 18:00"), [_CountIncidents], 0) * 100
```

## [Medium] _Cyclical_Pattern_Detected
- Table: IncidentsAllFields
- Risk: determinism: volatile date/time
- Suggested action: Replace volatile TODAY/NOW logic with a governed refresh-date measure, model parameter, or date table filter.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

```DAX
IF(MOD(DAY(TODAY()), 7) = 1, "Weekly-Pattern", IF(MOD(DAY(TODAY()), 14) = 1, "BiWeekly-Pattern", "No-Pattern"))
```

## [High] _Ticket_Type_TTR_Prediction
- Table: IncidentsAllFields
- Risk: correctness: Excel-style COUNTIF in DAX
- Suggested action: Rewrite using CALCULATE with COUNTROWS/FILTER or a native DAX aggregation. COUNTIF is not a standard DAX function.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

```DAX
AVERAGE(IncidentsAllFields[_AVG TTS]) * (1 + (COUNTIF(IncidentsAllFields[type], "Problem") / [_CountIncidents]))
```

## [High] _Root_Cause_Correlation_Score
- Table: IncidentsAllFields
- Risk: correctness: Excel-style COUNTIF in DAX
- Suggested action: Rewrite using CALCULATE with COUNTROWS/FILTER or a native DAX aggregation. COUNTIF is not a standard DAX function.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

```DAX
INT((COUNTIF(IncidentsAllFields[prioritycode], ">2") / [_CountIncidents] * 40 + COUNTIF(IncidentsAllFields[typename], "*Problem*") / [_CountIncidents] * 35 + [_Escalation_Rate] * 25))
```

## [High] _Channel_Performance_Email
- Table: IncidentsAllFields
- Risk: correctness: Excel-style COUNTIF in DAX
- Suggested action: Rewrite using CALCULATE with COUNTROWS/FILTER or a native DAX aggregation. COUNTIF is not a standard DAX function.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

```DAX
COUNTIF(IncidentsAllFields[caseorigincodename], "*Email*") / COUNTIF(IncidentsAllFields[caseorigincodename], "<>") * 100
```

## [High] _Preferred_Channel_Detection
- Table: IncidentsAllFields
- Risk: correctness: Excel-style COUNTIF in DAX
- Suggested action: Rewrite using CALCULATE with COUNTROWS/FILTER or a native DAX aggregation. COUNTIF is not a standard DAX function.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

```DAX
IF(COUNTIF(IncidentsAllFields[caseorigincodename], "*Phone*") > COUNTIF(IncidentsAllFields[caseorigincodename], "*Email*"), "Phone", "Email")
```

## [High] _Channel_CSAT_Differential
- Table: IncidentsAllFields
- Risk: correctness: Excel-style COUNTIF in DAX
- Suggested action: Rewrite using CALCULATE with COUNTROWS/FILTER or a native DAX aggregation. COUNTIF is not a standard DAX function.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

```DAX
[_CSAT_Score] * DIVIDE(COUNTIF(IncidentsAllFields[customersatisfactioncodename], "*Satisfied*"), [_CountIncidents], 0)
```

## [High] _Context_Switching_Cost
- Table: IncidentsAllFields
- Risk: correctness: Excel-style COUNTIF in DAX
- Suggested action: Rewrite using CALCULATE with COUNTROWS/FILTER or a native DAX aggregation. COUNTIF is not a standard DAX function.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

```DAX
DIVIDE(COUNTIF(IncidentsAllFields[casetypecodename], "<>"), [_Avg_Cases_Per_Agent], 0) * 5
```

## [High] _Data_Privacy_Compliance
- Table: IncidentsAllFields
- Risk: correctness: Excel-style COUNTIF in DAX
- Suggested action: Rewrite using CALCULATE with COUNTROWS/FILTER or a native DAX aggregation. COUNTIF is not a standard DAX function.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

```DAX
MIN((1 - [_Missing_Description_Rate] / 100 - DIVIDE(COUNTIF(IncidentsAllFields[contactidname], "BLANK"), [_CountIncidents], 0) * 50) * 100, 100)
```

## [High] _Escalation_Authority_Compliance
- Table: IncidentsAllFields
- Risk: correctness: Excel-style COUNTIF in DAX
- Suggested action: Rewrite using CALCULATE with COUNTROWS/FILTER or a native DAX aggregation. COUNTIF is not a standard DAX function.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

```DAX
DIVIDE([_Escalated_Tickets_Count], COUNTIF(IncidentsAllFields[isescalated], TRUE), 0) * 100
```

## [Medium] _Quarter_Performance_Trend
- Table: IncidentsAllFields
- Risk: determinism: volatile date/time
- Suggested action: Replace volatile TODAY/NOW logic with a governed refresh-date measure, model parameter, or date table filter.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

```DAX
([_SLA_Compliance] + [_FirstContactResolutionRate_FCR] * 100) / 2 * POWER(1.05, INT(MONTH(TODAY()) / 3))
```



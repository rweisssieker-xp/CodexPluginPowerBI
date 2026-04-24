# Power BI Live DAX Fix Drafts

Drafts: 38

These are implementation drafts, not blind patches. Validate every rewrite against accepted business totals before replacing production measures.

## [Medium] Gleitender Durchschnitt für "_CountIncidents"
- Table: IncidentsAllFields
- Risk: maintainability: long expression
- Note: Split long expressions into helper measures with explicit business names and descriptions.

### Original

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

### Draft

```DAX
/* DRAFT: extract helper measures for reusable business logic before finalizing. */

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

- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [High] _Repeat_Customer_Rate
- Table: IncidentsAllFields
- Risk: performance: FILTER over ALL
- Note: FILTER(ALL(...)) can over-clear context. Replace ALL(table) with REMOVEFILTERS(required columns) or a smaller dimension scope where semantics allow.

### Original

```DAX
DIVIDE(CALCULATE(COUNTA(IncidentsAllFields[incidentid]),FILTER(ALL(IncidentsAllFields),CALCULATE(COUNTA(IncidentsAllFields[incidentid]))>1)),COUNTA(IncidentsAllFields[incidentid]),0)
```

### Draft

```DAX
DIVIDE(CALCULATE(COUNTA(IncidentsAllFields[incidentid]),FILTER(REMOVEFILTERS(IncidentsAllFields),CALCULATE(COUNTA(IncidentsAllFields[incidentid]))>1)),COUNTA(IncidentsAllFields[incidentid]),0)
```

- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [High] _Repeat_Customer_Rate
- Table: IncidentsAllFields
- Risk: performance: ALL over fact table
- Note: ALL over a fact table is usually too broad. Clear only the columns or dimensions required by the calculation.

### Original

```DAX
DIVIDE(CALCULATE(COUNTA(IncidentsAllFields[incidentid]),FILTER(ALL(IncidentsAllFields),CALCULATE(COUNTA(IncidentsAllFields[incidentid]))>1)),COUNTA(IncidentsAllFields[incidentid]),0)
```

### Draft

```DAX
DIVIDE(CALCULATE(COUNTA(IncidentsAllFields[incidentid]),FILTER(REMOVEFILTERS(/* TODO: choose required IncidentsAllFields columns, not full fact table */),CALCULATE(COUNTA(IncidentsAllFields[incidentid]))>1)),COUNTA(IncidentsAllFields[incidentid]),0)
```

- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [High] _Tickets_0_1Day
- Table: IncidentsAllFields
- Risk: performance: FILTER over ALL
- Note: FILTER(ALL(...)) can over-clear context. Replace ALL(table) with REMOVEFILTERS(required columns) or a smaller dimension scope where semantics allow.

### Original

```DAX
CALCULATE(COUNTA(IncidentsAllFields[incidentid]),FILTER(ALL(IncidentsAllFields),IncidentsAllFields[caseage]<1440))
```

### Draft

```DAX
CALCULATE(COUNTA(IncidentsAllFields[incidentid]),FILTER(REMOVEFILTERS(IncidentsAllFields),IncidentsAllFields[caseage]<1440))
```

- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [High] _Tickets_0_1Day
- Table: IncidentsAllFields
- Risk: performance: ALL over fact table
- Note: ALL over a fact table is usually too broad. Clear only the columns or dimensions required by the calculation.

### Original

```DAX
CALCULATE(COUNTA(IncidentsAllFields[incidentid]),FILTER(ALL(IncidentsAllFields),IncidentsAllFields[caseage]<1440))
```

### Draft

```DAX
CALCULATE(COUNTA(IncidentsAllFields[incidentid]),FILTER(REMOVEFILTERS(/* TODO: choose required IncidentsAllFields columns, not full fact table */),IncidentsAllFields[caseage]<1440))
```

- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [High] _Tickets_1_3Days
- Table: IncidentsAllFields
- Risk: performance: FILTER over ALL
- Note: FILTER(ALL(...)) can over-clear context. Replace ALL(table) with REMOVEFILTERS(required columns) or a smaller dimension scope where semantics allow.

### Original

```DAX
CALCULATE(COUNTA(IncidentsAllFields[incidentid]),FILTER(ALL(IncidentsAllFields),AND(IncidentsAllFields[caseage]>=1440,IncidentsAllFields[caseage]<4320)))
```

### Draft

```DAX
CALCULATE(COUNTA(IncidentsAllFields[incidentid]),FILTER(REMOVEFILTERS(IncidentsAllFields),AND(IncidentsAllFields[caseage]>=1440,IncidentsAllFields[caseage]<4320)))
```

- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [High] _Tickets_1_3Days
- Table: IncidentsAllFields
- Risk: performance: ALL over fact table
- Note: ALL over a fact table is usually too broad. Clear only the columns or dimensions required by the calculation.

### Original

```DAX
CALCULATE(COUNTA(IncidentsAllFields[incidentid]),FILTER(ALL(IncidentsAllFields),AND(IncidentsAllFields[caseage]>=1440,IncidentsAllFields[caseage]<4320)))
```

### Draft

```DAX
CALCULATE(COUNTA(IncidentsAllFields[incidentid]),FILTER(REMOVEFILTERS(/* TODO: choose required IncidentsAllFields columns, not full fact table */),AND(IncidentsAllFields[caseage]>=1440,IncidentsAllFields[caseage]<4320)))
```

- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [High] _Tickets_3_7Days
- Table: IncidentsAllFields
- Risk: performance: FILTER over ALL
- Note: FILTER(ALL(...)) can over-clear context. Replace ALL(table) with REMOVEFILTERS(required columns) or a smaller dimension scope where semantics allow.

### Original

```DAX
CALCULATE(COUNTA(IncidentsAllFields[incidentid]),FILTER(ALL(IncidentsAllFields),AND(IncidentsAllFields[caseage]>=4320,IncidentsAllFields[caseage]<10080)))
```

### Draft

```DAX
CALCULATE(COUNTA(IncidentsAllFields[incidentid]),FILTER(REMOVEFILTERS(IncidentsAllFields),AND(IncidentsAllFields[caseage]>=4320,IncidentsAllFields[caseage]<10080)))
```

- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [High] _Tickets_3_7Days
- Table: IncidentsAllFields
- Risk: performance: ALL over fact table
- Note: ALL over a fact table is usually too broad. Clear only the columns or dimensions required by the calculation.

### Original

```DAX
CALCULATE(COUNTA(IncidentsAllFields[incidentid]),FILTER(ALL(IncidentsAllFields),AND(IncidentsAllFields[caseage]>=4320,IncidentsAllFields[caseage]<10080)))
```

### Draft

```DAX
CALCULATE(COUNTA(IncidentsAllFields[incidentid]),FILTER(REMOVEFILTERS(/* TODO: choose required IncidentsAllFields columns, not full fact table */),AND(IncidentsAllFields[caseage]>=4320,IncidentsAllFields[caseage]<10080)))
```

- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [High] _Tickets_Over_7Days
- Table: IncidentsAllFields
- Risk: performance: FILTER over ALL
- Note: FILTER(ALL(...)) can over-clear context. Replace ALL(table) with REMOVEFILTERS(required columns) or a smaller dimension scope where semantics allow.

### Original

```DAX
CALCULATE(COUNTA(IncidentsAllFields[incidentid]),FILTER(ALL(IncidentsAllFields),IncidentsAllFields[caseage]>=10080))
```

### Draft

```DAX
CALCULATE(COUNTA(IncidentsAllFields[incidentid]),FILTER(REMOVEFILTERS(IncidentsAllFields),IncidentsAllFields[caseage]>=10080))
```

- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [High] _Tickets_Over_7Days
- Table: IncidentsAllFields
- Risk: performance: ALL over fact table
- Note: ALL over a fact table is usually too broad. Clear only the columns or dimensions required by the calculation.

### Original

```DAX
CALCULATE(COUNTA(IncidentsAllFields[incidentid]),FILTER(ALL(IncidentsAllFields),IncidentsAllFields[caseage]>=10080))
```

### Draft

```DAX
CALCULATE(COUNTA(IncidentsAllFields[incidentid]),FILTER(REMOVEFILTERS(/* TODO: choose required IncidentsAllFields columns, not full fact table */),IncidentsAllFields[caseage]>=10080))
```

- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [Medium] _Potential_SLA_Breach_24h
- Table: IncidentsAllFields
- Risk: determinism: volatile date/time
- Note: Volatile TODAY/NOW changes by query date. Prefer a governed refresh-date measure or a date-table driven filter.

### Original

```DAX
DIVIDE(CALCULATE(COUNTA(IncidentsAllFields[incidentid]),IncidentsAllFields[resolveby]<=TODAY()+1,IncidentsAllFields[statuscodename]<>"Closed"),COUNTA(IncidentsAllFields[incidentid]),0)
```

### Draft

```DAX
DIVIDE(CALCULATE(COUNTA(IncidentsAllFields[incidentid]),IncidentsAllFields[resolveby]<=[As Of Date]+1,IncidentsAllFields[statuscodename]<>"Closed"),COUNTA(IncidentsAllFields[incidentid]),0)
```

- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [Medium] _Status_Date_Mismatch_Count
- Table: IncidentsAllFields
- Risk: determinism: volatile date/time
- Note: Volatile TODAY/NOW changes by query date. Prefer a governed refresh-date measure or a date-table driven filter.

### Original

```DAX
CALCULATE(COUNTA(IncidentsAllFields[incidentid]),IncidentsAllFields[pdw_resolutiondate]<TODAY(),IncidentsAllFields[statuscodename]<>"Closed")
```

### Draft

```DAX
CALCULATE(COUNTA(IncidentsAllFields[incidentid]),IncidentsAllFields[pdw_resolutiondate]<[As Of Date],IncidentsAllFields[statuscodename]<>"Closed")
```

- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [Medium] _Overdue_Tickets_Count
- Table: IncidentsAllFields
- Risk: determinism: volatile date/time
- Note: Volatile TODAY/NOW changes by query date. Prefer a governed refresh-date measure or a date-table driven filter.

### Original

```DAX
CALCULATE(COUNTA(IncidentsAllFields[incidentid]),IncidentsAllFields[resolveby]<TODAY(),IncidentsAllFields[statuscodename]<>"Closed")
```

### Draft

```DAX
CALCULATE(COUNTA(IncidentsAllFields[incidentid]),IncidentsAllFields[resolveby]<[As Of Date],IncidentsAllFields[statuscodename]<>"Closed")
```

- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [High] _Resolution_Time_StdDev
- Table: IncidentsAllFields
- Risk: performance: ALL over fact table
- Note: ALL over a fact table is usually too broad. Clear only the columns or dimensions required by the calculation.

### Original

```DAX
STDEV.P(CALCULATE(IncidentsAllFields[pdw_totalresolutiontime_duration],ALL(IncidentsAllFields)))
```

### Draft

```DAX
STDEV.P(CALCULATE(IncidentsAllFields[pdw_totalresolutiontime_duration],REMOVEFILTERS(/* TODO: choose required IncidentsAllFields columns, not full fact table */)))
```

- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [High] _Anomaly_High_Resolution_Time
- Table: IncidentsAllFields
- Risk: performance: FILTER over ALL
- Note: FILTER(ALL(...)) can over-clear context. Replace ALL(table) with REMOVEFILTERS(required columns) or a smaller dimension scope where semantics allow.

### Original

```DAX
CALCULATE(COUNTA(IncidentsAllFields[incidentid]),FILTER(ALL(IncidentsAllFields),IncidentsAllFields[pdw_totalresolutiontime_duration]>([_AVG TTS]*2*60)))
```

### Draft

```DAX
CALCULATE(COUNTA(IncidentsAllFields[incidentid]),FILTER(REMOVEFILTERS(IncidentsAllFields),IncidentsAllFields[pdw_totalresolutiontime_duration]>([_AVG TTS]*2*60)))
```

- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [High] _Anomaly_High_Resolution_Time
- Table: IncidentsAllFields
- Risk: performance: ALL over fact table
- Note: ALL over a fact table is usually too broad. Clear only the columns or dimensions required by the calculation.

### Original

```DAX
CALCULATE(COUNTA(IncidentsAllFields[incidentid]),FILTER(ALL(IncidentsAllFields),IncidentsAllFields[pdw_totalresolutiontime_duration]>([_AVG TTS]*2*60)))
```

### Draft

```DAX
CALCULATE(COUNTA(IncidentsAllFields[incidentid]),FILTER(REMOVEFILTERS(/* TODO: choose required IncidentsAllFields columns, not full fact table */),IncidentsAllFields[pdw_totalresolutiontime_duration]>([_AVG TTS]*2*60)))
```

- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [High] _Volume_vs_Baseline_Index
- Table: IncidentsAllFields
- Risk: performance: ALL over fact table
- Note: ALL over a fact table is usually too broad. Clear only the columns or dimensions required by the calculation.

### Original

```DAX
DIVIDE([_CountIncidents],CALCULATE(AVERAGE(COUNTA(IncidentsAllFields[incidentid])),ALL(IncidentsAllFields)),0)
```

### Draft

```DAX
DIVIDE([_CountIncidents],CALCULATE(AVERAGE(COUNTA(IncidentsAllFields[incidentid])),REMOVEFILTERS(/* TODO: choose required IncidentsAllFields columns, not full fact table */)),0)
```

- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [High] _CSAT_Score
- Table: IncidentsAllFields
- Risk: correctness: Excel-style COUNTIF in DAX
- Note: COUNTIF is not valid DAX. Replace each occurrence with CALCULATE(COUNTROWS(...), filter predicates) after confirming the target table and filter semantics.

### Original

```DAX
DIVIDE(COUNTIF(IncidentsAllFields[satisfactionindex], ">= 4"), COUNTIF(IncidentsAllFields[satisfactionindex], "<> -999"), 0) * 100
```

### Draft

```DAX
/* DRAFT: replace COUNTIF with CALCULATE + COUNTROWS after business validation. */
DIVIDE(COUNTIF(IncidentsAllFields[satisfactionindex], ">= 4"), COUNTIF(IncidentsAllFields[satisfactionindex], "<> -999"), 0) * 100
```

- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [High] _Top_Problem_Categories_Pareto
- Table: IncidentsAllFields
- Risk: correctness: Excel-style COUNTIF in DAX
- Note: COUNTIF is not valid DAX. Replace each occurrence with CALCULATE(COUNTROWS(...), filter predicates) after confirming the target table and filter semantics.

### Original

```DAX
COUNTIF(IncidentsAllFields[type], "Problem") * 0.2
```

### Draft

```DAX
/* DRAFT: replace COUNTIF with CALCULATE + COUNTROWS after business validation. */
COUNTIF(IncidentsAllFields[type], "Problem") * 0.2
```

- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [High] _Root_Cause_Identification_Rate
- Table: IncidentsAllFields
- Risk: correctness: Excel-style COUNTIF in DAX
- Note: COUNTIF is not valid DAX. Replace each occurrence with CALCULATE(COUNTROWS(...), filter predicates) after confirming the target table and filter semantics.

### Original

```DAX
DIVIDE(COUNTIF(IncidentsAllFields[description], "*Root Cause*"), [_CountIncidents], 0) * 100
```

### Draft

```DAX
/* DRAFT: replace COUNTIF with CALCULATE + COUNTROWS after business validation. */
DIVIDE(COUNTIF(IncidentsAllFields[description], "*Root Cause*"), [_CountIncidents], 0) * 100
```

- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [High] _KB_Self_Service_Rate
- Table: IncidentsAllFields
- Risk: correctness: Excel-style COUNTIF in DAX
- Note: COUNTIF is not valid DAX. Replace each occurrence with CALCULATE(COUNTROWS(...), filter predicates) after confirming the target table and filter semantics.

### Original

```DAX
DIVIDE(COUNTIF(IncidentsAllFields[typename], "Knowledge Base"), [_CountIncidents], 0) * 100
```

### Draft

```DAX
/* DRAFT: replace COUNTIF with CALCULATE + COUNTROWS after business validation. */
DIVIDE(COUNTIF(IncidentsAllFields[typename], "Knowledge Base"), [_CountIncidents], 0) * 100
```

- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [High] _Recurring_Issue_Ratio
- Table: IncidentsAllFields
- Risk: correctness: Excel-style COUNTIF in DAX
- Note: COUNTIF is not valid DAX. Replace each occurrence with CALCULATE(COUNTROWS(...), filter predicates) after confirming the target table and filter semantics.

### Original

```DAX
DIVIDE(COUNTIF(IncidentsAllFields[resolvedbykbkbase], TRUE), [_CountIncidents], 0) * 100
```

### Draft

```DAX
/* DRAFT: replace COUNTIF with CALCULATE + COUNTROWS after business validation. */
DIVIDE(COUNTIF(IncidentsAllFields[resolvedbykbkbase], TRUE), [_CountIncidents], 0) * 100
```

- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [High] _Agents_Needing_Training
- Table: IncidentsAllFields
- Risk: correctness: Excel-style COUNTIF in DAX
- Note: COUNTIF is not valid DAX. Replace each occurrence with CALCULATE(COUNTROWS(...), filter predicates) after confirming the target table and filter semantics.

### Original

```DAX
COUNTIF(IncidentsAllFields[ownerid], "<> BLANK") - COUNTX(FILTER(SUMMARIZE(IncidentsAllFields, IncidentsAllFields[ownerid]), [_Agent_Skill_Gap] < 1.2 && [_Agent_Burnout_Risk] < 60), 1)
```

### Draft

```DAX
/* DRAFT: replace COUNTIF with CALCULATE + COUNTROWS after business validation. */
COUNTIF(IncidentsAllFields[ownerid], "<> BLANK") - COUNTX(FILTER(SUMMARIZE(IncidentsAllFields, IncidentsAllFields[ownerid]), [_Agent_Skill_Gap] < 1.2 && [_Agent_Burnout_Risk] < 60), 1)
```

- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [High] _Handoff_Success_Rate
- Table: IncidentsAllFields
- Risk: correctness: Excel-style COUNTIF in DAX
- Note: COUNTIF is not valid DAX. Replace each occurrence with CALCULATE(COUNTROWS(...), filter predicates) after confirming the target table and filter semantics.

### Original

```DAX
DIVIDE(COUNTIF(IncidentsAllFields[isescalated], FALSE), [_CountIncidents], 0) * 100
```

### Draft

```DAX
/* DRAFT: replace COUNTIF with CALCULATE + COUNTROWS after business validation. */
DIVIDE(COUNTIF(IncidentsAllFields[isescalated], FALSE), [_CountIncidents], 0) * 100
```

- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [High] _Ticket_Rework_Rate
- Table: IncidentsAllFields
- Risk: correctness: Excel-style COUNTIF in DAX
- Note: COUNTIF is not valid DAX. Replace each occurrence with CALCULATE(COUNTROWS(...), filter predicates) after confirming the target table and filter semantics.

### Original

```DAX
DIVIDE(COUNTIF(IncidentsAllFields[iserrorticket], TRUE), [_CountIncidents], 0) * 100
```

### Draft

```DAX
/* DRAFT: replace COUNTIF with CALCULATE + COUNTROWS after business validation. */
DIVIDE(COUNTIF(IncidentsAllFields[iserrorticket], TRUE), [_CountIncidents], 0) * 100
```

- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [Medium] _Holiday_Impact_Index
- Table: IncidentsAllFields
- Risk: determinism: volatile date/time
- Note: Volatile TODAY/NOW changes by query date. Prefer a governed refresh-date measure or a date-table driven filter.

### Original

```DAX
IF(MONTH(TODAY()) = 12 OR MONTH(TODAY()) = 1 OR MONTH(TODAY()) = 8, DIVIDE([_CountIncidents], AVERAGEX(VALUES(Calendar[Monat]), [_CountIncidents]), 1), 1)
```

### Draft

```DAX
IF(MONTH([As Of Date]) = 12 OR MONTH([As Of Date]) = 1 OR MONTH([As Of Date]) = 8, DIVIDE([_CountIncidents], AVERAGEX(VALUES(Calendar[Monat]), [_CountIncidents]), 1), 1)
```

- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [High] _Peak_Business_Hours_Concentration
- Table: IncidentsAllFields
- Risk: correctness: Excel-style COUNTIF in DAX
- Note: COUNTIF is not valid DAX. Replace each occurrence with CALCULATE(COUNTROWS(...), filter predicates) after confirming the target table and filter semantics.

### Original

```DAX
DIVIDE(COUNTIF(IncidentsAllFields[createdon], ">= 8:00" & IncidentsAllFields[createdon], "<= 18:00"), [_CountIncidents], 0) * 100
```

### Draft

```DAX
/* DRAFT: replace COUNTIF with CALCULATE + COUNTROWS after business validation. */
DIVIDE(COUNTIF(IncidentsAllFields[createdon], ">= 8:00" & IncidentsAllFields[createdon], "<= 18:00"), [_CountIncidents], 0) * 100
```

- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [Medium] _Cyclical_Pattern_Detected
- Table: IncidentsAllFields
- Risk: determinism: volatile date/time
- Note: Volatile TODAY/NOW changes by query date. Prefer a governed refresh-date measure or a date-table driven filter.

### Original

```DAX
IF(MOD(DAY(TODAY()), 7) = 1, "Weekly-Pattern", IF(MOD(DAY(TODAY()), 14) = 1, "BiWeekly-Pattern", "No-Pattern"))
```

### Draft

```DAX
IF(MOD(DAY([As Of Date]), 7) = 1, "Weekly-Pattern", IF(MOD(DAY([As Of Date]), 14) = 1, "BiWeekly-Pattern", "No-Pattern"))
```

- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [High] _Ticket_Type_TTR_Prediction
- Table: IncidentsAllFields
- Risk: correctness: Excel-style COUNTIF in DAX
- Note: COUNTIF is not valid DAX. Replace each occurrence with CALCULATE(COUNTROWS(...), filter predicates) after confirming the target table and filter semantics.

### Original

```DAX
AVERAGE(IncidentsAllFields[_AVG TTS]) * (1 + (COUNTIF(IncidentsAllFields[type], "Problem") / [_CountIncidents]))
```

### Draft

```DAX
/* DRAFT: replace COUNTIF with CALCULATE + COUNTROWS after business validation. */
AVERAGE(IncidentsAllFields[_AVG TTS]) * (1 + (COUNTIF(IncidentsAllFields[type], "Problem") / [_CountIncidents]))
```

- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [High] _Root_Cause_Correlation_Score
- Table: IncidentsAllFields
- Risk: correctness: Excel-style COUNTIF in DAX
- Note: COUNTIF is not valid DAX. Replace each occurrence with CALCULATE(COUNTROWS(...), filter predicates) after confirming the target table and filter semantics.

### Original

```DAX
INT((COUNTIF(IncidentsAllFields[prioritycode], ">2") / [_CountIncidents] * 40 + COUNTIF(IncidentsAllFields[typename], "*Problem*") / [_CountIncidents] * 35 + [_Escalation_Rate] * 25))
```

### Draft

```DAX
/* DRAFT: replace COUNTIF with CALCULATE + COUNTROWS after business validation. */
INT((COUNTIF(IncidentsAllFields[prioritycode], ">2") / [_CountIncidents] * 40 + COUNTIF(IncidentsAllFields[typename], "*Problem*") / [_CountIncidents] * 35 + [_Escalation_Rate] * 25))
```

- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [High] _Channel_Performance_Email
- Table: IncidentsAllFields
- Risk: correctness: Excel-style COUNTIF in DAX
- Note: COUNTIF is not valid DAX. Replace each occurrence with CALCULATE(COUNTROWS(...), filter predicates) after confirming the target table and filter semantics.

### Original

```DAX
COUNTIF(IncidentsAllFields[caseorigincodename], "*Email*") / COUNTIF(IncidentsAllFields[caseorigincodename], "<>") * 100
```

### Draft

```DAX
/* DRAFT: replace COUNTIF with CALCULATE + COUNTROWS after business validation. */
COUNTIF(IncidentsAllFields[caseorigincodename], "*Email*") / COUNTIF(IncidentsAllFields[caseorigincodename], "<>") * 100
```

- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [High] _Preferred_Channel_Detection
- Table: IncidentsAllFields
- Risk: correctness: Excel-style COUNTIF in DAX
- Note: COUNTIF is not valid DAX. Replace each occurrence with CALCULATE(COUNTROWS(...), filter predicates) after confirming the target table and filter semantics.

### Original

```DAX
IF(COUNTIF(IncidentsAllFields[caseorigincodename], "*Phone*") > COUNTIF(IncidentsAllFields[caseorigincodename], "*Email*"), "Phone", "Email")
```

### Draft

```DAX
/* DRAFT: replace COUNTIF with CALCULATE + COUNTROWS after business validation. */
IF(COUNTIF(IncidentsAllFields[caseorigincodename], "*Phone*") > COUNTIF(IncidentsAllFields[caseorigincodename], "*Email*"), "Phone", "Email")
```

- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [High] _Channel_CSAT_Differential
- Table: IncidentsAllFields
- Risk: correctness: Excel-style COUNTIF in DAX
- Note: COUNTIF is not valid DAX. Replace each occurrence with CALCULATE(COUNTROWS(...), filter predicates) after confirming the target table and filter semantics.

### Original

```DAX
[_CSAT_Score] * DIVIDE(COUNTIF(IncidentsAllFields[customersatisfactioncodename], "*Satisfied*"), [_CountIncidents], 0)
```

### Draft

```DAX
/* DRAFT: replace COUNTIF with CALCULATE + COUNTROWS after business validation. */
[_CSAT_Score] * DIVIDE(COUNTIF(IncidentsAllFields[customersatisfactioncodename], "*Satisfied*"), [_CountIncidents], 0)
```

- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [High] _Context_Switching_Cost
- Table: IncidentsAllFields
- Risk: correctness: Excel-style COUNTIF in DAX
- Note: COUNTIF is not valid DAX. Replace each occurrence with CALCULATE(COUNTROWS(...), filter predicates) after confirming the target table and filter semantics.

### Original

```DAX
DIVIDE(COUNTIF(IncidentsAllFields[casetypecodename], "<>"), [_Avg_Cases_Per_Agent], 0) * 5
```

### Draft

```DAX
/* DRAFT: replace COUNTIF with CALCULATE + COUNTROWS after business validation. */
DIVIDE(COUNTIF(IncidentsAllFields[casetypecodename], "<>"), [_Avg_Cases_Per_Agent], 0) * 5
```

- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [High] _Data_Privacy_Compliance
- Table: IncidentsAllFields
- Risk: correctness: Excel-style COUNTIF in DAX
- Note: COUNTIF is not valid DAX. Replace each occurrence with CALCULATE(COUNTROWS(...), filter predicates) after confirming the target table and filter semantics.

### Original

```DAX
MIN((1 - [_Missing_Description_Rate] / 100 - DIVIDE(COUNTIF(IncidentsAllFields[contactidname], "BLANK"), [_CountIncidents], 0) * 50) * 100, 100)
```

### Draft

```DAX
/* DRAFT: replace COUNTIF with CALCULATE + COUNTROWS after business validation. */
MIN((1 - [_Missing_Description_Rate] / 100 - DIVIDE(COUNTIF(IncidentsAllFields[contactidname], "BLANK"), [_CountIncidents], 0) * 50) * 100, 100)
```

- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [High] _Escalation_Authority_Compliance
- Table: IncidentsAllFields
- Risk: correctness: Excel-style COUNTIF in DAX
- Note: COUNTIF is not valid DAX. Replace each occurrence with CALCULATE(COUNTROWS(...), filter predicates) after confirming the target table and filter semantics.

### Original

```DAX
DIVIDE([_Escalated_Tickets_Count], COUNTIF(IncidentsAllFields[isescalated], TRUE), 0) * 100
```

### Draft

```DAX
/* DRAFT: replace COUNTIF with CALCULATE + COUNTROWS after business validation. */
DIVIDE([_Escalated_Tickets_Count], COUNTIF(IncidentsAllFields[isescalated], TRUE), 0) * 100
```

- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

## [Medium] _Quarter_Performance_Trend
- Table: IncidentsAllFields
- Risk: determinism: volatile date/time
- Note: Volatile TODAY/NOW changes by query date. Prefer a governed refresh-date measure or a date-table driven filter.

### Original

```DAX
([_SLA_Compliance] + [_FirstContactResolutionRate_FCR] * 100) / 2 * POWER(1.05, INT(MONTH(TODAY()) / 3))
```

### Draft

```DAX
([_SLA_Compliance] + [_FirstContactResolutionRate_FCR] * 100) / 2 * POWER(1.05, INT(MONTH([As Of Date]) / 3))
```

- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.



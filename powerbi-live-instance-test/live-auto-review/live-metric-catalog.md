# Power BI Live Metric Catalog

Server: `Data Source=localhost:64728`
Metrics: 170
Metrics needing review: 12

## IncidentsAllFields[_CountIncidents]

- ID: `incidentsallfields._countincidents`
- Tags: operations
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
DISTINCTCOUNT(IncidentsAllFields[incidentid])
```

## IncidentsAllFields[_AVGX _CountIncidentsPerDay]

- ID: `incidentsallfields._avgx-_countincidentsperday`
- Tags: operations
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX

AVERAGEX(
	KEEPFILTERS(VALUES('IncidentsAllFields'[createdon])),
	CALCULATE([_CountIncidents])
)
```

## IncidentsAllFields[_Case Age Hours]

- ID: `incidentsallfields._case-age-hours`
- Tags: operations, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX

DIVIDE(
	SUM('IncidentsAllFields'[caseage]),
	60)

```

## IncidentsAllFields[_AVGCase Age Hours]

- ID: `incidentsallfields._avgcase-age-hours`
- Tags: operations, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX

DIVIDE([_Case Age Hours], [_CountIncidents])
```

## IncidentsAllFields[_CountIncidents MTD]

- ID: `incidentsallfields._countincidents-mtd`
- Tags: operations, time-intelligence
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX

TOTALMTD([_CountIncidents], 'Calendar'[Date])
```

## IncidentsAllFields[_CountIncidents YTD]

- ID: `incidentsallfields._countincidents-ytd`
- Tags: operations, time-intelligence
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX

TOTALYTD([_CountIncidents], 'Calendar'[Date])
```

## IncidentsAllFields[_CountIncidents YoY%]

- ID: `incidentsallfields._countincidents-yoypct`
- Tags: operations, time-intelligence, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX

VAR __PREV_YEAR = CALCULATE([_CountIncidents], DATEADD('Calendar'[Date], -1, YEAR))
RETURN
	DIVIDE([_CountIncidents] - __PREV_YEAR, __PREV_YEAR)
```

## IncidentsAllFields[Gleitender Durchschnitt für "_CountIncidents"]

- ID: `incidentsallfields.gleitender-durchschnitt-für-"_countincidents"`
- Tags: operations, time-intelligence
- Risk level: review
- Risks: usability: measure can intentionally raise ERROR; maintainability: long expression
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

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

## IncidentsAllFields[AVG _CountIncidents_Date]

- ID: `incidentsallfields.avg-_countincidents_date`
- Tags: operations
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX

AVERAGEX(
	KEEPFILTERS(VALUES('Calendar'[Date])),
	CALCULATE([_CountIncidents])
)
```

## IncidentsAllFields[_Open_Incidents]

- ID: `incidentsallfields._open_incidents`
- Tags: operations
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX

CALCULATE (
    COUNTROWS('IncidentsAllFields'),
    'IncidentsAllFields'[statuscodename] <> "Behoben" && 'IncidentsAllFields'[statuscodename] <> "Abgeschlossen"
)

```

## IncidentsAllFields[_Incidents_Prio]

- ID: `incidentsallfields._incidents_prio`
- Tags: operations
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX

CALCULATE (
    COUNTROWS('IncidentsAllFields'),
    ALLEXCEPT('IncidentsAllFields', 'IncidentsAllFields'[pdw_priority_codename])
)

```

## IncidentsAllFields[_SLA_Conflict]

- ID: `incidentsallfields._sla_conflict`
- Tags: sla, operations
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX

COUNTROWS (
    FILTER (
        'IncidentsAllFields',
        'IncidentsAllFields'[firstresponsesent] = FALSE()
            && NOT(ISBLANK('IncidentsAllFields'[resolveby]))
            && 'IncidentsAllFields'[createdon] > 'IncidentsAllFields'[resolveby]
    )
)

```

## IncidentsAllFields[_AVG TTR]

- ID: `incidentsallfields._avg-ttr`
- Tags: operations
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX

AVERAGEX (
    'IncidentsAllFields',
    DATEDIFF('IncidentsAllFields'[createdon - DateTime], 'IncidentsAllFields'[responseby], HOUR)
)

```

## IncidentsAllFields[_AVG TTS]

- ID: `incidentsallfields._avg-tts`
- Tags: operations
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX

VAR gueltigeTickets =
    FILTER (
        'IncidentsAllFields',
        NOT ISBLANK('IncidentsAllFields'[createdon - DateTime])
            && NOT ISBLANK('IncidentsAllFields'[pdw_resolutiondate])
            && 'IncidentsAllFields'[pdw_resolutiondate] >= 'IncidentsAllFields'[createdon - DateTime]
    )
RETURN
AVERAGEX (
    gueltigeTickets,
    DATEDIFF(
        'IncidentsAllFields'[createdon - DateTime],
        'IncidentsAllFields'[pdw_resolutiondate],
        HOUR
    )
)

```

## IncidentsAllFields[_FirstContactResolutionRate_FCR]

- ID: `incidentsallfields._firstcontactresolutionrate_fcr`
- Tags: operations, customer, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX

DIVIDE(
    COUNTROWS(
        FILTER(
            IncidentsAllFields,
            IncidentsAllFields[isEscalated] = FALSE  -- nicht eskaliert
            && IncidentsAllFields[merged] = FALSE    -- nicht wiederer\u00f6ffnet (angenommen merged=TRUE kennzeichnet Reopen)
            -- weitere Kriterien f\u00fcr FCR k\u00f6nnen hier hinzu (z.B. gel\u00f6st beim FirstResponse)
        )
    ),
    COUNTROWS( IncidentsAllFields )
)

```

## IncidentsAllFields[_CountIncidents gesamt für statuscodename]

- ID: `incidentsallfields._countincidents-gesamt-für-statuscodename`
- Tags: operations
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX

CALCULATE(
	[_CountIncidents],
	ALLSELECTED('IncidentsAllFields'[statuscodename])
)
```

## IncidentsAllFields[_SLA_Compliance]

- ID: `incidentsallfields._sla_compliance`
- Tags: sla, operations, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
VAR TotalIncidents = [_CountIncidents]
VAR BreachCount = [_SLA_Conflict]
RETURN
MAX ( 0, 1 - DIVIDE ( BreachCount, TotalIncidents, 0 ) )
```

## IncidentsAllFields[_Resolution_Time_Trend]

- ID: `incidentsallfields._resolution_time_trend`
- Tags: uncategorized
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
CALCULATE([_AVG TTS],ALL(Calendar[Jahr],Calendar[Quartal],Calendar[Monat]))/[_AVG TTS]
```

## IncidentsAllFields[_Open_vs_Closed_Ratio]

- ID: `incidentsallfields._open_vs_closed_ratio`
- Tags: operations, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
DIVIDE([_Open_Incidents],CALCULATE([_CountIncidents]),1)
```

## IncidentsAllFields[_Escalation_Rate]

- ID: `incidentsallfields._escalation_rate`
- Tags: operations, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
DIVIDE (
    CALCULATE (
        DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
        IncidentsAllFields[isescalated] = TRUE ()
    ),
    [_CountIncidents],
    0
)
```

## IncidentsAllFields[_Avg_Days_Open]

- ID: `incidentsallfields._avg_days_open`
- Tags: operations, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
DIVIDE(SUM(IncidentsAllFields[caseage]),COUNT(IncidentsAllFields[incidentid])*1440,0)
```

## IncidentsAllFields[_Backlog_Volume]

- ID: `incidentsallfields._backlog_volume`
- Tags: operations
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
[_Open_Incidents]
```

## IncidentsAllFields[_Ticket_Velocity]

- ID: `incidentsallfields._ticket_velocity`
- Tags: operations, time-intelligence, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
VAR MinDate =
    CALCULATE ( MIN ( 'Calendar'[Date] ), ALL ( 'Calendar' ) )
VAR MaxDate =
    CALCULATE ( MAX ( 'Calendar'[Date] ), ALL ( 'Calendar' ) )
VAR WeeksInCalendar =
    MAX ( 1, DATEDIFF ( MinDate, MaxDate, WEEK ) + 1 )
RETURN
DIVIDE ( [_CountIncidents], WeeksInCalendar, 0 )
```

## IncidentsAllFields[_Repeat_Customer_Rate]

- ID: `incidentsallfields._repeat_customer_rate`
- Tags: operations, customer, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
VAR CustomersWithIncidents =
    FILTER (
        VALUES ( IncidentsAllFields[contactid] ),
        NOT ISBLANK ( IncidentsAllFields[contactid] )
            && CALCULATE ( [_CountIncidents] ) > 1
    )
RETURN
DIVIDE (
    COUNTROWS ( CustomersWithIncidents ),
    CALCULATE (
        DISTINCTCOUNT ( IncidentsAllFields[contactid] ),
        NOT ISBLANK ( IncidentsAllFields[contactid] )
    ),
    0
)
```

## IncidentsAllFields[_First_Response_SLA_Met]

- ID: `incidentsallfields._first_response_sla_met`
- Tags: sla, operations, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
DIVIDE(CALCULATE(COUNTA(IncidentsAllFields[incidentid]),IncidentsAllFields[firstresponsesent]="Yes"),COUNTA(IncidentsAllFields[incidentid]),0)
```

## IncidentsAllFields[_SLA_Breach_Count]

- ID: `incidentsallfields._sla_breach_count`
- Tags: sla
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
[_SLA_Conflict]
```

## IncidentsAllFields[_Tickets_0_1Day]

- ID: `incidentsallfields._tickets_0_1day`
- Tags: operations
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
CALCULATE (
    DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
    KEEPFILTERS ( IncidentsAllFields[caseage] < 1440 )
)
```

## IncidentsAllFields[_Tickets_1_3Days]

- ID: `incidentsallfields._tickets_1_3days`
- Tags: operations
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
CALCULATE (
    DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
    KEEPFILTERS ( IncidentsAllFields[caseage] >= 1440 ),
    KEEPFILTERS ( IncidentsAllFields[caseage] < 4320 )
)
```

## IncidentsAllFields[_Tickets_3_7Days]

- ID: `incidentsallfields._tickets_3_7days`
- Tags: operations
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
CALCULATE (
    DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
    KEEPFILTERS ( IncidentsAllFields[caseage] >= 4320 ),
    KEEPFILTERS ( IncidentsAllFields[caseage] < 10080 )
)
```

## IncidentsAllFields[_Tickets_Over_7Days]

- ID: `incidentsallfields._tickets_over_7days`
- Tags: operations
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
CALCULATE (
    DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
    KEEPFILTERS ( IncidentsAllFields[caseage] >= 10080 )
)
```

## IncidentsAllFields[_Median_Resolution_Hours]

- ID: `incidentsallfields._median_resolution_hours`
- Tags: operations
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
CALCULATE(MEDIAN(IncidentsAllFields[pdw_totalresolutiontime_duration])/60)
```

## IncidentsAllFields[_Potential_SLA_Breach_24h]

- ID: `incidentsallfields._potential_sla_breach_24h`
- Tags: sla, operations, time-intelligence, ratio
- Risk level: review
- Risks: determinism: volatile date/time
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
DIVIDE(CALCULATE(COUNTA(IncidentsAllFields[incidentid]),IncidentsAllFields[resolveby]<=TODAY()+1,IncidentsAllFields[statuscodename]<>"Closed"),COUNTA(IncidentsAllFields[incidentid]),0)
```

## IncidentsAllFields[_Top_Priority_Ticket_Count]

- ID: `incidentsallfields._top_priority_ticket_count`
- Tags: operations
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
CALCULATE(COUNTA(IncidentsAllFields[incidentid]),TOPN(1,VALUES(IncidentsAllFields[pdw_priority_codename]),COUNTA(IncidentsAllFields[incidentid])))
```

## IncidentsAllFields[_Month_over_Month_Change]

- ID: `incidentsallfields._month_over_month_change`
- Tags: operations, time-intelligence, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
DIVIDE([_CountIncidents]-CALCULATE([_CountIncidents],DATEADD(Calendar[Date],-30,DAY)),CALCULATE([_CountIncidents],DATEADD(Calendar[Date],-30,DAY)),0)
```

## IncidentsAllFields[_Escalated_Tickets_Count]

- ID: `incidentsallfields._escalated_tickets_count`
- Tags: operations
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
CALCULATE(COUNTA(IncidentsAllFields[incidentid]),IncidentsAllFields[isescalatedname]="Yes")
```

## IncidentsAllFields[_Top_Agent_Case_Load]

- ID: `incidentsallfields._top_agent_case_load`
- Tags: operations
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
CALCULATE(COUNTA(IncidentsAllFields[incidentid]),TOPN(1,VALUES(IncidentsAllFields[owneridname]),COUNTA(IncidentsAllFields[incidentid])))
```

## IncidentsAllFields[_Avg_Cases_Per_Agent]

- ID: `incidentsallfields._avg_cases_per_agent`
- Tags: operations, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
DIVIDE(COUNTA(IncidentsAllFields[incidentid]),DISTINCTCOUNT(IncidentsAllFields[owneridname]),0)
```

## IncidentsAllFields[_First_Fix_Quality_Rate]

- ID: `incidentsallfields._first_fix_quality_rate`
- Tags: operations, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
DIVIDE(CALCULATE(COUNTA(IncidentsAllFields[incidentid]),IncidentsAllFields[merged]="No"),COUNTA(IncidentsAllFields[incidentid]),0)
```

## IncidentsAllFields[_Missing_Description_Rate]

- ID: `incidentsallfields._missing_description_rate`
- Tags: operations, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
DIVIDE(CALCULATE(COUNTA(IncidentsAllFields[incidentid]),ISBLANK(IncidentsAllFields[description])),COUNTA(IncidentsAllFields[incidentid]),0)
```

## IncidentsAllFields[_Unassigned_Tickets]

- ID: `incidentsallfields._unassigned_tickets`
- Tags: operations
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
CALCULATE(COUNTA(IncidentsAllFields[incidentid]),ISBLANK(IncidentsAllFields[owneridname]))
```

## IncidentsAllFields[_Status_Date_Mismatch_Count]

- ID: `incidentsallfields._status_date_mismatch_count`
- Tags: operations, time-intelligence
- Risk level: review
- Risks: determinism: volatile date/time
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
CALCULATE(COUNTA(IncidentsAllFields[incidentid]),IncidentsAllFields[pdw_resolutiondate]<TODAY(),IncidentsAllFields[statuscodename]<>"Closed")
```

## IncidentsAllFields[_Overdue_Tickets_Count]

- ID: `incidentsallfields._overdue_tickets_count`
- Tags: operations, time-intelligence
- Risk level: review
- Risks: determinism: volatile date/time
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
CALCULATE(COUNTA(IncidentsAllFields[incidentid]),IncidentsAllFields[resolveby]<TODAY(),IncidentsAllFields[statuscodename]<>"Closed")
```

## IncidentsAllFields[_Missing_Resolution_Notes_Rate]

- ID: `incidentsallfields._missing_resolution_notes_rate`
- Tags: operations, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
DIVIDE(CALCULATE(COUNTA(IncidentsAllFields[incidentid]),ISBLANK(IncidentsAllFields[pdw_resolution])),COUNTA(IncidentsAllFields[incidentid]),0)
```

## IncidentsAllFields[_Data_Quality_Score]

- ID: `incidentsallfields._data_quality_score`
- Tags: uncategorized
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
(1-(([_Missing_Description_Rate]+[_Missing_Resolution_Notes_Rate])/2))*100
```

## IncidentsAllFields[_Daily_Spike_Detection]

- ID: `incidentsallfields._daily_spike_detection`
- Tags: operations, time-intelligence, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
DIVIDE([_CountIncidents]-CALCULATE([_CountIncidents],DATEADD(Calendar[Date],-7,DAY)),CALCULATE([_CountIncidents],DATEADD(Calendar[Date],-7,DAY)),0)
```

## IncidentsAllFields[_Resolution_Time_StdDev]

- ID: `incidentsallfields._resolution_time_stddev`
- Tags: operations
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
STDEV.P ( IncidentsAllFields[pdw_totalresolutiontime_duration] )
```

## IncidentsAllFields[_Anomaly_High_Resolution_Time]

- ID: `incidentsallfields._anomaly_high_resolution_time`
- Tags: operations
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
VAR ThresholdMinutes = [_AVG TTS] * 2 * 60
RETURN
CALCULATE (
    DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
    KEEPFILTERS ( IncidentsAllFields[pdw_totalresolutiontime_duration] > ThresholdMinutes )
)
```

## IncidentsAllFields[_Peak_Month_Volume]

- ID: `incidentsallfields._peak_month_volume`
- Tags: operations, time-intelligence
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
MAXX ( VALUES ( 'Calendar'[JahrMonat] ), [_CountIncidents] )
```

## IncidentsAllFields[_Low_Month_Volume]

- ID: `incidentsallfields._low_month_volume`
- Tags: operations, time-intelligence
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
MINX ( VALUES ( 'Calendar'[JahrMonat] ), [_CountIncidents] )
```

## IncidentsAllFields[_Volume_vs_Baseline_Index]

- ID: `incidentsallfields._volume_vs_baseline_index`
- Tags: operations, time-intelligence, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
VAR BaselineMonthlyVolume =
    AVERAGEX ( ALL ( 'Calendar'[JahrMonat] ), [_CountIncidents] )
RETURN
DIVIDE ( [_CountIncidents], BaselineMonthlyVolume, 0 )
```

## IncidentsAllFields[_Escalation_Probability]

- ID: `incidentsallfields._escalation_probability`
- Tags: operations, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
DIVIDE(CALCULATE([_Escalated_Tickets_Count]),CALCULATE([_CountIncidents]),0)
```

## IncidentsAllFields[_Estimated_Days_to_Clear_Backlog]

- ID: `incidentsallfields._estimated_days_to_clear_backlog`
- Tags: operations, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
DIVIDE([_CountIncidents]*[_AVG TTS],24,0)
```

## IncidentsAllFields[_Customer_Support_Burden_Score]

- ID: `incidentsallfields._customer_support_burden_score`
- Tags: customer
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
MIN([_Repeat_Customer_Rate]*100,100)
```

## IncidentsAllFields[_High_Priority_Backlog_Percent]

- ID: `incidentsallfields._high_priority_backlog_percent`
- Tags: operations, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
DIVIDE(CALCULATE(COUNTA(IncidentsAllFields[incidentid]),IncidentsAllFields[pdw_priority_codename]="High",IncidentsAllFields[statuscodename]<>"Closed"),[_Open_Incidents],0)
```

## IncidentsAllFields[_Team_Stress_Index]

- ID: `incidentsallfields._team_stress_index`
- Tags: sla, operations
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
MIN((([_Open_Incidents]/100)+([_Escalation_Rate]*100)+([_Potential_SLA_Breach_24h]*100))/3,100)
```

## IncidentsAllFields[_TTR_Prediction_Confidence]

- ID: `incidentsallfields._ttr_prediction_confidence`
- Tags: uncategorized
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
MIN([_Data_Quality_Score]*0.8,100)
```

## IncidentsAllFields[_CSAT_Score]

- ID: `incidentsallfields._csat_score`
- Tags: operations, customer, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
VAR Satisfied =
    CALCULATE (
        DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
        CONTAINSSTRING ( IncidentsAllFields[customersatisfactioncodename], "Satisfied" )
    )
VAR Rated =
    CALCULATE (
        DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
        NOT ISBLANK ( IncidentsAllFields[customersatisfactioncodename] )
    )
RETURN
DIVIDE ( Satisfied, Rated, 0 ) * 100
```

## IncidentsAllFields[_Customer_Effort_Score]

- ID: `incidentsallfields._customer_effort_score`
- Tags: operations, customer, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
DIVIDE(SUMX(SUMMARIZE(IncidentsAllFields, IncidentsAllFields[contactid]), IF([_First_Fix_Quality_Rate] > 0.8, 5, IF([_First_Fix_Quality_Rate] > 0.6, 3, 1))), DISTINCTCOUNT(IncidentsAllFields[contactid]), 0)
```

## IncidentsAllFields[_Churn_Risk_Indicator]

- ID: `incidentsallfields._churn_risk_indicator`
- Tags: operations, customer, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
DIVIDE(COUNTX(FILTER(SUMMARIZE(IncidentsAllFields, IncidentsAllFields[contactid], "OpenTickets", [_Open_Incidents], "UnresolvedDays", [_Avg_Days_Open]), [OpenTickets] > 3 && [UnresolvedDays] > 15), 1), DISTINCTCOUNT(IncidentsAllFields[contactid]), 0) * 100
```

## IncidentsAllFields[_Customer_Lifetime_Value]

- ID: `incidentsallfields._customer_lifetime_value`
- Tags: operations, customer, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
DIVIDE(SUMX(SUMMARIZE(IncidentsAllFields, IncidentsAllFields[contactid], "TicketCount", DISTINCTCOUNT(IncidentsAllFields[incidentid]), "FirstFixRate", [_FirstContactResolutionRate_FCR]), IF([FirstFixRate] > 0.7, [TicketCount] * 100, [TicketCount] * 50)), DISTINCTCOUNT(IncidentsAllFields[contactid]), 0)
```

## IncidentsAllFields[_Volume_Forecast_4Weeks]

- ID: `incidentsallfields._volume_forecast_4weeks`
- Tags: operations, time-intelligence
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
([_CountIncidents] * 28) / (DISTINCTCOUNT(Calendar[Date]) + 1)
```

## IncidentsAllFields[_Capacity_Planning_Agents_Needed]

- ID: `incidentsallfields._capacity_planning_agents_needed`
- Tags: operations
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
INT([_Backlog_Volume] / (MAX(5, [_Ticket_Velocity]) * 5)) + 1
```

## IncidentsAllFields[_SLA_Breach_Forecast_24h]

- ID: `incidentsallfields._sla_breach_forecast_24h`
- Tags: sla, operations
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
[_Potential_SLA_Breach_24h] * (1 + ([_Backlog_Volume] / MAX(1, [_Open_Incidents])))
```

## IncidentsAllFields[_Seasonality_Index]

- ID: `incidentsallfields._seasonality_index`
- Tags: operations, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
DIVIDE([_CountIncidents], AVERAGEX(VALUES(Calendar[Monat]), [_CountIncidents]), 1)
```

## IncidentsAllFields[_Top_Problem_Categories_Pareto]

- ID: `incidentsallfields._top_problem_categories_pareto`
- Tags: operations
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
CALCULATE (
    DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
    CONTAINSSTRING ( IncidentsAllFields[casetypecodename], "Problem" )
) * 0.2
```

## IncidentsAllFields[_Root_Cause_Identification_Rate]

- ID: `incidentsallfields._root_cause_identification_rate`
- Tags: operations, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
DIVIDE (
    CALCULATE (
        DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
        CONTAINSSTRING ( IncidentsAllFields[description], "Root Cause" )
    ),
    [_CountIncidents],
    0
) * 100
```

## IncidentsAllFields[_KB_Self_Service_Rate]

- ID: `incidentsallfields._kb_self_service_rate`
- Tags: operations, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
DIVIDE (
    CALCULATE (
        DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
        NOT ISBLANK ( IncidentsAllFields[kbarticleid] )
            || NOT ISBLANK ( IncidentsAllFields[kbarticleidname] )
    ),
    [_CountIncidents],
    0
) * 100
```

## IncidentsAllFields[_Recurring_Issue_Ratio]

- ID: `incidentsallfields._recurring_issue_ratio`
- Tags: operations, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
DIVIDE (
    CALCULATE (
        DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
        IncidentsAllFields[pdw_findsimilarincidentkb] = TRUE ()
    ),
    [_CountIncidents],
    0
) * 100
```

## IncidentsAllFields[_Agent_Skill_Gap]

- ID: `incidentsallfields._agent_skill_gap`
- Tags: operations, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
DIVIDE([_AVG TTS], AVERAGEX(VALUES(IncidentsAllFields[ownerid]), [_AVG TTS]), 1)
```

## IncidentsAllFields[_Agent_Burnout_Risk]

- ID: `incidentsallfields._agent_burnout_risk`
- Tags: operations
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
MIN(([_Avg_Cases_Per_Agent] / 10 * 50) + ([_Escalation_Rate] * 30) + ([_Team_Stress_Index] * 20), 100)
```

## IncidentsAllFields[_Agents_Needing_Training]

- ID: `incidentsallfields._agents_needing_training`
- Tags: operations
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
COUNTROWS (
    FILTER (
        VALUES ( IncidentsAllFields[owneridname] ),
        NOT ISBLANK ( IncidentsAllFields[owneridname] )
            && [_Agent_Skill_Gap] >= 1.2
            && [_Agent_Burnout_Risk] >= 60
    )
)
```

## IncidentsAllFields[_Agent_Performance_Rank]

- ID: `incidentsallfields._agent_performance_rank`
- Tags: operations, customer, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
RANKX (
    VALUES ( IncidentsAllFields[owneridname] ),
    DIVIDE (
        [_FirstContactResolutionRate_FCR],
        AVERAGE ( IncidentsAllFields[prioritycode] ) + 1,
        0
    )
)
```

## IncidentsAllFields[_Queue_Wait_Time_Days]

- ID: `incidentsallfields._queue_wait_time_days`
- Tags: operations, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
DIVIDE ( [_AVGCase Age Hours], 24, 0 )
```

## IncidentsAllFields[_Optimal_Assignment_Ratio]

- ID: `incidentsallfields._optimal_assignment_ratio`
- Tags: customer, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
DIVIDE([_FirstContactResolutionRate_FCR], 0.95, 0) * 100
```

## IncidentsAllFields[_Handoff_Success_Rate]

- ID: `incidentsallfields._handoff_success_rate`
- Tags: operations, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
DIVIDE (
    CALCULATE (
        DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
        IncidentsAllFields[isescalated] = FALSE ()
    ),
    [_CountIncidents],
    0
) * 100
```

## IncidentsAllFields[_Ticket_Rework_Rate]

- ID: `incidentsallfields._ticket_rework_rate`
- Tags: operations, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
DIVIDE (
    CALCULATE (
        DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
        IncidentsAllFields[merged] = TRUE ()
    ),
    [_CountIncidents],
    0
) * 100
```

## IncidentsAllFields[_Cost_Per_Resolution]

- ID: `incidentsallfields._cost_per_resolution`
- Tags: finance
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
([_AVG TTS] / 60) * 50
```

## IncidentsAllFields[_Revenue_Impact_VIP_Score]

- ID: `incidentsallfields._revenue_impact_vip_score`
- Tags: operations, customer, finance
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
SUMX(SUMMARIZE(IncidentsAllFields, IncidentsAllFields[contactid], "IsVIP", IF(DISTINCTCOUNT(IncidentsAllFields[incidentid]) > 5, 1, 0)), IF([IsVIP] = 1, [_Customer_Lifetime_Value] * 2, [_Customer_Lifetime_Value]))
```

## IncidentsAllFields[_SLA_ROI]

- ID: `incidentsallfields._sla_roi`
- Tags: sla, operations, finance, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
DIVIDE([_SLA_Compliance], [_Cost_Per_Resolution] * [_CountIncidents], 0.01)
```

## IncidentsAllFields[_Support_Efficiency_Index]

- ID: `incidentsallfields._support_efficiency_index`
- Tags: sla, customer, finance, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
DIVIDE(([_FirstContactResolutionRate_FCR] * 50 + [_SLA_Compliance] * 50), MAX(1, [_Cost_Per_Resolution] / 100), 1)
```

## IncidentsAllFields[_Holiday_Impact_Index]

- ID: `incidentsallfields._holiday_impact_index`
- Tags: operations, time-intelligence, ratio
- Risk level: review
- Risks: determinism: volatile date/time
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
IF(MONTH(TODAY()) = 12 OR MONTH(TODAY()) = 1 OR MONTH(TODAY()) = 8, DIVIDE([_CountIncidents], AVERAGEX(VALUES(Calendar[Monat]), [_CountIncidents]), 1), 1)
```

## IncidentsAllFields[_Peak_Business_Hours_Concentration]

- ID: `incidentsallfields._peak_business_hours_concentration`
- Tags: operations, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
DIVIDE (
    CALCULATE (
        DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
        HOUR ( IncidentsAllFields[createdon] ) >= 8,
        HOUR ( IncidentsAllFields[createdon] ) < 18
    ),
    [_CountIncidents],
    0
) * 100
```

## IncidentsAllFields[_Trend_Acceleration_Rate]

- ID: `incidentsallfields._trend_acceleration_rate`
- Tags: operations, time-intelligence
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
([_CountIncidents] - CALCULATE([_CountIncidents], DATEADD(Calendar[Date], -7, DAY))) / MAX(1, CALCULATE([_CountIncidents], DATEADD(Calendar[Date], -7, DAY)))
```

## IncidentsAllFields[_Cyclical_Pattern_Detected]

- ID: `incidentsallfields._cyclical_pattern_detected`
- Tags: time-intelligence
- Risk level: review
- Risks: determinism: volatile date/time
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
IF(MOD(DAY(TODAY()), 7) = 1, "Weekly-Pattern", IF(MOD(DAY(TODAY()), 14) = 1, "BiWeekly-Pattern", "No-Pattern"))
```

## IncidentsAllFields[_Executive_Health_Score]

- ID: `incidentsallfields._executive_health_score`
- Tags: sla, customer
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
MIN((([_SLA_Compliance] + [_FirstContactResolutionRate_FCR] * 100 + 100 - [_Team_Stress_Index]) / 3), 100)
```

## IncidentsAllFields[_Service_Quality_Index]

- ID: `incidentsallfields._service_quality_index`
- Tags: sla, customer
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
([_FirstContactResolutionRate_FCR] * 60 + [_SLA_Compliance] * 40)
```

## IncidentsAllFields[_Team_Productivity_Index]

- ID: `incidentsallfields._team_productivity_index`
- Tags: operations
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
([_Ticket_Velocity] / 10 * 100) / [_Avg_Cases_Per_Agent]
```

## IncidentsAllFields[_Customer_Sentiment_Score]

- ID: `incidentsallfields._customer_sentiment_score`
- Tags: customer
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
[_CSAT_Score] * 0.5 + (100 - [_Churn_Risk_Indicator] * 100) * 0.5
```

## IncidentsAllFields[_Service_Health_Status]

- ID: `incidentsallfields._service_health_status`
- Tags: uncategorized
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
IF([_Executive_Health_Score] > 80, "Excellent", IF([_Executive_Health_Score] > 65, "Good", IF([_Executive_Health_Score] > 50, "Warning", "Critical")))
```

## IncidentsAllFields[_Critical_Alerts_Count]

- ID: `incidentsallfields._critical_alerts_count`
- Tags: sla, customer
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
(IF([_SLA_Compliance] < 80, 1, 0)) + (IF([_Team_Stress_Index] > 70, 1, 0)) + (IF([_CSAT_Score] < 75, 1, 0)) + (IF([_Churn_Risk_Indicator] > 20, 1, 0))
```

## IncidentsAllFields[_Weekly_Service_Risk]

- ID: `incidentsallfields._weekly_service_risk`
- Tags: operations, time-intelligence
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
[_Trend_Acceleration_Rate] * [_Anomaly_High_Resolution_Time] / MAX(1, [_CountIncidents]) * 100
```

## IncidentsAllFields[_Performance_Trend_Signal]

- ID: `incidentsallfields._performance_trend_signal`
- Tags: uncategorized
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
IF([_Trend_Acceleration_Rate] < -0.05, "Improving", IF([_Trend_Acceleration_Rate] > 0.05, "Declining", "Stable"))
```

## IncidentsAllFields[_FCR_Improvement_Opportunity]

- ID: `incidentsallfields._fcr_improvement_opportunity`
- Tags: operations, customer
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
[_CountIncidents] * (1 - [_FirstContactResolutionRate_FCR])
```

## IncidentsAllFields[_SLA_Improvement_Opportunity]

- ID: `incidentsallfields._sla_improvement_opportunity`
- Tags: sla, operations
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
[_CountIncidents] * (1 - [_SLA_Compliance] / 100)
```

## IncidentsAllFields[_Effort_Reduction_Opportunity]

- ID: `incidentsallfields._effort_reduction_opportunity`
- Tags: operations
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
([_Ticket_Rework_Rate] / 100 * [_CountIncidents] * [_AVG TTS] / 24) + ([_Escalation_Rate] / 100 * [_CountIncidents] * 8)
```

## IncidentsAllFields[_Cost_Savings_Potential]

- ID: `incidentsallfields._cost_savings_potential`
- Tags: sla, finance
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
([_FCR_Improvement_Opportunity] + [_SLA_Improvement_Opportunity]) * [_Cost_Per_Resolution]
```

## IncidentsAllFields[_Industry_Benchmark_Index]

- ID: `incidentsallfields._industry_benchmark_index`
- Tags: sla, customer, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
DIVIDE(([_AVG TTS] / 24) * 0.3 + [_FirstContactResolutionRate_FCR] * 0.4 + [_SLA_Compliance] * 0.3, 75, 1)
```

## IncidentsAllFields[_Performance_Percentile_Rank]

- ID: `incidentsallfields._performance_percentile_rank`
- Tags: sla, customer
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
INT((([_SLA_Compliance] + [_FirstContactResolutionRate_FCR] * 100) / 2) * 1.1)
```

## IncidentsAllFields[_Custom_SLA_Variance]

- ID: `incidentsallfields._custom_sla_variance`
- Tags: sla
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
[_SLA_Compliance] - 80
```

## IncidentsAllFields[_Agent_Fair_Performance_Rank]

- ID: `incidentsallfields._agent_fair_performance_rank`
- Tags: operations, customer, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
RANKX (
    VALUES ( IncidentsAllFields[owneridname] ),
    DIVIDE (
        [_FirstContactResolutionRate_FCR] * [_AVG TTS],
        ( AVERAGE ( IncidentsAllFields[prioritycode] ) + 1 ) * 100,
        0
    )
)
```

## IncidentsAllFields[_Volume_Forecast_12Weeks]

- ID: `incidentsallfields._volume_forecast_12weeks`
- Tags: time-intelligence
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
[_Volume_Forecast_4Weeks] * 3 * (1 + [_Seasonality_Index] / 2)
```

## IncidentsAllFields[_Capacity_Simulation_SLA_Improvement]

- ID: `incidentsallfields._capacity_simulation_sla_improvement`
- Tags: sla
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
[_SLA_Compliance] * 1.15 + ([_Team_Stress_Index] * -0.08)
```

## IncidentsAllFields[_Escalation_Prevention_ROI]

- ID: `incidentsallfields._escalation_prevention_roi`
- Tags: operations, finance
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
([_Escalated_Tickets_Count] * [_Cost_Per_Resolution] * 1.5) - ([_Escalated_Tickets_Count] * 50)
```

## IncidentsAllFields[_Ticket_Type_TTR_Prediction]

- ID: `incidentsallfields._ticket_type_ttr_prediction`
- Tags: operations, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
VAR ProblemTickets =
    CALCULATE (
        DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
        CONTAINSSTRING ( IncidentsAllFields[casetypecodename], "Problem" )
    )
RETURN
[_AVG TTS] * ( 1 + DIVIDE ( ProblemTickets, [_CountIncidents], 0 ) )
```

## IncidentsAllFields[_Customer_Cluster_Segment]

- ID: `incidentsallfields._customer_cluster_segment`
- Tags: customer
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
IF([_Customer_Lifetime_Value] > 1000 && [_Churn_Risk_Indicator] < 15, "VIP", IF([_Customer_Lifetime_Value] > 500, "Premium", "Standard"))
```

## IncidentsAllFields[_Customer_Profitability_Index]

- ID: `incidentsallfields._customer_profitability_index`
- Tags: operations, customer, finance, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
DIVIDE([_Customer_Lifetime_Value] * 1.2, [_Cost_Per_Resolution] * [_Repeat_Incidents_Customer], 0)
```

## IncidentsAllFields[_Individual_Churn_Propensity]

- ID: `incidentsallfields._individual_churn_propensity`
- Tags: customer
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
MIN(([_Churn_Risk_Indicator] * 1.5 + [_Customer_Effort_Score] * 20), 100)
```

## IncidentsAllFields[_Customer_Engagement_Quality]

- ID: `incidentsallfields._customer_engagement_quality`
- Tags: customer
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
(100 - [_Queue_Wait_Time_Days] * 10) * ([_FirstContactResolutionRate_FCR] + 1) / 2
```

## IncidentsAllFields[_SLA_Breach_Factor_Analysis]

- ID: `incidentsallfields._sla_breach_factor_analysis`
- Tags: sla, operations, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
DIVIDE (
    [_SLA_Breach_Count],
    [_CountIncidents] * ( 1 + AVERAGE ( IncidentsAllFields[prioritycode] ) ),
    0
)
```

## IncidentsAllFields[_Root_Cause_Correlation_Score]

- ID: `incidentsallfields._root_cause_correlation_score`
- Tags: operations, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
VAR HighPriorityShare =
    DIVIDE (
        CALCULATE (
            DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
            IncidentsAllFields[prioritycode] > 2
        ),
        [_CountIncidents],
        0
    )
VAR ProblemShare =
    DIVIDE (
        CALCULATE (
            DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
            CONTAINSSTRING ( IncidentsAllFields[casetypecodename], "Problem" )
        ),
        [_CountIncidents],
        0
    )
RETURN
INT ( HighPriorityShare * 40 + ProblemShare * 35 + [_Escalation_Rate] * 25 )
```

## IncidentsAllFields[_Problem_Pattern_Concentration]

- ID: `incidentsallfields._problem_pattern_concentration`
- Tags: operations
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
IF([_Top_Problem_Categories_Pareto] / [_CountIncidents] > 0.7, "High Concentration (Fixable)", "Diverse Issues (Complex)")
```

## IncidentsAllFields[_Seasonal_Root_Cause_Variance]

- ID: `incidentsallfields._seasonal_root_cause_variance`
- Tags: operations, time-intelligence, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
VAR MonthlyCounts =
    ADDCOLUMNS ( VALUES ( 'Calendar'[JahrMonat] ), "__IncidentCount", [_CountIncidents] )
RETURN
DIVIDE (
    STDEVX.P ( MonthlyCounts, [__IncidentCount] ),
    AVERAGEX ( MonthlyCounts, [__IncidentCount] ),
    0
) * 100
```

## IncidentsAllFields[_Customer_Total_Cost_Ownership]

- ID: `incidentsallfields._customer_total_cost_ownership`
- Tags: operations, customer, finance
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
[_Cost_Per_Resolution] * 1.3 + ([_Repeat_Incidents_Customer] * 20)
```

## IncidentsAllFields[_Service_Profitability_Ratio]

- ID: `incidentsallfields._service_profitability_ratio`
- Tags: operations, finance, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
DIVIDE([_Revenue_Impact_VIP_Score] * 1.5, [_Cost_Per_Resolution] * [_Avg_Cases_Per_Agent], 0)
```

## IncidentsAllFields[_Cost_Avoidance_Prevention]

- ID: `incidentsallfields._cost_avoidance_prevention`
- Tags: operations, finance
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
([_KB_Self_Service_Rate] * 0.01 * [_CountIncidents] * [_Cost_Per_Resolution] * 0.7)
```

## IncidentsAllFields[_Break_Even_SLA_Improvement]

- ID: `incidentsallfields._break_even_sla_improvement`
- Tags: sla, finance
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
INT((([_Cost_Savings_Potential] / 10000) / [_SLA_Compliance] * 100))
```

## IncidentsAllFields[_SLA_Achievement_Trajectory]

- ID: `incidentsallfields._sla_achievement_trajectory`
- Tags: sla, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
DIVIDE([_SLA_Compliance], 100, 0) * (1 - ([_Potential_SLA_Breach_24h] / 100))
```

## IncidentsAllFields[_Compliance_Audit_Ready_Index]

- ID: `incidentsallfields._compliance_audit_ready_index`
- Tags: sla, customer
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
MIN((([_Data_Quality_Score] + [_SLA_Compliance] + [_FirstContactResolutionRate_FCR] * 100) / 3 + [_Root_Cause_Identification_Rate] * 0.5), 100)
```

## IncidentsAllFields[_First_Response_Compliance]

- ID: `incidentsallfields._first_response_compliance`
- Tags: sla, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
DIVIDE([_First_Response_SLA_Met], [_SLA_Compliance], 0) * 100
```

## IncidentsAllFields[_Documentation_Completeness]

- ID: `incidentsallfields._documentation_completeness`
- Tags: uncategorized
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
(100 - ([_Missing_Description_Rate] + [_Missing_Resolution_Notes_Rate]) / 2)
```

## IncidentsAllFields[_Channel_Performance_Email]

- ID: `incidentsallfields._channel_performance_email`
- Tags: operations, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
DIVIDE (
    CALCULATE (
        DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
        CONTAINSSTRING ( IncidentsAllFields[caseorigincodename], "Email" )
    ),
    CALCULATE (
        DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
        NOT ISBLANK ( IncidentsAllFields[caseorigincodename] )
    ),
    0
) * 100
```

## IncidentsAllFields[_Multi_Touch_Channel_Attribution]

- ID: `incidentsallfields._multi_touch_channel_attribution`
- Tags: operations, customer, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
DIVIDE (
    [_FirstContactResolutionRate_FCR],
    AVERAGE ( IncidentsAllFields[caseorigincode] ) + 1,
    0
) * 100
```

## IncidentsAllFields[_Preferred_Channel_Detection]

- ID: `incidentsallfields._preferred_channel_detection`
- Tags: operations
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
VAR PhoneCount =
    CALCULATE (
        DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
        CONTAINSSTRING ( IncidentsAllFields[caseorigincodename], "Phone" )
    )
VAR EmailCount =
    CALCULATE (
        DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
        CONTAINSSTRING ( IncidentsAllFields[caseorigincodename], "Email" )
    )
RETURN
IF ( PhoneCount > EmailCount, "Phone", "Email" )
```

## IncidentsAllFields[_Channel_CSAT_Differential]

- ID: `incidentsallfields._channel_csat_differential`
- Tags: operations, customer, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
[_CSAT_Score]
    * DIVIDE (
        CALCULATE (
            DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
            CONTAINSSTRING ( IncidentsAllFields[customersatisfactioncodename], "Satisfied" )
        ),
        [_CountIncidents],
        0
    )
```

## IncidentsAllFields[_Agent_Idle_Time_Hours]

- ID: `incidentsallfields._agent_idle_time_hours`
- Tags: operations, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
DIVIDE([_AVG TTS], [_Avg_Cases_Per_Agent], 0) * 24 - 1
```

## IncidentsAllFields[_KB_Usage_Effectiveness]

- ID: `incidentsallfields._kb_usage_effectiveness`
- Tags: uncategorized
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
[_KB_Self_Service_Rate]
```

## IncidentsAllFields[_Macro_Script_Utilization_Level]

- ID: `incidentsallfields._macro_script_utilization_level`
- Tags: operations
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
IF([_Ticket_Velocity] > 5, "High Automation", IF([_Ticket_Velocity] > 2, "Medium Automation", "Low Automation"))
```

## IncidentsAllFields[_Context_Switching_Cost]

- ID: `incidentsallfields._context_switching_cost`
- Tags: operations, finance, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
DIVIDE (
    CALCULATE (
        DISTINCTCOUNT ( IncidentsAllFields[casetypecodename] ),
        NOT ISBLANK ( IncidentsAllFields[casetypecodename] )
    ),
    [_Avg_Cases_Per_Agent],
    0
) * 5
```

## IncidentsAllFields[_Individual_SLA_Breach_Risk]

- ID: `incidentsallfields._individual_sla_breach_risk`
- Tags: sla
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
([_Potential_SLA_Breach_24h] + [_Agent_Burnout_Risk] / 2)
```

## IncidentsAllFields[_Data_Privacy_Compliance]

- ID: `incidentsallfields._data_privacy_compliance`
- Tags: sla, operations, customer, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
VAR MissingContactShare =
    DIVIDE (
        CALCULATE (
            DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
            ISBLANK ( IncidentsAllFields[contactidname] )
        ),
        [_CountIncidents],
        0
    )
RETURN
MAX (
    0,
    MIN ( ( 1 - [_Missing_Description_Rate] / 100 - MissingContactShare * 0.5 ) * 100, 100 )
)
```

## IncidentsAllFields[_Escalation_Authority_Compliance]

- ID: `incidentsallfields._escalation_authority_compliance`
- Tags: sla, operations, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
DIVIDE (
    [_Escalated_Tickets_Count],
    CALCULATE (
        DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
        IncidentsAllFields[isescalated] = TRUE ()
    ),
    0
) * 100
```

## IncidentsAllFields[_SLA_Violation_Severity_Index]

- ID: `incidentsallfields._sla_violation_severity_index`
- Tags: sla, operations, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
MIN (
    DIVIDE ( [_SLA_Breach_Count], [_CountIncidents], 0 ) * 100
        * ( 1 + DIVIDE ( [_AVG TTS] - [_Median_Resolution_Hours], [_Median_Resolution_Hours], 0 ) ),
    100
)
```

## IncidentsAllFields[_Quarter_Performance_Trend]

- ID: `incidentsallfields._quarter_performance_trend`
- Tags: sla, customer, time-intelligence
- Risk level: review
- Risks: determinism: volatile date/time
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
([_SLA_Compliance] + [_FirstContactResolutionRate_FCR] * 100) / 2 * POWER(1.05, INT(MONTH(TODAY()) / 3))
```

## IncidentsAllFields[_Best_Practice_Position]

- ID: `incidentsallfields._best_practice_position`
- Tags: uncategorized
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
IF([_Performance_Percentile_Rank] > 90, "Top 10% Performer", IF([_Performance_Percentile_Rank] > 70, "Above Average", IF([_Performance_Percentile_Rank] > 40, "Average", "Below Average")))
```

## IncidentsAllFields[_Hidden_Cost_Poor_Service]

- ID: `incidentsallfields._hidden_cost_poor_service`
- Tags: sla, customer, finance
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
([_Churn_Risk_Indicator] / 100 * [_Revenue_Impact_VIP_Score]) + ([_SLA_Compliance] * -0.5)
```

## IncidentsAllFields[_Improvement_Efficiency_ROI]

- ID: `incidentsallfields._improvement_efficiency_roi`
- Tags: finance, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
IF([_Cost_Savings_Potential] > 0, DIVIDE([_Cost_Savings_Potential], 10000, 0), 0)
```

## IncidentsAllFields[_SumUsedHours]

- ID: `incidentsallfields._sumusedhours`
- Tags: operations
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
sum(IncidentsAllFields[pdw_usedhours])
```

## IncidentsAllFields[_SRA_Open Critical Tickets]

- ID: `incidentsallfields._sra_open-critical-tickets`
- Tags: operations
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
COUNTROWS (
    FILTER (
        VALUES ( IncidentsAllFields[incidentid] ),
        [_SRA_Ticket Risk Band] = "Critical"
    )
)
```

## IncidentsAllFields[_SRA_Action Required Tickets]

- ID: `incidentsallfields._sra_action-required-tickets`
- Tags: operations
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
COUNTROWS (
    FILTER (
        VALUES ( IncidentsAllFields[incidentid] ),
        [_SRA_Ticket Risk Band] IN { "Action Required", "Critical" }
    )
)
```

## IncidentsAllFields[_SRA_Tickets Without Owner]

- ID: `incidentsallfields._sra_tickets-without-owner`
- Tags: operations
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
CALCULATE (
    DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
    ISBLANK ( IncidentsAllFields[owneridname] )
        || IncidentsAllFields[owneridname] = "",
    NOT ( IncidentsAllFields[statuscodename] IN { "Behoben", "Abgeschlossen", "Closed" } )
)
```

## IncidentsAllFields[_SRA_SLA Due Next 24h]

- ID: `incidentsallfields._sra_sla-due-next-24h`
- Tags: sla, operations
- Risk level: review
- Risks: determinism: volatile date/time
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
CALCULATE (
    DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
    NOT ISBLANK ( IncidentsAllFields[resolveby] ),
    IncidentsAllFields[resolveby] >= NOW (),
    IncidentsAllFields[resolveby] <= NOW () + 1,
    NOT ( IncidentsAllFields[statuscodename] IN { "Behoben", "Abgeschlossen", "Closed" } )
)
```

## IncidentsAllFields[_SRA_Overdue Open Tickets]

- ID: `incidentsallfields._sra_overdue-open-tickets`
- Tags: operations
- Risk level: review
- Risks: determinism: volatile date/time
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
CALCULATE (
    DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
    NOT ISBLANK ( IncidentsAllFields[resolveby] ),
    IncidentsAllFields[resolveby] < NOW (),
    NOT ( IncidentsAllFields[statuscodename] IN { "Behoben", "Abgeschlossen", "Closed" } )
)
```

## IncidentsAllFields[_SRA_Ticket Risk Score]

- ID: `incidentsallfields._sra_ticket-risk-score`
- Tags: sla, operations
- Risk level: review
- Risks: determinism: volatile date/time; maintainability: long expression
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
VAR IsClosed =
    SELECTEDVALUE ( IncidentsAllFields[statuscodename] ) IN { "Behoben", "Abgeschlossen", "Closed" }
VAR PriorityCode =
    SELECTEDVALUE ( IncidentsAllFields[prioritycode], 0 )
VAR PriorityName =
    SELECTEDVALUE ( IncidentsAllFields[pdw_priority_codename], "" )
VAR PriorityRisk =
    SWITCH (
        TRUE (),
        CONTAINSSTRING ( PriorityName, "Critical" ) || CONTAINSSTRING ( PriorityName, "High" ) || PriorityCode >= 3, 20,
        PriorityCode = 2, 10,
        0
    )
VAR ResolveBy =
    SELECTEDVALUE ( IncidentsAllFields[resolveby] )
VAR SlaRisk =
    SWITCH (
        TRUE (),
        IsClosed, 0,
        ISBLANK ( ResolveBy ), 10,
        ResolveBy < NOW (), 30,
        ResolveBy <= NOW () + 1, 25,
        ResolveBy <= NOW () + 2, 15,
        0
    )
VAR OwnerRisk =
    IF (
        IsClosed,
        0,
        IF (
            ISBLANK ( SELECTEDVALUE ( IncidentsAllFields[owneridname] ) )
                || SELECTEDVALUE ( IncidentsAllFields[owneridname] ) = "",
            15,
            0
        )
    )
VAR AgeMinutes =
    SELECTEDVALUE ( IncidentsAllFields[caseage], 0 )
VAR AgeRisk =
    SWITCH (
        TRUE (),
        IsClosed, 0,
        AgeMinutes >= 10080, 15,
        AgeMinutes >= 4320, 10,
        AgeMinutes >= 1440, 5,
        0
    )
VAR EscalationRisk =
    IF ( SELECTEDVALUE ( IncidentsAllFields[isescalated], FALSE () ), 10, 0 )
VAR FirstResponseRisk =
    IF (
        IsClosed,
        0,
        IF ( SELECTEDVALUE ( IncidentsAllFields[firstresponsesent], FALSE () ), 0, 10 )
    )
RETURN
MIN ( 100, PriorityRisk + SlaRisk + OwnerRisk + AgeRisk + EscalationRisk + FirstResponseRisk )
```

## IncidentsAllFields[_SRA_Ticket Risk Band]

- ID: `incidentsallfields._sra_ticket-risk-band`
- Tags: operations
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
VAR Score = [_SRA_Ticket Risk Score]
RETURN
SWITCH (
    TRUE (),
    Score >= 75, "Critical",
    Score >= 50, "Action Required",
    Score >= 25, "Watch",
    "Low Risk"
)
```

## IncidentsAllFields[_SRA_Ticket Recommended Action]

- ID: `incidentsallfields._sra_ticket-recommended-action`
- Tags: sla, operations
- Risk level: review
- Risks: determinism: volatile date/time; maintainability: long expression
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
VAR IsClosed =
    SELECTEDVALUE ( IncidentsAllFields[statuscodename] ) IN { "Behoben", "Abgeschlossen", "Closed" }
VAR ResolveBy =
    SELECTEDVALUE ( IncidentsAllFields[resolveby] )
VAR MissingOwner =
    ISBLANK ( SELECTEDVALUE ( IncidentsAllFields[owneridname] ) )
        || SELECTEDVALUE ( IncidentsAllFields[owneridname] ) = ""
VAR NoFirstResponse =
    NOT SELECTEDVALUE ( IncidentsAllFields[firstresponsesent], FALSE () )
VAR IsEscalated =
    SELECTEDVALUE ( IncidentsAllFields[isescalated], FALSE () )
VAR Score = [_SRA_Ticket Risk Score]
RETURN
SWITCH (
    TRUE (),
    IsClosed, "No action - closed",
    MissingOwner, "Assign owner",
    NOT ISBLANK ( ResolveBy ) && ResolveBy < NOW (), "Resolve overdue SLA",
    NOT ISBLANK ( ResolveBy ) && ResolveBy <= NOW () + 1, "Prioritize before SLA breach",
    NoFirstResponse, "Send first response",
    IsEscalated, "Review escalation path",
    Score >= 50, "Review and prioritize",
    "Monitor"
)
```

## IncidentsAllFields[_SRA_Average Risk Score]

- ID: `incidentsallfields._sra_average-risk-score`
- Tags: operations
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
AVERAGEX (
    VALUES ( IncidentsAllFields[incidentid] ),
    [_SRA_Ticket Risk Score]
)
```

## IncidentsAllFields[_SRA_Critical Share]

- ID: `incidentsallfields._sra_critical-share`
- Tags: operations, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
DIVIDE ( [_SRA_Open Critical Tickets], [_Open_Incidents], 0 )
```

## IncidentsAllFields[_SRA_Action Queue Size]

- ID: `incidentsallfields._sra_action-queue-size`
- Tags: operations
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
COUNTROWS (
    FILTER (
        VALUES ( IncidentsAllFields[incidentid] ),
        [_SRA_Ticket Risk Band] IN { "Action Required", "Critical" }
            || [_SRA_Ticket Recommended Action] <> "Monitor"
            && [_SRA_Ticket Recommended Action] <> "No action - closed"
    )
)
```

## IncidentsAllFields[_SRA_Watch Tickets]

- ID: `incidentsallfields._sra_watch-tickets`
- Tags: operations
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
COUNTROWS (
    FILTER (
        VALUES ( IncidentsAllFields[incidentid] ),
        [_SRA_Ticket Risk Band] = "Watch"
    )
)
```

## IncidentsAllFields[_SRA_Low Risk Tickets]

- ID: `incidentsallfields._sra_low-risk-tickets`
- Tags: operations
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
COUNTROWS (
    FILTER (
        VALUES ( IncidentsAllFields[incidentid] ),
        [_SRA_Ticket Risk Band] = "Low Risk"
    )
)
```

## IncidentsAllFields[_SRA_Critical Or Action Share]

- ID: `incidentsallfields._sra_critical-or-action-share`
- Tags: operations, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
DIVIDE ( [_SRA_Action Required Tickets], [_Open_Incidents], 0 )
```

## IncidentsAllFields[_SRA_Service Health Score]

- ID: `incidentsallfields._sra_service-health-score`
- Tags: operations, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
VAR AvgRiskPenalty =
    [_SRA_Average Risk Score] * 0.45
VAR CriticalPenalty =
    [_SRA_Critical Share] * 100 * 0.25
VAR OverduePenalty =
    DIVIDE ( [_SRA_Overdue Open Tickets], [_Open_Incidents], 0 ) * 100 * 0.20
VAR UnassignedPenalty =
    DIVIDE ( [_SRA_Tickets Without Owner], [_Open_Incidents], 0 ) * 100 * 0.10
RETURN
MAX ( 0, MIN ( 100, 100 - AvgRiskPenalty - CriticalPenalty - OverduePenalty - UnassignedPenalty ) )
```

## IncidentsAllFields[_SRA_Service Health Status]

- ID: `incidentsallfields._sra_service-health-status`
- Tags: uncategorized
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
VAR Score = [_SRA_Service Health Score]
RETURN
SWITCH (
    TRUE (),
    Score >= 85, "Healthy",
    Score >= 70, "Stable",
    Score >= 50, "At Risk",
    "Critical"
)
```

## IncidentsAllFields[_SRA_SLA Exposure Share]

- ID: `incidentsallfields._sra_sla-exposure-share`
- Tags: sla, operations, ratio
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
DIVIDE (
    [_SRA_Overdue Open Tickets] + [_SRA_SLA Due Next 24h],
    [_Open_Incidents],
    0
)
```

## IncidentsAllFields[_SRA_Owner Load Risk Score]

- ID: `incidentsallfields._sra_owner-load-risk-score`
- Tags: operations
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
AVERAGEX (
    VALUES ( IncidentsAllFields[incidentid] ),
    [_SRA_Ticket Risk Score]
)
```

## IncidentsAllFields[_SRA_Top Risk Owner]

- ID: `incidentsallfields._sra_top-risk-owner`
- Tags: operations
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
VAR OwnerScores =
    ADDCOLUMNS (
        FILTER (
            VALUES ( IncidentsAllFields[owneridname] ),
            NOT ISBLANK ( IncidentsAllFields[owneridname] )
                && IncidentsAllFields[owneridname] <> ""
        ),
        "__Risk", [_SRA_Owner Load Risk Score],
        "__Tickets", [_CountIncidents]
    )
VAR TopOwner =
    TOPN ( 1, OwnerScores, [__Risk], DESC, [__Tickets], DESC, IncidentsAllFields[owneridname], ASC )
RETURN
CONCATENATEX ( TopOwner, IncidentsAllFields[owneridname] )
```

## IncidentsAllFields[_SRA_Top Risk Customer]

- ID: `incidentsallfields._sra_top-risk-customer`
- Tags: operations, customer
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
VAR CustomerScores =
    ADDCOLUMNS (
        FILTER (
            VALUES ( IncidentsAllFields[contactidname] ),
            NOT ISBLANK ( IncidentsAllFields[contactidname] )
                && IncidentsAllFields[contactidname] <> ""
        ),
        "__Risk", [_SRA_Average Risk Score],
        "__Tickets", [_CountIncidents]
    )
VAR TopCustomer =
    TOPN ( 1, CustomerScores, [__Risk], DESC, [__Tickets], DESC, IncidentsAllFields[contactidname], ASC )
RETURN
CONCATENATEX ( TopCustomer, IncidentsAllFields[contactidname] )
```

## IncidentsAllFields[_SRA_Next Best Action Summary]

- ID: `incidentsallfields._sra_next-best-action-summary`
- Tags: sla, operations
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
VAR Health = [_SRA_Service Health Status]
VAR QueueSize = [_SRA_Action Queue Size]
VAR CriticalTickets = [_SRA_Open Critical Tickets]
VAR DueSoon = [_SRA_SLA Due Next 24h]
VAR Overdue = [_SRA_Overdue Open Tickets]
RETURN
Health
    & " | Queue: " & FORMAT ( QueueSize, "#,0" )
    & " | Critical: " & FORMAT ( CriticalTickets, "#,0" )
    & " | Overdue: " & FORMAT ( Overdue, "#,0" )
    & " | Due 24h: " & FORMAT ( DueSoon, "#,0" )
```

## IncidentsAllFields[_SRA_Risk Band Sort]

- ID: `incidentsallfields._sra_risk-band-sort`
- Tags: operations
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
SWITCH (
    [_SRA_Ticket Risk Band],
    "Critical", 4,
    "Action Required", 3,
    "Watch", 2,
    "Low Risk", 1,
    0
)
```

## IncidentsAllFields[_SRA_Assign Owner Tickets]

- ID: `incidentsallfields._sra_assign-owner-tickets`
- Tags: operations
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
CALCULATE (
    DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
    IncidentsAllFields[SRA Action Board Lane] = "1 Assign Owner"
)
```

## IncidentsAllFields[_SRA_Resolve Overdue SLA Tickets]

- ID: `incidentsallfields._sra_resolve-overdue-sla-tickets`
- Tags: sla, operations
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
CALCULATE (
    DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
    IncidentsAllFields[SRA Action Board Lane] = "2 Resolve Overdue SLA"
)
```

## IncidentsAllFields[_SRA_Prioritize SLA Risk Tickets]

- ID: `incidentsallfields._sra_prioritize-sla-risk-tickets`
- Tags: sla, operations
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
CALCULATE (
    DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
    IncidentsAllFields[SRA Action Board Lane] = "3 Prioritize SLA Risk"
)
```

## IncidentsAllFields[_SRA_Send First Response Tickets]

- ID: `incidentsallfields._sra_send-first-response-tickets`
- Tags: operations
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
CALCULATE (
    DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
    IncidentsAllFields[SRA Action Board Lane] = "4 Send First Response"
)
```

## IncidentsAllFields[_SRA_Review Escalation Tickets]

- ID: `incidentsallfields._sra_review-escalation-tickets`
- Tags: operations
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
CALCULATE (
    DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
    IncidentsAllFields[SRA Action Board Lane] = "5 Review Escalation"
)
```

## IncidentsAllFields[_SRA_Multi Driver Tickets]

- ID: `incidentsallfields._sra_multi-driver-tickets`
- Tags: operations
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
CALCULATE (
    DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
    IncidentsAllFields[SRA Driver Count] >= 3
)
```

## IncidentsAllFields[_SRA_Average Driver Count]

- ID: `incidentsallfields._sra_average-driver-count`
- Tags: operations
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
AVERAGE ( IncidentsAllFields[SRA Driver Count] )
```

## IncidentsAllFields[_SRA_Top Driver Theme]

- ID: `incidentsallfields._sra_top-driver-theme`
- Tags: sla, operations
- Risk level: review
- Risks: maintainability: long expression
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
VAR MissingFirstResponse =
    CALCULATE (
        DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
        CONTAINSSTRING ( IncidentsAllFields[SRA Risk Drivers], "Missing first response" )
    )
VAR MissingSla =
    CALCULATE (
        DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
        CONTAINSSTRING ( IncidentsAllFields[SRA Risk Drivers], "Missing SLA due date" )
    )
VAR OverdueSla =
    CALCULATE (
        DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
        CONTAINSSTRING ( IncidentsAllFields[SRA Risk Drivers], "Overdue SLA" )
    )
VAR NoOwner =
    CALCULATE (
        DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
        CONTAINSSTRING ( IncidentsAllFields[SRA Risk Drivers], "No owner assigned" )
    )
VAR OldTickets =
    CALCULATE (
        DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
        CONTAINSSTRING ( IncidentsAllFields[SRA Risk Drivers], "Age >" )
    )
VAR Themes =
    {
        ( "Missing first response", MissingFirstResponse ),
        ( "Missing SLA due date", MissingSla ),
        ( "Overdue SLA", OverdueSla ),
        ( "No owner assigned", NoOwner ),
        ( "Aging tickets", OldTickets )
    }
VAR TopTheme =
    TOPN ( 1, Themes, [Value2], DESC, [Value1], ASC )
RETURN
CONCATENATEX ( TopTheme, [Value1] )
```

## IncidentsAllFields[_SRA_Action Board Summary]

- ID: `incidentsallfields._sra_action-board-summary`
- Tags: sla, operations
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
"Assign: " & FORMAT ( [_SRA_Assign Owner Tickets], "#,0" )
    & " | Overdue: " & FORMAT ( [_SRA_Resolve Overdue SLA Tickets], "#,0" )
    & " | SLA risk: " & FORMAT ( [_SRA_Prioritize SLA Risk Tickets], "#,0" )
    & " | First response: " & FORMAT ( [_SRA_Send First Response Tickets], "#,0" )
    & " | Escalation: " & FORMAT ( [_SRA_Review Escalation Tickets], "#,0" )
```

## TimeSheet[_DurationTicket]

- ID: `timesheet._durationticket`
- Tags: operations
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
sum(TimeSheet[pdw_duration])/60
```

## TimeSheet[_CountDescription]

- ID: `timesheet._countdescription`
- Tags: uncategorized
- Risk level: normal
- Owner: [TODO: metric owner]
- Business definition: [TODO: business definition]

```DAX
COUNT(TimeSheet[description])
```



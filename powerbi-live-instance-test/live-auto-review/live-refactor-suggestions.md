# Power BI Live Refactor Suggestions

Suggestions: 15

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

## [Medium] _Holiday_Impact_Index
- Table: IncidentsAllFields
- Risk: determinism: volatile date/time
- Suggested action: Replace volatile TODAY/NOW logic with a governed refresh-date measure, model parameter, or date table filter.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

```DAX
IF(MONTH(TODAY()) = 12 OR MONTH(TODAY()) = 1 OR MONTH(TODAY()) = 8, DIVIDE([_CountIncidents], AVERAGEX(VALUES(Calendar[Monat]), [_CountIncidents]), 1), 1)
```

## [Medium] _Cyclical_Pattern_Detected
- Table: IncidentsAllFields
- Risk: determinism: volatile date/time
- Suggested action: Replace volatile TODAY/NOW logic with a governed refresh-date measure, model parameter, or date table filter.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

```DAX
IF(MOD(DAY(TODAY()), 7) = 1, "Weekly-Pattern", IF(MOD(DAY(TODAY()), 14) = 1, "BiWeekly-Pattern", "No-Pattern"))
```

## [Medium] _Quarter_Performance_Trend
- Table: IncidentsAllFields
- Risk: determinism: volatile date/time
- Suggested action: Replace volatile TODAY/NOW logic with a governed refresh-date measure, model parameter, or date table filter.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

```DAX
([_SLA_Compliance] + [_FirstContactResolutionRate_FCR] * 100) / 2 * POWER(1.05, INT(MONTH(TODAY()) / 3))
```

## [Medium] _SRA_SLA Due Next 24h
- Table: IncidentsAllFields
- Risk: determinism: volatile date/time
- Suggested action: Replace volatile TODAY/NOW logic with a governed refresh-date measure, model parameter, or date table filter.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

```DAX
CALCULATE (
    DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
    NOT ISBLANK ( IncidentsAllFields[resolveby] ),
    IncidentsAllFields[resolveby] >= NOW (),
    IncidentsAllFields[resolveby] <= NOW () + 1,
    NOT ( IncidentsAllFields[statuscodename] IN { "Behoben", "Abgeschlossen", "Closed" } )
)
```

## [Medium] _SRA_Overdue Open Tickets
- Table: IncidentsAllFields
- Risk: determinism: volatile date/time
- Suggested action: Replace volatile TODAY/NOW logic with a governed refresh-date measure, model parameter, or date table filter.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

```DAX
CALCULATE (
    DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
    NOT ISBLANK ( IncidentsAllFields[resolveby] ),
    IncidentsAllFields[resolveby] < NOW (),
    NOT ( IncidentsAllFields[statuscodename] IN { "Behoben", "Abgeschlossen", "Closed" } )
)
```

## [Medium] _SRA_Ticket Risk Score
- Table: IncidentsAllFields
- Risk: determinism: volatile date/time
- Suggested action: Replace volatile TODAY/NOW logic with a governed refresh-date measure, model parameter, or date table filter.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

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

## [Medium] _SRA_Ticket Risk Score
- Table: IncidentsAllFields
- Risk: maintainability: long expression
- Suggested action: Extract reusable business logic into helper measures and add comments/description.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

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

## [Medium] _SRA_Ticket Recommended Action
- Table: IncidentsAllFields
- Risk: determinism: volatile date/time
- Suggested action: Replace volatile TODAY/NOW logic with a governed refresh-date measure, model parameter, or date table filter.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

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

## [Medium] _SRA_Ticket Recommended Action
- Table: IncidentsAllFields
- Risk: maintainability: long expression
- Suggested action: Extract reusable business logic into helper measures and add comments/description.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

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

## [Medium] _SRA_Top Driver Theme
- Table: IncidentsAllFields
- Risk: maintainability: long expression
- Suggested action: Extract reusable business logic into helper measures and add comments/description.
- Validation: Validate the measure in Power BI Desktop, compare against accepted totals, and check dependent measures before publishing.

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



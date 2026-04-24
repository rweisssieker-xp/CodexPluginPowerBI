$ErrorActionPreference = 'Stop'

$serverName = 'localhost:63952'
$assemblyPath = 'C:\Program Files\Tabular Editor 3\Microsoft.AnalysisServices.Tabular.dll'
$backupPath = Join-Path $PSScriptRoot ("incidentsallfields-measure-backup-{0}.json" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))

Add-Type -Path $assemblyPath

$server = [Microsoft.AnalysisServices.Tabular.Server]::new()
$server.Connect($serverName)

try {
    $database = $server.Databases[0]
    $model = $database.Model
    $table = $model.Tables['IncidentsAllFields']
    if ($null -eq $table) {
        throw "Table 'IncidentsAllFields' was not found."
    }

    $fixes = [ordered]@{
        '_SLA_Compliance' = @'
VAR TotalIncidents = [_CountIncidents]
VAR BreachCount = [_SLA_Conflict]
RETURN
MAX ( 0, 1 - DIVIDE ( BreachCount, TotalIncidents, 0 ) )
'@
        '_Escalation_Rate' = @'
DIVIDE (
    CALCULATE (
        DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
        IncidentsAllFields[isescalated] = TRUE ()
    ),
    [_CountIncidents],
    0
)
'@
        '_Ticket_Velocity' = @'
VAR MinDate =
    CALCULATE ( MIN ( 'Calendar'[Date] ), ALL ( 'Calendar' ) )
VAR MaxDate =
    CALCULATE ( MAX ( 'Calendar'[Date] ), ALL ( 'Calendar' ) )
VAR WeeksInCalendar =
    MAX ( 1, DATEDIFF ( MinDate, MaxDate, WEEK ) + 1 )
RETURN
DIVIDE ( [_CountIncidents], WeeksInCalendar, 0 )
'@
        '_Resolution_Time_StdDev' = @'
STDEV.P ( IncidentsAllFields[pdw_totalresolutiontime_duration] )
'@
        '_Peak_Month_Volume' = @'
MAXX ( VALUES ( 'Calendar'[JahrMonat] ), [_CountIncidents] )
'@
        '_Low_Month_Volume' = @'
MINX ( VALUES ( 'Calendar'[JahrMonat] ), [_CountIncidents] )
'@
        '_CSAT_Score' = @'
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
'@
        '_Top_Problem_Categories_Pareto' = @'
CALCULATE (
    DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
    CONTAINSSTRING ( IncidentsAllFields[casetypecodename], "Problem" )
) * 0.2
'@
        '_Root_Cause_Identification_Rate' = @'
DIVIDE (
    CALCULATE (
        DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
        CONTAINSSTRING ( IncidentsAllFields[description], "Root Cause" )
    ),
    [_CountIncidents],
    0
) * 100
'@
        '_KB_Self_Service_Rate' = @'
DIVIDE (
    CALCULATE (
        DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
        NOT ISBLANK ( IncidentsAllFields[kbarticleid] )
            || NOT ISBLANK ( IncidentsAllFields[kbarticleidname] )
    ),
    [_CountIncidents],
    0
) * 100
'@
        '_Recurring_Issue_Ratio' = @'
DIVIDE (
    CALCULATE (
        DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
        IncidentsAllFields[pdw_findsimilarincidentkb] = TRUE ()
    ),
    [_CountIncidents],
    0
) * 100
'@
        '_Agents_Needing_Training' = @'
COUNTROWS (
    FILTER (
        VALUES ( IncidentsAllFields[owneridname] ),
        NOT ISBLANK ( IncidentsAllFields[owneridname] )
            && [_Agent_Skill_Gap] >= 1.2
            && [_Agent_Burnout_Risk] >= 60
    )
)
'@
        '_Agent_Performance_Rank' = @'
RANKX (
    VALUES ( IncidentsAllFields[owneridname] ),
    DIVIDE (
        [_FirstContactResolutionRate_FCR],
        AVERAGE ( IncidentsAllFields[prioritycode] ) + 1,
        0
    )
)
'@
        '_Queue_Wait_Time_Days' = @'
DIVIDE ( [_AVGCase Age Hours], 24, 0 )
'@
        '_Handoff_Success_Rate' = @'
DIVIDE (
    CALCULATE (
        DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
        IncidentsAllFields[isescalated] = FALSE ()
    ),
    [_CountIncidents],
    0
) * 100
'@
        '_Ticket_Rework_Rate' = @'
DIVIDE (
    CALCULATE (
        DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
        IncidentsAllFields[merged] = TRUE ()
    ),
    [_CountIncidents],
    0
) * 100
'@
        '_Peak_Business_Hours_Concentration' = @'
DIVIDE (
    CALCULATE (
        DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
        HOUR ( IncidentsAllFields[createdon] ) >= 8,
        HOUR ( IncidentsAllFields[createdon] ) < 18
    ),
    [_CountIncidents],
    0
) * 100
'@
        '_Agent_Fair_Performance_Rank' = @'
RANKX (
    VALUES ( IncidentsAllFields[owneridname] ),
    DIVIDE (
        [_FirstContactResolutionRate_FCR] * [_AVG TTS],
        ( AVERAGE ( IncidentsAllFields[prioritycode] ) + 1 ) * 100,
        0
    )
)
'@
        '_Ticket_Type_TTR_Prediction' = @'
VAR ProblemTickets =
    CALCULATE (
        DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
        CONTAINSSTRING ( IncidentsAllFields[casetypecodename], "Problem" )
    )
RETURN
[_AVG TTS] * ( 1 + DIVIDE ( ProblemTickets, [_CountIncidents], 0 ) )
'@
        '_SLA_Breach_Factor_Analysis' = @'
DIVIDE (
    [_SLA_Breach_Count],
    [_CountIncidents] * ( 1 + AVERAGE ( IncidentsAllFields[prioritycode] ) ),
    0
)
'@
        '_Root_Cause_Correlation_Score' = @'
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
'@
        '_Seasonal_Root_Cause_Variance' = @'
VAR MonthlyCounts =
    ADDCOLUMNS ( VALUES ( 'Calendar'[JahrMonat] ), "__IncidentCount", [_CountIncidents] )
RETURN
DIVIDE (
    STDEVX.P ( MonthlyCounts, [__IncidentCount] ),
    AVERAGEX ( MonthlyCounts, [__IncidentCount] ),
    0
) * 100
'@
        '_Channel_Performance_Email' = @'
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
'@
        '_Multi_Touch_Channel_Attribution' = @'
DIVIDE (
    [_FirstContactResolutionRate_FCR],
    AVERAGE ( IncidentsAllFields[caseorigincode] ) + 1,
    0
) * 100
'@
        '_Preferred_Channel_Detection' = @'
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
'@
        '_Channel_CSAT_Differential' = @'
[_CSAT_Score]
    * DIVIDE (
        CALCULATE (
            DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
            CONTAINSSTRING ( IncidentsAllFields[customersatisfactioncodename], "Satisfied" )
        ),
        [_CountIncidents],
        0
    )
'@
        '_Context_Switching_Cost' = @'
DIVIDE (
    CALCULATE (
        DISTINCTCOUNT ( IncidentsAllFields[casetypecodename] ),
        NOT ISBLANK ( IncidentsAllFields[casetypecodename] )
    ),
    [_Avg_Cases_Per_Agent],
    0
) * 5
'@
        '_Data_Privacy_Compliance' = @'
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
'@
        '_Escalation_Authority_Compliance' = @'
DIVIDE (
    [_Escalated_Tickets_Count],
    CALCULATE (
        DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
        IncidentsAllFields[isescalated] = TRUE ()
    ),
    0
) * 100
'@
        '_SLA_Violation_Severity_Index' = @'
MIN (
    DIVIDE ( [_SLA_Breach_Count], [_CountIncidents], 0 ) * 100
        * ( 1 + DIVIDE ( [_AVG TTS] - [_Median_Resolution_Hours], [_Median_Resolution_Hours], 0 ) ),
    100
)
'@
    }

    $backup = foreach ($name in $fixes.Keys) {
        $measure = $table.Measures[$name]
        if ($null -ne $measure) {
            [pscustomobject]@{
                Table = $table.Name
                Name = $measure.Name
                OriginalExpression = $measure.Expression
            }
        }
    }
    $backup | ConvertTo-Json -Depth 5 | Set-Content -Path $backupPath -Encoding UTF8

    $changed = New-Object System.Collections.Generic.List[string]
    foreach ($name in $fixes.Keys) {
        $measure = $table.Measures[$name]
        if ($null -eq $measure) {
            Write-Warning "Measure '$name' was not found; skipping."
            continue
        }
        $measure.Expression = $fixes[$name].Trim()
        $changed.Add($name)
    }

    $model.SaveChanges()

    [pscustomobject]@{
        Server = $serverName
        Database = $database.Name
        BackupPath = $backupPath
        ChangedMeasures = $changed.Count
        Measures = ($changed -join ', ')
    } | Format-List
}
finally {
    $server.Disconnect()
}

$ErrorActionPreference = 'Stop'

$serverName = 'localhost:63952'
$assemblyPath = 'C:\Program Files\Tabular Editor 3\Microsoft.AnalysisServices.Tabular.dll'

Add-Type -Path $assemblyPath

$server = [Microsoft.AnalysisServices.Tabular.Server]::new()
$server.Connect($serverName)

function Set-Measure {
    param(
        [Parameter(Mandatory)] $Table,
        [Parameter(Mandatory)] [string] $Name,
        [Parameter(Mandatory)] [string] $Expression,
        [string] $Description,
        [string] $FormatString
    )

    $measure = $Table.Measures[$Name]
    if ($null -eq $measure) {
        $measure = [Microsoft.AnalysisServices.Tabular.Measure]::new()
        $measure.Name = $Name
        $Table.Measures.Add($measure)
        $measure.Expression = $Expression.Trim()
    }
    else {
        $measure.Expression = $Expression.Trim()
    }

    if ($Description) { $measure.Description = $Description }
    if ($FormatString) { $measure.FormatString = $FormatString }
    return $measure
}

try {
    $database = $server.Databases[0]
    $model = $database.Model
    $table = $model.Tables['IncidentsAllFields']
    if ($null -eq $table) {
        throw "Table 'IncidentsAllFields' was not found."
    }

    $measures = @(
        @{
            Name = '_SRA_Open Critical Tickets'
            Format = '#,0'
            Description = 'Open tickets classified as Critical by the Service Risk Assistant.'
            Expression = @'
COUNTROWS (
    FILTER (
        VALUES ( IncidentsAllFields[incidentid] ),
        [_SRA_Ticket Risk Band] = "Critical"
    )
)
'@
        },
        @{
            Name = '_SRA_Action Required Tickets'
            Format = '#,0'
            Description = 'Open tickets classified as Action Required or Critical by the Service Risk Assistant.'
            Expression = @'
COUNTROWS (
    FILTER (
        VALUES ( IncidentsAllFields[incidentid] ),
        [_SRA_Ticket Risk Band] IN { "Action Required", "Critical" }
    )
)
'@
        },
        @{
            Name = '_SRA_Tickets Without Owner'
            Format = '#,0'
            Description = 'Open tickets that do not have an owner name assigned.'
            Expression = @'
CALCULATE (
    DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
    ISBLANK ( IncidentsAllFields[owneridname] )
        || IncidentsAllFields[owneridname] = "",
    NOT ( IncidentsAllFields[statuscodename] IN { "Behoben", "Abgeschlossen", "Closed" } )
)
'@
        },
        @{
            Name = '_SRA_SLA Due Next 24h'
            Format = '#,0'
            Description = 'Open tickets whose resolve-by timestamp is within the next 24 hours.'
            Expression = @'
CALCULATE (
    DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
    NOT ISBLANK ( IncidentsAllFields[resolveby] ),
    IncidentsAllFields[resolveby] >= NOW (),
    IncidentsAllFields[resolveby] <= NOW () + 1,
    NOT ( IncidentsAllFields[statuscodename] IN { "Behoben", "Abgeschlossen", "Closed" } )
)
'@
        },
        @{
            Name = '_SRA_Overdue Open Tickets'
            Format = '#,0'
            Description = 'Open tickets whose resolve-by timestamp is already in the past.'
            Expression = @'
CALCULATE (
    DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
    NOT ISBLANK ( IncidentsAllFields[resolveby] ),
    IncidentsAllFields[resolveby] < NOW (),
    NOT ( IncidentsAllFields[statuscodename] IN { "Behoben", "Abgeschlossen", "Closed" } )
)
'@
        },
        @{
            Name = '_SRA_Ticket Risk Score'
            Format = '0'
            Description = '0-100 ticket-level risk score based on status, SLA deadline, priority, ownership, age, escalation and first response.'
            Expression = @'
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
'@
        },
        @{
            Name = '_SRA_Ticket Risk Band'
            Description = 'Text classification for the Service Risk Assistant ticket risk score.'
            Expression = @'
VAR Score = [_SRA_Ticket Risk Score]
RETURN
SWITCH (
    TRUE (),
    Score >= 75, "Critical",
    Score >= 50, "Action Required",
    Score >= 25, "Watch",
    "Low Risk"
)
'@
        },
        @{
            Name = '_SRA_Ticket Recommended Action'
            Description = 'Recommended operational action for the currently selected ticket.'
            Expression = @'
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
'@
        },
        @{
            Name = '_SRA_Average Risk Score'
            Format = '0.0'
            Description = 'Average Service Risk Assistant score across tickets in the current filter context.'
            Expression = @'
AVERAGEX (
    VALUES ( IncidentsAllFields[incidentid] ),
    [_SRA_Ticket Risk Score]
)
'@
        },
        @{
            Name = '_SRA_Critical Share'
            Format = '0.0%'
            Description = 'Share of tickets classified as Critical in the current filter context.'
            Expression = @'
DIVIDE ( [_SRA_Open Critical Tickets], [_Open_Incidents], 0 )
'@
        },
        @{
            Name = '_SRA_Action Queue Size'
            Format = '#,0'
            Description = 'Operational action queue size: critical/action-required tickets, overdue tickets, due-next-24h tickets and unassigned tickets de-duplicated at ticket level.'
            Expression = @'
COUNTROWS (
    FILTER (
        VALUES ( IncidentsAllFields[incidentid] ),
        [_SRA_Ticket Risk Band] IN { "Action Required", "Critical" }
            || [_SRA_Ticket Recommended Action] <> "Monitor"
            && [_SRA_Ticket Recommended Action] <> "No action - closed"
    )
)
'@
        }
    )

    foreach ($definition in $measures) {
        Set-Measure `
            -Table $table `
            -Name $definition.Name `
            -Expression $definition.Expression `
            -Description $definition.Description `
            -FormatString $definition.Format | Out-Null
    }

    $model.SaveChanges()

    [pscustomobject]@{
        Server = $serverName
        Database = $database.Name
        AddedOrUpdatedMeasures = $measures.Count
        Measures = (($measures | ForEach-Object { $_.Name }) -join ', ')
    } | Format-List
}
finally {
    $server.Disconnect()
}

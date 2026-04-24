$ErrorActionPreference = 'Stop'

$serverName = 'localhost:63952'
$assemblyPath = 'C:\Program Files\Tabular Editor 3\Microsoft.AnalysisServices.Tabular.dll'

Add-Type -Path $assemblyPath

$server = [Microsoft.AnalysisServices.Tabular.Server]::new()
$server.Connect($serverName)

function Set-CalculatedColumn {
    param(
        [Parameter(Mandatory)] $Table,
        [Parameter(Mandatory)] [string] $Name,
        [Parameter(Mandatory)] [string] $Expression,
        [Parameter(Mandatory)] $DataType,
        [string] $Description,
        [string] $FormatString
    )

    $column = $Table.Columns[$Name]
    if ($null -eq $column) {
        $column = [Microsoft.AnalysisServices.Tabular.CalculatedColumn]::new()
        $column.Name = $Name
        $Table.Columns.Add($column)
    }

    $column.Expression = $Expression.Trim()
    $column.DataType = $DataType
    if ($Description) { $column.Description = $Description }
    if ($FormatString) { $column.FormatString = $FormatString }
}

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
    }

    $measure.Expression = $Expression.Trim()
    if ($Description) { $measure.Description = $Description }
    if ($FormatString) { $measure.FormatString = $FormatString }
}

try {
    $database = $server.Databases[0]
    $model = $database.Model
    $table = $model.Tables['IncidentsAllFields']
    if ($null -eq $table) {
        throw "Table 'IncidentsAllFields' was not found."
    }

    Set-CalculatedColumn `
        -Table $table `
        -Name 'SRA Risk Drivers' `
        -DataType ([Microsoft.AnalysisServices.Tabular.DataType]::String) `
        -Description 'Human-readable explanation of the factors driving the row-level Service Risk Assistant score.' `
        -Expression @'
VAR IsClosed =
    IncidentsAllFields[statuscodename] IN { "Behoben", "Abgeschlossen", "Closed" }
VAR PriorityCode =
    COALESCE ( IncidentsAllFields[prioritycode], 0 )
VAR PriorityName =
    COALESCE ( IncidentsAllFields[pdw_priority_codename], "" )
VAR PriorityDriver =
    IF (
        CONTAINSSTRING ( PriorityName, "Critical" )
            || CONTAINSSTRING ( PriorityName, "High" )
            || PriorityCode >= 3,
        "High priority; ",
        ""
    )
VAR ResolveBy = IncidentsAllFields[resolveby]
VAR SlaDriver =
    SWITCH (
        TRUE (),
        IsClosed, "",
        ISBLANK ( ResolveBy ), "Missing SLA due date; ",
        ResolveBy < NOW (), "Overdue SLA; ",
        ResolveBy <= NOW () + 1, "SLA due within 24h; ",
        ResolveBy <= NOW () + 2, "SLA due within 48h; ",
        ""
    )
VAR OwnerDriver =
    IF (
        NOT IsClosed
            && ( ISBLANK ( IncidentsAllFields[owneridname] ) || IncidentsAllFields[owneridname] = "" ),
        "No owner assigned; ",
        ""
    )
VAR AgeMinutes =
    COALESCE ( IncidentsAllFields[caseage], 0 )
VAR AgeDriver =
    SWITCH (
        TRUE (),
        IsClosed, "",
        AgeMinutes >= 10080, "Age > 7 days; ",
        AgeMinutes >= 4320, "Age > 3 days; ",
        AgeMinutes >= 1440, "Age > 1 day; ",
        ""
    )
VAR EscalationDriver =
    IF ( IncidentsAllFields[isescalated], "Escalated; ", "" )
VAR FirstResponseDriver =
    IF (
        NOT IsClosed && NOT IncidentsAllFields[firstresponsesent],
        "Missing first response; ",
        ""
    )
VAR Drivers =
    PriorityDriver & SlaDriver & OwnerDriver & AgeDriver & EscalationDriver & FirstResponseDriver
RETURN
IF ( Drivers = "", "No material risk drivers", LEFT ( Drivers, LEN ( Drivers ) - 2 ) )
'@

    Set-CalculatedColumn `
        -Table $table `
        -Name 'SRA Driver Count' `
        -DataType ([Microsoft.AnalysisServices.Tabular.DataType]::Int64) `
        -FormatString '0' `
        -Description 'Number of active Service Risk Assistant risk drivers on the ticket.' `
        -Expression @'
VAR IsClosed =
    IncidentsAllFields[statuscodename] IN { "Behoben", "Abgeschlossen", "Closed" }
VAR PriorityCode =
    COALESCE ( IncidentsAllFields[prioritycode], 0 )
VAR PriorityName =
    COALESCE ( IncidentsAllFields[pdw_priority_codename], "" )
VAR PriorityDriver =
    IF (
        CONTAINSSTRING ( PriorityName, "Critical" )
            || CONTAINSSTRING ( PriorityName, "High" )
            || PriorityCode >= 3,
        1,
        0
    )
VAR ResolveBy = IncidentsAllFields[resolveby]
VAR SlaDriver =
    IF ( NOT IsClosed && ( ISBLANK ( ResolveBy ) || ResolveBy <= NOW () + 2 ), 1, 0 )
VAR OwnerDriver =
    IF (
        NOT IsClosed
            && ( ISBLANK ( IncidentsAllFields[owneridname] ) || IncidentsAllFields[owneridname] = "" ),
        1,
        0
    )
VAR AgeMinutes =
    COALESCE ( IncidentsAllFields[caseage], 0 )
VAR AgeDriver =
    IF ( NOT IsClosed && AgeMinutes >= 1440, 1, 0 )
VAR EscalationDriver =
    IF ( IncidentsAllFields[isescalated], 1, 0 )
VAR FirstResponseDriver =
    IF ( NOT IsClosed && NOT IncidentsAllFields[firstresponsesent], 1, 0 )
RETURN
PriorityDriver + SlaDriver + OwnerDriver + AgeDriver + EscalationDriver + FirstResponseDriver
'@

    Set-CalculatedColumn `
        -Table $table `
        -Name 'SRA Action Board Lane' `
        -DataType ([Microsoft.AnalysisServices.Tabular.DataType]::String) `
        -Description 'Board lane for operational next-best-action management.' `
        -Expression @'
VAR ActionText = IncidentsAllFields[SRA Recommended Action]
RETURN
SWITCH (
    TRUE (),
    ActionText = "Assign owner", "1 Assign Owner",
    ActionText = "Resolve overdue SLA", "2 Resolve Overdue SLA",
    ActionText = "Prioritize before SLA breach", "3 Prioritize SLA Risk",
    ActionText = "Send first response", "4 Send First Response",
    ActionText = "Review escalation path", "5 Review Escalation",
    ActionText = "Review and prioritize", "6 Review and Prioritize",
    ActionText = "Monitor", "7 Monitor",
    ActionText = "No action - closed", "8 Closed",
    "6 Review and Prioritize"
)
'@

    Set-CalculatedColumn `
        -Table $table `
        -Name 'SRA Action Board Lane Sort' `
        -DataType ([Microsoft.AnalysisServices.Tabular.DataType]::Int64) `
        -FormatString '0' `
        -Description 'Sort helper for SRA Action Board Lane.' `
        -Expression @'
SWITCH (
    IncidentsAllFields[SRA Action Board Lane],
    "1 Assign Owner", 1,
    "2 Resolve Overdue SLA", 2,
    "3 Prioritize SLA Risk", 3,
    "4 Send First Response", 4,
    "5 Review Escalation", 5,
    "6 Review and Prioritize", 6,
    "7 Monitor", 7,
    "8 Closed", 8,
    99
)
'@

    $measureDefinitions = @(
        @{
            Name = '_SRA_Assign Owner Tickets'
            Format = '#,0'
            Description = 'Tickets in the Assign Owner next-best-action lane.'
            Expression = @'
CALCULATE (
    DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
    IncidentsAllFields[SRA Action Board Lane] = "1 Assign Owner"
)
'@
        },
        @{
            Name = '_SRA_Resolve Overdue SLA Tickets'
            Format = '#,0'
            Description = 'Tickets in the Resolve Overdue SLA next-best-action lane.'
            Expression = @'
CALCULATE (
    DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
    IncidentsAllFields[SRA Action Board Lane] = "2 Resolve Overdue SLA"
)
'@
        },
        @{
            Name = '_SRA_Prioritize SLA Risk Tickets'
            Format = '#,0'
            Description = 'Tickets in the Prioritize SLA Risk next-best-action lane.'
            Expression = @'
CALCULATE (
    DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
    IncidentsAllFields[SRA Action Board Lane] = "3 Prioritize SLA Risk"
)
'@
        },
        @{
            Name = '_SRA_Send First Response Tickets'
            Format = '#,0'
            Description = 'Tickets in the Send First Response next-best-action lane.'
            Expression = @'
CALCULATE (
    DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
    IncidentsAllFields[SRA Action Board Lane] = "4 Send First Response"
)
'@
        },
        @{
            Name = '_SRA_Review Escalation Tickets'
            Format = '#,0'
            Description = 'Tickets in the Review Escalation next-best-action lane.'
            Expression = @'
CALCULATE (
    DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
    IncidentsAllFields[SRA Action Board Lane] = "5 Review Escalation"
)
'@
        },
        @{
            Name = '_SRA_Multi Driver Tickets'
            Format = '#,0'
            Description = 'Tickets with at least three active risk drivers.'
            Expression = @'
CALCULATE (
    DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
    IncidentsAllFields[SRA Driver Count] >= 3
)
'@
        },
        @{
            Name = '_SRA_Average Driver Count'
            Format = '0.0'
            Description = 'Average number of risk drivers per ticket in the current filter context.'
            Expression = @'
AVERAGE ( IncidentsAllFields[SRA Driver Count] )
'@
        },
        @{
            Name = '_SRA_Top Driver Theme'
            Description = 'Dominant risk-driver theme in the current filter context.'
            Expression = @'
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
'@
        },
        @{
            Name = '_SRA_Action Board Summary'
            Description = 'Compact summary of next-best-action board lane counts.'
            Expression = @'
"Assign: " & FORMAT ( [_SRA_Assign Owner Tickets], "#,0" )
    & " | Overdue: " & FORMAT ( [_SRA_Resolve Overdue SLA Tickets], "#,0" )
    & " | SLA risk: " & FORMAT ( [_SRA_Prioritize SLA Risk Tickets], "#,0" )
    & " | First response: " & FORMAT ( [_SRA_Send First Response Tickets], "#,0" )
    & " | Escalation: " & FORMAT ( [_SRA_Review Escalation Tickets], "#,0" )
'@
        }
    )

    foreach ($definition in $measureDefinitions) {
        Set-Measure `
            -Table $table `
            -Name $definition.Name `
            -Expression $definition.Expression `
            -Description $definition.Description `
            -FormatString $definition.Format
    }

    $model.SaveChanges()
    $model.RequestRefresh([Microsoft.AnalysisServices.Tabular.RefreshType]::Calculate)
    $model.SaveChanges()

    [pscustomobject]@{
        Server = $serverName
        Database = $database.Name
        AddedOrUpdatedColumns = 'SRA Risk Drivers, SRA Driver Count, SRA Action Board Lane, SRA Action Board Lane Sort'
        AddedOrUpdatedMeasures = ($measureDefinitions.Count)
        Measures = (($measureDefinitions | ForEach-Object { $_.Name }) -join ', ')
    } | Format-List
}
finally {
    $server.Disconnect()
}

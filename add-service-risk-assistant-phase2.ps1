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

    $measures = @(
        @{
            Name = '_SRA_Watch Tickets'
            Format = '#,0'
            Description = 'Open tickets classified as Watch by the Service Risk Assistant.'
            Expression = @'
COUNTROWS (
    FILTER (
        VALUES ( IncidentsAllFields[incidentid] ),
        [_SRA_Ticket Risk Band] = "Watch"
    )
)
'@
        },
        @{
            Name = '_SRA_Low Risk Tickets'
            Format = '#,0'
            Description = 'Open tickets classified as Low Risk by the Service Risk Assistant.'
            Expression = @'
COUNTROWS (
    FILTER (
        VALUES ( IncidentsAllFields[incidentid] ),
        [_SRA_Ticket Risk Band] = "Low Risk"
    )
)
'@
        },
        @{
            Name = '_SRA_Critical Or Action Share'
            Format = '0.0%'
            Description = 'Share of open tickets that require action or are critical.'
            Expression = @'
DIVIDE ( [_SRA_Action Required Tickets], [_Open_Incidents], 0 )
'@
        },
        @{
            Name = '_SRA_Service Health Score'
            Format = '0'
            Description = 'Executive 0-100 service health score. Higher is better; penalizes high average risk, critical share, overdue tickets and unassigned tickets.'
            Expression = @'
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
'@
        },
        @{
            Name = '_SRA_Service Health Status'
            Description = 'Text status for the Service Risk Assistant executive health score.'
            Expression = @'
VAR Score = [_SRA_Service Health Score]
RETURN
SWITCH (
    TRUE (),
    Score >= 85, "Healthy",
    Score >= 70, "Stable",
    Score >= 50, "At Risk",
    "Critical"
)
'@
        },
        @{
            Name = '_SRA_SLA Exposure Share'
            Format = '0.0%'
            Description = 'Share of open incidents that are overdue or due within the next 24 hours.'
            Expression = @'
DIVIDE (
    [_SRA_Overdue Open Tickets] + [_SRA_SLA Due Next 24h],
    [_Open_Incidents],
    0
)
'@
        },
        @{
            Name = '_SRA_Owner Load Risk Score'
            Format = '0.0'
            Description = 'Average ticket risk score for the owner in current filter context.'
            Expression = @'
AVERAGEX (
    VALUES ( IncidentsAllFields[incidentid] ),
    [_SRA_Ticket Risk Score]
)
'@
        },
        @{
            Name = '_SRA_Top Risk Owner'
            Description = 'Owner with the highest average ticket risk in the current filter context.'
            Expression = @'
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
'@
        },
        @{
            Name = '_SRA_Top Risk Customer'
            Description = 'Customer/contact with the highest average ticket risk in the current filter context.'
            Expression = @'
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
'@
        },
        @{
            Name = '_SRA_Next Best Action Summary'
            Description = 'Compact executive summary of the current service-risk state.'
            Expression = @'
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
'@
        },
        @{
            Name = '_SRA_Risk Band Sort'
            Format = '0'
            Description = 'Numeric sort helper for Service Risk Assistant risk bands.'
            Expression = @'
SWITCH (
    [_SRA_Ticket Risk Band],
    "Critical", 4,
    "Action Required", 3,
    "Watch", 2,
    "Low Risk", 1,
    0
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
            -FormatString $definition.Format
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

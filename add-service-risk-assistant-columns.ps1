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
        [string] $FormatString,
        [bool] $IsHidden = $false
    )

    $column = $Table.Columns[$Name]
    if ($null -eq $column) {
        $column = [Microsoft.AnalysisServices.Tabular.CalculatedColumn]::new()
        $column.Name = $Name
        $Table.Columns.Add($column)
    }

    $column.Expression = $Expression.Trim()
    $column.DataType = $DataType
    $column.IsHidden = $IsHidden
    if ($Description) { $column.Description = $Description }
    if ($FormatString) { $column.FormatString = $FormatString }
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
        -Name 'SRA Risk Score' `
        -DataType ([Microsoft.AnalysisServices.Tabular.DataType]::Int64) `
        -FormatString '0' `
        -Description 'Static row-level Service Risk Assistant score for ticket lists and sorting. Recalculated on refresh.' `
        -Expression @'
VAR IsClosed =
    IncidentsAllFields[statuscodename] IN { "Behoben", "Abgeschlossen", "Closed" }
VAR PriorityCode =
    COALESCE ( IncidentsAllFields[prioritycode], 0 )
VAR PriorityName =
    COALESCE ( IncidentsAllFields[pdw_priority_codename], "" )
VAR PriorityRisk =
    SWITCH (
        TRUE (),
        CONTAINSSTRING ( PriorityName, "Critical" ) || CONTAINSSTRING ( PriorityName, "High" ) || PriorityCode >= 3, 20,
        PriorityCode = 2, 10,
        0
    )
VAR ResolveBy = IncidentsAllFields[resolveby]
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
        IF ( ISBLANK ( IncidentsAllFields[owneridname] ) || IncidentsAllFields[owneridname] = "", 15, 0 )
    )
VAR AgeMinutes =
    COALESCE ( IncidentsAllFields[caseage], 0 )
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
    IF ( IncidentsAllFields[isescalated], 10, 0 )
VAR FirstResponseRisk =
    IF ( IsClosed, 0, IF ( IncidentsAllFields[firstresponsesent], 0, 10 ) )
RETURN
MIN ( 100, PriorityRisk + SlaRisk + OwnerRisk + AgeRisk + EscalationRisk + FirstResponseRisk )
'@

    Set-CalculatedColumn `
        -Table $table `
        -Name 'SRA Risk Band' `
        -DataType ([Microsoft.AnalysisServices.Tabular.DataType]::String) `
        -Description 'Static row-level Service Risk Assistant risk band for ticket lists and slicers. Recalculated on refresh.' `
        -Expression @'
VAR Score = IncidentsAllFields[SRA Risk Score]
RETURN
SWITCH (
    TRUE (),
    Score >= 75, "Critical",
    Score >= 50, "Action Required",
    Score >= 25, "Watch",
    "Low Risk"
)
'@

    Set-CalculatedColumn `
        -Table $table `
        -Name 'SRA Risk Band Sort' `
        -DataType ([Microsoft.AnalysisServices.Tabular.DataType]::Int64) `
        -FormatString '0' `
        -Description 'Sort helper for SRA Risk Band.' `
        -Expression @'
SWITCH (
    IncidentsAllFields[SRA Risk Band],
    "Critical", 4,
    "Action Required", 3,
    "Watch", 2,
    "Low Risk", 1,
    0
)
'@

    Set-CalculatedColumn `
        -Table $table `
        -Name 'SRA Recommended Action' `
        -DataType ([Microsoft.AnalysisServices.Tabular.DataType]::String) `
        -Description 'Static row-level next action for ticket action queues. Recalculated on refresh.' `
        -Expression @'
VAR IsClosed =
    IncidentsAllFields[statuscodename] IN { "Behoben", "Abgeschlossen", "Closed" }
VAR ResolveBy = IncidentsAllFields[resolveby]
VAR MissingOwner =
    ISBLANK ( IncidentsAllFields[owneridname] ) || IncidentsAllFields[owneridname] = ""
VAR NoFirstResponse =
    NOT IncidentsAllFields[firstresponsesent]
VAR IsEscalated =
    IncidentsAllFields[isescalated]
VAR Score = IncidentsAllFields[SRA Risk Score]
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

    $model.SaveChanges()

    [pscustomobject]@{
        Server = $serverName
        Database = $database.Name
        AddedOrUpdatedColumns = 'SRA Risk Score, SRA Risk Band, SRA Risk Band Sort, SRA Recommended Action'
    } | Format-List
}
finally {
    $server.Disconnect()
}

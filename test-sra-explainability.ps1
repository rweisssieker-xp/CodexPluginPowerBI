$ErrorActionPreference = 'Stop'

$serverName = 'Data Source=localhost:63952'
$queryScript = 'C:\Users\reinerw\.codex\plugins\cache\local-productivity-plugins\powerbi-desktop\1.2.0\scripts\Invoke-PowerBILiveDaxQuery.ps1'

$queries = @(
    @{
        Name = 'Action queue sample'
        Query = @'
EVALUATE
TOPN (
    10,
    SELECTCOLUMNS (
        IncidentsAllFields,
        "Incident", IncidentsAllFields[incidentid],
        "RiskScore", IncidentsAllFields[SRA Risk Score],
        "RiskBand", IncidentsAllFields[SRA Risk Band],
        "Drivers", IncidentsAllFields[SRA Risk Drivers],
        "DriverCount", IncidentsAllFields[SRA Driver Count],
        "Lane", IncidentsAllFields[SRA Action Board Lane],
        "Action", IncidentsAllFields[SRA Recommended Action],
        "Owner", IncidentsAllFields[owneridname]
    ),
    [RiskScore], DESC,
    [DriverCount], DESC
)
'@
    },
    @{
        Name = 'Action board measures'
        Query = @'
EVALUATE
ROW (
    "AssignOwner", [_SRA_Assign Owner Tickets],
    "OverdueSLA", [_SRA_Resolve Overdue SLA Tickets],
    "PrioritizeSLA", [_SRA_Prioritize SLA Risk Tickets],
    "FirstResponse", [_SRA_Send First Response Tickets],
    "ReviewEscalation", [_SRA_Review Escalation Tickets],
    "MultiDriver", [_SRA_Multi Driver Tickets],
    "AverageDriverCount", [_SRA_Average Driver Count],
    "TopDriverTheme", [_SRA_Top Driver Theme],
    "Summary", [_SRA_Action Board Summary]
)
'@
    }
)

foreach ($item in $queries) {
    Write-Host "## $($item.Name)"
    & $queryScript -Server $serverName -Query $item.Query -Json
}

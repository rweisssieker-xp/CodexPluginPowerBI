$ErrorActionPreference = 'Stop'

$serverName = 'localhost:63952'
$assemblyPath = 'C:\Program Files\Tabular Editor 3\Microsoft.AnalysisServices.Tabular.dll'
$backupPath = Join-Path $PSScriptRoot ("incidentsallfields-performance-measure-backup-{0}.json" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))

Add-Type -Path $assemblyPath

$server = [Microsoft.AnalysisServices.Tabular.Server]::new()
$server.Connect($serverName)

try {
    $database = $server.Databases[0]
    $table = $database.Model.Tables['IncidentsAllFields']
    if ($null -eq $table) {
        throw "Table 'IncidentsAllFields' was not found."
    }

    $fixes = [ordered]@{
        '_Repeat_Customer_Rate' = @'
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
'@
        '_Tickets_0_1Day' = @'
CALCULATE (
    DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
    KEEPFILTERS ( IncidentsAllFields[caseage] < 1440 )
)
'@
        '_Tickets_1_3Days' = @'
CALCULATE (
    DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
    KEEPFILTERS ( IncidentsAllFields[caseage] >= 1440 ),
    KEEPFILTERS ( IncidentsAllFields[caseage] < 4320 )
)
'@
        '_Tickets_3_7Days' = @'
CALCULATE (
    DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
    KEEPFILTERS ( IncidentsAllFields[caseage] >= 4320 ),
    KEEPFILTERS ( IncidentsAllFields[caseage] < 10080 )
)
'@
        '_Tickets_Over_7Days' = @'
CALCULATE (
    DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
    KEEPFILTERS ( IncidentsAllFields[caseage] >= 10080 )
)
'@
        '_Anomaly_High_Resolution_Time' = @'
VAR ThresholdMinutes = [_AVG TTS] * 2 * 60
RETURN
CALCULATE (
    DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
    FILTER (
        ALL ( IncidentsAllFields[pdw_totalresolutiontime_duration] ),
        IncidentsAllFields[pdw_totalresolutiontime_duration] > ThresholdMinutes
    )
)
'@
        '_Volume_vs_Baseline_Index' = @'
VAR BaselineMonthlyVolume =
    AVERAGEX ( ALL ( 'Calendar'[JahrMonat] ), [_CountIncidents] )
RETURN
DIVIDE ( [_CountIncidents], BaselineMonthlyVolume, 0 )
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

    $database.Model.SaveChanges()

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

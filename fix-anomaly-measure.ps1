$ErrorActionPreference = 'Stop'

Add-Type -Path 'C:\Program Files\Tabular Editor 3\Microsoft.AnalysisServices.Tabular.dll'

$server = [Microsoft.AnalysisServices.Tabular.Server]::new()
$server.Connect('localhost:63952')

try {
    $database = $server.Databases[0]
    $measure = $database.Model.Tables['IncidentsAllFields'].Measures['_Anomaly_High_Resolution_Time']
    $measure.Expression = @'
VAR ThresholdMinutes = [_AVG TTS] * 2 * 60
RETURN
CALCULATE (
    DISTINCTCOUNT ( IncidentsAllFields[incidentid] ),
    KEEPFILTERS ( IncidentsAllFields[pdw_totalresolutiontime_duration] > ThresholdMinutes )
)
'@.Trim()
    $database.Model.SaveChanges()
    $measure.Expression
}
finally {
    $server.Disconnect()
}

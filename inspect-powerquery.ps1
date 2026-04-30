Add-Type -Path 'C:\Program Files\DAX Studio\bin\Microsoft.AnalysisServices.Tabular.dll'

$server = [Microsoft.AnalysisServices.Tabular.Server]::new()
$server.Connect('localhost:57411')
try {
    $model = $server.Databases[0].Model
    foreach ($tableName in @('TimesheetLines', 'Resources', 'TimesheetLineActuals', 'Resource Demand')) {
        $table = $model.Tables.Find($tableName)
        if (-not $table) { continue }
        "===== TABLE: $tableName ====="
        foreach ($partition in $table.Partitions) {
            "Partition: $($partition.Name)"
            "Source Type: $($partition.Source.GetType().FullName)"
            $partition.Source | Format-List * | Out-String
        }
    }
}
finally {
    $server.Disconnect()
}

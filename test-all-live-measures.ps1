$ErrorActionPreference = 'Stop'

$serverName = 'localhost:63952'
$tomAssembly = 'C:\Program Files\Tabular Editor 3\Microsoft.AnalysisServices.Tabular.dll'
$queryScript = 'C:\Users\reinerw\.codex\plugins\cache\local-productivity-plugins\powerbi-desktop\1.2.0\scripts\Invoke-PowerBILiveDaxQuery.ps1'

Add-Type -Path $tomAssembly

$server = [Microsoft.AnalysisServices.Tabular.Server]::new()
$server.Connect($serverName)

try {
    $measures = foreach ($table in $server.Databases[0].Model.Tables) {
        foreach ($measure in $table.Measures) {
            [pscustomobject]@{
                Table = $table.Name
                Name = $measure.Name
            }
        }
    }
}
finally {
    $server.Disconnect()
}

$results = foreach ($measure in $measures) {
    $escapedName = $measure.Name.Replace(']', ']]')
    $label = ($measure.Table + ' - ' + $measure.Name).Replace('"', '""')
    $query = "EVALUATE ROW(""$label"", [$escapedName])"
    try {
        & $queryScript -Server $serverName -Query $query -Json | Out-Null
        [pscustomobject]@{
            Table = $measure.Table
            Name = $measure.Name
            Status = 'Passed'
            Error = $null
        }
    }
    catch {
        [pscustomobject]@{
            Table = $measure.Table
            Name = $measure.Name
            Status = 'Failed'
            Error = $_.Exception.Message
        }
    }
}

$results | ConvertTo-Json -Depth 5 | Set-Content -Path '.\powerbi-all-live-measure-validation.json' -Encoding UTF8
$results | Where-Object Status -eq 'Failed' | Format-Table -AutoSize
Write-Host ("Tested={0} Passed={1} Failed={2}" -f @($results).Count, @($results | Where-Object Status -eq 'Passed').Count, @($results | Where-Object Status -eq 'Failed').Count)

$ErrorActionPreference = 'Stop'

$serverName = 'localhost:63952'
$tomAssembly = 'C:\Program Files\Tabular Editor 3\Microsoft.AnalysisServices.Tabular.dll'
$queryScript = 'C:\Users\reinerw\.codex\plugins\cache\local-productivity-plugins\powerbi-desktop\1.2.0\scripts\Invoke-PowerBILiveDaxQuery.ps1'

Add-Type -Path $tomAssembly

$server = [Microsoft.AnalysisServices.Tabular.Server]::new()
$server.Connect($serverName)
try {
    $measures = @($server.Databases[0].Model.Tables['IncidentsAllFields'].Measures | Where-Object Name -like '_SRA_*' | ForEach-Object Name | Sort-Object)
}
finally {
    $server.Disconnect()
}

$results = foreach ($name in $measures) {
    $escapedName = $name.Replace(']', ']]')
    $label = $name.Replace('"', '""')
    $query = "EVALUATE ROW(""$label"", [$escapedName])"
    try {
        & $queryScript -Server $serverName -Query $query -Json | Out-Null
        [pscustomobject]@{ Name = $name; Status = 'Passed'; Error = $null }
    }
    catch {
        [pscustomobject]@{ Name = $name; Status = 'Failed'; Error = $_.Exception.Message }
    }
}

$results | Format-Table -AutoSize
Write-Host ("Tested={0} Passed={1} Failed={2}" -f @($results).Count, @($results | Where-Object Status -eq 'Passed').Count, @($results | Where-Object Status -eq 'Failed').Count)

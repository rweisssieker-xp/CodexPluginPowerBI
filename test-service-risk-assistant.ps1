$ErrorActionPreference = 'Stop'

$serverName = 'localhost:63952'
$queryScript = 'C:\Users\reinerw\.codex\plugins\cache\local-productivity-plugins\powerbi-desktop\1.2.0\scripts\Invoke-PowerBILiveDaxQuery.ps1'
$measures = @(
    '_SRA_Open Critical Tickets',
    '_SRA_Action Required Tickets',
    '_SRA_Tickets Without Owner',
    '_SRA_SLA Due Next 24h',
    '_SRA_Overdue Open Tickets',
    '_SRA_Ticket Risk Score',
    '_SRA_Ticket Risk Band',
    '_SRA_Ticket Recommended Action',
    '_SRA_Average Risk Score',
    '_SRA_Critical Share',
    '_SRA_Action Queue Size'
)

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

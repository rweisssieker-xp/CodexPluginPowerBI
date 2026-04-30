param(
    [string]$Path = ".",
    [string]$Server,
    [string]$OutputPath,
    [switch]$Json
)

$ErrorActionPreference = 'Stop'
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

$repo = & (Join-Path $scriptRoot 'New-PowerBIMetricCatalog.ps1') -Path $Path -Json | ConvertFrom-Json
$live = $null
$liveStatus = 'NotAvailable'
$liveDetail = ''
try {
    $live = & (Join-Path $scriptRoot 'New-PowerBILiveMetricCatalog.ps1') -Server $Server -Json | ConvertFrom-Json
    $liveStatus = 'Completed'
}
catch {
    $liveDetail = $_.Exception.Message
}

$differences = New-Object System.Collections.Generic.List[object]
if ($live) {
    $repoByName = @{}
    foreach ($m in @($repo.metrics)) { $repoByName[$m.name] = $m }
    $liveByName = @{}
    foreach ($m in @($live.metrics)) { $liveByName[$m.name] = $m }
    foreach ($name in $repoByName.Keys) {
        if (-not $liveByName.ContainsKey($name)) { $differences.Add([pscustomobject]@{ type = 'RepoOnlyMeasure'; measure = $name; risk = 'Medium'; detail = 'Measure exists in repo but not live Desktop model.' }) }
        elseif ($repoByName[$name].expression -ne $liveByName[$name].expression) { $differences.Add([pscustomobject]@{ type = 'ExpressionDrift'; measure = $name; risk = 'High'; detail = 'Measure expression differs between repo and live Desktop model.' }) }
    }
    foreach ($name in $liveByName.Keys) {
        if (-not $repoByName.ContainsKey($name)) { $differences.Add([pscustomobject]@{ type = 'LiveOnlyMeasure'; measure = $name; risk = 'High'; detail = 'Measure exists live but is not represented in repo/source control.' }) }
    }
}

$result = [pscustomobject]@{
    schema = 'codex.powerbi.liveRepoReconciliation.v1'
    generated = (Get-Date).ToString('s')
    repoPath = (Resolve-Path -LiteralPath $Path).Path
    liveStatus = $liveStatus
    liveDetail = $liveDetail
    repoMeasureCount = $repo.metricCount
    liveMeasureCount = if ($live) { $live.metricCount } else { $null }
    differenceCount = $differences.Count
    differences = @($differences.ToArray())
}

if ($Json) {
    $text = $result | ConvertTo-Json -Depth 8
    if ($OutputPath) { Set-Content -LiteralPath $OutputPath -Value $text -Encoding UTF8 }
    $text
    return
}

$md = @('# Power BI Live vs Repo Reconciliation', '', "Live status: $($result.liveStatus)", "Differences: $($result.differenceCount)", '') + @($result.differences | ForEach-Object { "- [$($_.risk)] $($_.type): `$($_.measure)` - $($_.detail)" })
$content = ($md -join [Environment]::NewLine) + [Environment]::NewLine
if ($OutputPath) { Set-Content -LiteralPath $OutputPath -Value $content -Encoding UTF8 }
$content

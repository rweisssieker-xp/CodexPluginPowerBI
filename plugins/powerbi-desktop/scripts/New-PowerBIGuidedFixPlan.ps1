param(
    [string]$Path = ".",
    [string]$OutputPath,
    [switch]$Json
)

$ErrorActionPreference = 'Stop'

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$scan = & (Join-Path $scriptRoot 'Invoke-PowerBIInsightScan.ps1') -Path $Path -Json | ConvertFrom-Json
$catalog = & (Join-Path $scriptRoot 'New-PowerBIMetricCatalog.ps1') -Path $Path -Json | ConvertFrom-Json
$impact = & (Join-Path $scriptRoot 'New-PowerBIMeasureLineageImpact.ps1') -Path $Path -Json | ConvertFrom-Json

$fixes = New-Object System.Collections.Generic.List[object]
foreach ($finding in @($scan.findings)) {
    $priority = if ($finding.severity -eq 'High') { 'P0' } elseif ($finding.severity -eq 'Medium') { 'P1' } else { 'P2' }
    $fixes.Add([pscustomobject]@{
        priority = $priority
        theme = $finding.category
        source = $finding.source
        problem = $finding.message
        guidedStep = 'Inspect the cited file or measure, apply the suggested rewrite, then rerun scan and measure tests.'
        validation = 'Run Invoke-PowerBIInsightScan.ps1 and New-PowerBIMeasureTestPlan.ps1 for the affected model.'
        status = 'Open'
    })
}
foreach ($metric in @($catalog.metrics | Where-Object { @($_.risks).Count -gt 0 })) {
    $impactItem = @($impact.measures | Where-Object { $_.name -eq $metric.name } | Select-Object -First 1)
    $priority = if ($impactItem.downstreamCount -gt 0 -or $metric.riskLevel -eq 'high') { 'P0' } else { 'P1' }
    $fixes.Add([pscustomobject]@{
        priority = $priority
        theme = 'DAX Refactoring'
        source = $metric.name
        problem = (@($metric.risks) -join '; ')
        guidedStep = 'Rewrite the measure with narrower filters or deterministic logic, preserving accepted business totals.'
        validation = ('Run generated tests for `{0}` and validate downstream count {1}.' -f $metric.name, $impactItem.downstreamCount)
        status = 'Open'
    })
}

$ordered = @($fixes.ToArray() | Sort-Object @{ Expression = { @{ P0 = 0; P1 = 1; P2 = 2 }[$_.priority] } }, Source)
$result = [pscustomobject]@{
    schema = 'codex.powerbi.guidedFixPlan.v1'
    root = $scan.root
    generated = (Get-Date).ToString('s')
    fixCount = $ordered.Count
    fixes = $ordered
}

if ($Json) {
    $text = $result | ConvertTo-Json -Depth 8
    if ($OutputPath) { Set-Content -LiteralPath $OutputPath -Value $text -Encoding UTF8 }
    $text
    return
}

$md = New-Object System.Collections.Generic.List[string]
$md.Add('# Power BI Guided Fix Plan')
$md.Add('')
$md.Add(('Fixes: {0}' -f $result.fixCount))
$md.Add('')
foreach ($fix in $result.fixes) {
    $md.Add(('## [{0}] {1}' -f $fix.priority, $fix.source))
    $md.Add(('- Theme: {0}' -f $fix.theme))
    $md.Add(('- Problem: {0}' -f $fix.problem))
    $md.Add(('- Guided step: {0}' -f $fix.guidedStep))
    $md.Add(('- Validation: {0}' -f $fix.validation))
    $md.Add(('- Status: {0}' -f $fix.status))
    $md.Add('')
}
$content = ($md -join [Environment]::NewLine) + [Environment]::NewLine
if ($OutputPath) { Set-Content -LiteralPath $OutputPath -Value $content -Encoding UTF8 }
$content

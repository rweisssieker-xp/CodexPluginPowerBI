param(
    [string]$PluginRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
)

$ErrorActionPreference = 'Stop'

$samplePath = Join-Path $PluginRoot 'examples/sample-model'
$scriptsPath = Join-Path $PluginRoot 'scripts'
$manifestPath = Join-Path $PluginRoot '.codex-plugin/plugin.json'

$results = New-Object System.Collections.Generic.List[object]

function Add-TestResult {
    param([string]$Name, [bool]$Passed, [string]$Detail)
    $script:results.Add([pscustomobject]@{
        Name = $Name
        Passed = $Passed
        Detail = $Detail
    })
}

try {
    Get-Content -Raw -LiteralPath $manifestPath | ConvertFrom-Json | Out-Null
    Add-TestResult -Name 'Manifest JSON' -Passed $true -Detail 'plugin.json parses.'
}
catch {
    Add-TestResult -Name 'Manifest JSON' -Passed $false -Detail $_.Exception.Message
}

try {
    $live = & (Join-Path $scriptsPath 'Get-PowerBIDesktopLiveConnection.ps1') -Json | ConvertFrom-Json
    Add-TestResult -Name 'Live connection detection runs' -Passed ($null -ne $live.powerBIDesktopRunning) -Detail "PowerBIDesktopRunning=$($live.powerBIDesktopRunning)"
}
catch {
    Add-TestResult -Name 'Live connection detection runs' -Passed $false -Detail $_.Exception.Message
}

try {
    $requiredLiveScripts = @(
        'Invoke-PowerBILiveDaxQuery.ps1',
        'Test-PowerBILiveMeasures.ps1',
        'Test-PowerBILiveMetadataGovernance.ps1',
        'New-PowerBILiveRefactorSuggestions.ps1',
        'New-PowerBILiveFixBacklog.ps1',
        'New-PowerBILiveDaxFixDrafts.ps1',
        'Invoke-PowerBILiveAutoReview.ps1'
    )
    $missingLiveScripts = @($requiredLiveScripts | Where-Object { -not (Test-Path -LiteralPath (Join-Path $scriptsPath $_)) })
    Add-TestResult -Name 'Live AI scripts are present' -Passed ($missingLiveScripts.Count -eq 0) -Detail ("Missing={0}" -f ($missingLiveScripts -join ', '))
}
catch {
    Add-TestResult -Name 'Live AI scripts are present' -Passed $false -Detail $_.Exception.Message
}

try {
    $structure = & (Join-Path $scriptsPath 'Get-PowerBIPBIPStructure.ps1') -Path $samplePath -Json | ConvertFrom-Json
    Add-TestResult -Name 'PBIP structure reports readiness' -Passed ($structure.score -ge 20) -Detail "Readiness=$($structure.readiness), Score=$($structure.score)"
}
catch {
    Add-TestResult -Name 'PBIP structure reports readiness' -Passed $false -Detail $_.Exception.Message
}

try {
    $scan = & (Join-Path $scriptsPath 'Invoke-PowerBIInsightScan.ps1') -Path $samplePath -Json | ConvertFrom-Json
    Add-TestResult -Name 'Insight scan detects sample risks' -Passed ($scan.Findings.Count -ge 3 -and $scan.RiskScore -ge 6) -Detail "Findings=$($scan.Findings.Count), RiskScore=$($scan.RiskScore)"
}
catch {
    Add-TestResult -Name 'Insight scan detects sample risks' -Passed $false -Detail $_.Exception.Message
}

try {
    $catalog = & (Join-Path $scriptsPath 'New-PowerBIMetricCatalog.ps1') -Path $samplePath -Json | ConvertFrom-Json
    Add-TestResult -Name 'Metric catalog extracts measures' -Passed ($catalog.metricCount -eq 5) -Detail "MetricCount=$($catalog.metricCount)"
}
catch {
    Add-TestResult -Name 'Metric catalog extracts measures' -Passed $false -Detail $_.Exception.Message
}

try {
    $graph = & (Join-Path $scriptsPath 'New-PowerBIDependencyGraph.ps1') -Path $samplePath -Json | ConvertFrom-Json
    Add-TestResult -Name 'Dependency graph detects edges' -Passed ($graph.edgeCount -ge 2) -Detail "EdgeCount=$($graph.edgeCount)"
}
catch {
    Add-TestResult -Name 'Dependency graph detects edges' -Passed $false -Detail $_.Exception.Message
}

try {
    $plan = & (Join-Path $scriptsPath 'New-PowerBIRefactorPlan.ps1') -Path $samplePath -Json | ConvertFrom-Json
    Add-TestResult -Name 'Refactor plan creates items' -Passed ($plan.itemCount -ge 3) -Detail "ItemCount=$($plan.itemCount)"
}
catch {
    Add-TestResult -Name 'Refactor plan creates items' -Passed $false -Detail $_.Exception.Message
}

try {
    $pack = & (Join-Path $scriptsPath 'New-PowerBIAIPromptPack.ps1') -Path $samplePath -OutputDirectory (Join-Path $PluginRoot 'tmp/ai-pack-test')
    Add-TestResult -Name 'AI prompt pack creates context' -Passed (Test-Path -LiteralPath (Join-Path $pack.OutputDirectory 'context-pack.json')) -Detail $pack.OutputDirectory
}
catch {
    Add-TestResult -Name 'AI prompt pack creates context' -Passed $false -Detail $_.Exception.Message
}

try {
    $review = & (Join-Path $scriptsPath 'Invoke-PowerBIAutoReview.ps1') -Path $samplePath -OutputDirectory (Join-Path $PluginRoot 'tmp/auto-review-test')
    Add-TestResult -Name 'Auto review creates index' -Passed (Test-Path -LiteralPath $review.Index) -Detail $review.OutputDirectory
}
catch {
    Add-TestResult -Name 'Auto review creates index' -Passed $false -Detail $_.Exception.Message
}

try {
    $blueprint = & (Join-Path $scriptsPath 'New-PowerBIReportBlueprint.ps1') -Path $samplePath -Json | ConvertFrom-Json
    Add-TestResult -Name 'Report blueprint creates pages' -Passed ($blueprint.pageCount -eq 3) -Detail "PageCount=$($blueprint.pageCount)"
}
catch {
    Add-TestResult -Name 'Report blueprint creates pages' -Passed $false -Detail $_.Exception.Message
}

$results | Format-Table Name, Passed, Detail -AutoSize
if (($results | Where-Object { -not $_.Passed }).Count -gt 0) {
    exit 1
}

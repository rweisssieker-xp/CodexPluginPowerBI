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

try {
    $innovationScripts = @(
        'New-PowerBIGuidedFixPlan.ps1',
        'Compare-PowerBISemanticModel.ps1',
        'New-PowerBIMeasureLineageImpact.ps1',
        'New-PowerBIMeasureTestPlan.ps1',
        'New-PowerBIPerformanceAdvisor.ps1',
        'New-PowerBIReportUXCritic.ps1',
        'New-PowerBIExecutiveExplainabilityPack.ps1',
        'New-PowerBIModelGovernanceScorecard.ps1',
        'Test-PowerBICopilotReadiness.ps1',
        'New-PowerBIReleaseChecklist.ps1',
        'Invoke-PowerBIInnovationReview.ps1'
    )
    $missingInnovationScripts = @($innovationScripts | Where-Object { -not (Test-Path -LiteralPath (Join-Path $scriptsPath $_)) })
    Add-TestResult -Name 'Innovation scripts are present' -Passed ($missingInnovationScripts.Count -eq 0) -Detail ("Missing={0}" -f ($missingInnovationScripts -join ', '))
}
catch {
    Add-TestResult -Name 'Innovation scripts are present' -Passed $false -Detail $_.Exception.Message
}

try {
    $guided = & (Join-Path $scriptsPath 'New-PowerBIGuidedFixPlan.ps1') -Path $samplePath -Json | ConvertFrom-Json
    Add-TestResult -Name 'Guided fix plan ranks fixes' -Passed ($guided.fixCount -ge 3 -and @($guided.fixes)[0].priority -eq 'P0') -Detail "FixCount=$($guided.fixCount)"
}
catch {
    Add-TestResult -Name 'Guided fix plan ranks fixes' -Passed $false -Detail $_.Exception.Message
}

try {
    $impact = & (Join-Path $scriptsPath 'New-PowerBIMeasureLineageImpact.ps1') -Path $samplePath -Json | ConvertFrom-Json
    Add-TestResult -Name 'Measure lineage impact scores dependencies' -Passed ($impact.measureCount -eq 5 -and ($impact.measures | Where-Object { $_.downstreamCount -gt 0 }).Count -gt 0) -Detail "Measures=$($impact.measureCount)"
}
catch {
    Add-TestResult -Name 'Measure lineage impact scores dependencies' -Passed $false -Detail $_.Exception.Message
}

try {
    $testPlan = & (Join-Path $scriptsPath 'New-PowerBIMeasureTestPlan.ps1') -Path $samplePath -Json | ConvertFrom-Json
    Add-TestResult -Name 'Measure test generator creates DAX tests' -Passed ($testPlan.testCount -ge 15 -and @($testPlan.tests)[0].daxQuery) -Detail "Tests=$($testPlan.testCount)"
}
catch {
    Add-TestResult -Name 'Measure test generator creates DAX tests' -Passed $false -Detail $_.Exception.Message
}

try {
    $innovation = & (Join-Path $scriptsPath 'Invoke-PowerBIInnovationReview.ps1') -Path $samplePath -OutputDirectory (Join-Path $PluginRoot 'tmp/innovation-review-test')
    $passed = (Test-Path -LiteralPath $innovation.Index) -and (Test-Path -LiteralPath (Join-Path $innovation.OutputDirectory 'governance-scorecard.md')) -and (Test-Path -LiteralPath (Join-Path $innovation.OutputDirectory 'release-checklist.md'))
    Add-TestResult -Name 'Innovation review creates package' -Passed $passed -Detail $innovation.OutputDirectory
}
catch {
    Add-TestResult -Name 'Innovation review creates package' -Passed $false -Detail $_.Exception.Message
}

$results | Format-Table Name, Passed, Detail -AutoSize
if (($results | Where-Object { -not $_.Passed }).Count -gt 0) {
    exit 1
}

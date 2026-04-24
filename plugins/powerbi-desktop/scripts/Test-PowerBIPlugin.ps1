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
    $externalScripts = @(
        'Get-PowerBIExternalToolInventory.ps1',
        'New-PowerBIExternalToolCapabilityMatrix.ps1',
        'New-PowerBITabularEditorWorkflow.ps1',
        'New-PowerBIDaxStudioWorkflow.ps1',
        'New-PowerBIALMToolkitWorkflow.ps1',
        'New-PowerBIHelperWorkflow.ps1',
        'New-PowerBIPbiToolsWorkflow.ps1',
        'Invoke-PowerBIExternalToolsReview.ps1'
    )
    $missingExternalScripts = @($externalScripts | Where-Object { -not (Test-Path -LiteralPath (Join-Path $scriptsPath $_)) })
    Add-TestResult -Name 'External tool scripts are present' -Passed ($missingExternalScripts.Count -eq 0) -Detail ("Missing={0}" -f ($missingExternalScripts -join ', '))
}
catch {
    Add-TestResult -Name 'External tool scripts are present' -Passed $false -Detail $_.Exception.Message
}

try {
    $tools = & (Join-Path $scriptsPath 'Get-PowerBIExternalToolInventory.ps1') -Json | ConvertFrom-Json
    Add-TestResult -Name 'External tool inventory reports known tools' -Passed (@($tools.tools).Count -ge 7 -and ($tools.tools | Where-Object name -eq 'DAX Studio')) -Detail "Tools=$(@($tools.tools).Count)"
}
catch {
    Add-TestResult -Name 'External tool inventory reports known tools' -Passed $false -Detail $_.Exception.Message
}

try {
    $matrix = & (Join-Path $scriptsPath 'New-PowerBIExternalToolCapabilityMatrix.ps1') -Json | ConvertFrom-Json
    Add-TestResult -Name 'External tool capability matrix maps features' -Passed ($matrix.toolCount -ge 7 -and $matrix.capabilityCount -ge 8) -Detail "Tools=$($matrix.toolCount), Capabilities=$($matrix.capabilityCount)"
}
catch {
    Add-TestResult -Name 'External tool capability matrix maps features' -Passed $false -Detail $_.Exception.Message
}

try {
    $nativeScripts = @(
        'Invoke-PowerBINativeBpa.ps1',
        'Compare-PowerBINativeModel.ps1',
        'New-PowerBINativeModelDocumentation.ps1',
        'New-PowerBINativePerformanceProfile.ps1',
        'Test-PowerBIReportLayoutBestPractices.ps1',
        'New-PowerBIThemeAudit.ps1',
        'New-PowerBIPBIPSourceControlPlan.ps1',
        'Invoke-PowerBINativeToolParityReview.ps1'
    )
    $missingNativeScripts = @($nativeScripts | Where-Object { -not (Test-Path -LiteralPath (Join-Path $scriptsPath $_)) })
    Add-TestResult -Name 'Native tool capability scripts are present' -Passed ($missingNativeScripts.Count -eq 0) -Detail ("Missing={0}" -f ($missingNativeScripts -join ', '))
}
catch {
    Add-TestResult -Name 'Native tool capability scripts are present' -Passed $false -Detail $_.Exception.Message
}

try {
    $bpa = & (Join-Path $scriptsPath 'Invoke-PowerBINativeBpa.ps1') -Path $samplePath -Json | ConvertFrom-Json
    Add-TestResult -Name 'Native BPA returns rule findings' -Passed ($bpa.ruleCount -ge 5 -and $bpa.findingCount -ge 1) -Detail "Rules=$($bpa.ruleCount), Findings=$($bpa.findingCount)"
}
catch {
    Add-TestResult -Name 'Native BPA returns rule findings' -Passed $false -Detail $_.Exception.Message
}

try {
    $doc = & (Join-Path $scriptsPath 'New-PowerBINativeModelDocumentation.ps1') -Path $samplePath -Json | ConvertFrom-Json
    Add-TestResult -Name 'Native model documentation summarizes model' -Passed ($doc.metricCount -eq 5 -and $doc.sectionCount -ge 4) -Detail "Sections=$($doc.sectionCount)"
}
catch {
    Add-TestResult -Name 'Native model documentation summarizes model' -Passed $false -Detail $_.Exception.Message
}

try {
    $perf = & (Join-Path $scriptsPath 'New-PowerBINativePerformanceProfile.ps1') -Path $samplePath -Json | ConvertFrom-Json
    Add-TestResult -Name 'Native performance profile estimates risk' -Passed ($perf.profileCount -eq 5 -and $perf.totalEstimatedRisk -ge 0) -Detail "Profiles=$($perf.profileCount)"
}
catch {
    Add-TestResult -Name 'Native performance profile estimates risk' -Passed $false -Detail $_.Exception.Message
}

try {
    $realFeatureScripts = @(
        'Test-PowerBIVisualSchema.ps1',
        'Test-PowerBIReportRenderReadiness.ps1',
        'Invoke-PowerBILiveDaxBenchmark.ps1',
        'Get-PowerBILiveVertiPaqAnalyzer.ps1',
        'New-PowerBICalculationGroupDraft.ps1',
        'New-PowerBIRelationshipDraft.ps1',
        'New-PowerBIRlsRoleDraft.ps1',
        'New-PowerBIPowerQueryDraft.ps1',
        'New-PowerBIServiceIntegrationPlan.ps1',
        'New-PowerBIIncrementalRefreshDraft.ps1',
        'New-PowerBIAggregationDraft.ps1',
        'New-PowerBISchemaAwareVisualPlan.ps1',
        'Invoke-PowerBIRealFeatureReview.ps1'
    )
    $missingRealFeatureScripts = @($realFeatureScripts | Where-Object { -not (Test-Path -LiteralPath (Join-Path $scriptsPath $_)) })
    Add-TestResult -Name 'Real feature scripts are present' -Passed ($missingRealFeatureScripts.Count -eq 0) -Detail ("Missing={0}" -f ($missingRealFeatureScripts -join ', '))
}
catch {
    Add-TestResult -Name 'Real feature scripts are present' -Passed $false -Detail $_.Exception.Message
}

try {
    $calcGroup = & (Join-Path $scriptsPath 'New-PowerBICalculationGroupDraft.ps1') -GroupName 'Time Intelligence' -BaseMeasure 'Total Sales' -Json | ConvertFrom-Json
    Add-TestResult -Name 'Calculation group draft creates items' -Passed ($calcGroup.objectType -eq 'CalculationGroup' -and @($calcGroup.items).Count -ge 3) -Detail "Items=$(@($calcGroup.items).Count)"
}
catch {
    Add-TestResult -Name 'Calculation group draft creates items' -Passed $false -Detail $_.Exception.Message
}

try {
    $relationship = & (Join-Path $scriptsPath 'New-PowerBIRelationshipDraft.ps1') -FromTable 'Sales' -FromColumn 'DateKey' -ToTable 'Date' -ToColumn 'DateKey' -Json | ConvertFrom-Json
    Add-TestResult -Name 'Relationship draft creates TMDL' -Passed ($relationship.objectType -eq 'Relationship' -and $relationship.tmdl -match 'relationship') -Detail $relationship.relationshipName
}
catch {
    Add-TestResult -Name 'Relationship draft creates TMDL' -Passed $false -Detail $_.Exception.Message
}

try {
    $mDraft = & (Join-Path $scriptsPath 'New-PowerBIPowerQueryDraft.ps1') -QueryName 'DimDate' -SourceKind 'DateTable' -Json | ConvertFrom-Json
    Add-TestResult -Name 'Power Query draft creates M script' -Passed ($mDraft.objectType -eq 'PowerQuery' -and $mDraft.mCode -match 'let') -Detail $mDraft.queryName
}
catch {
    Add-TestResult -Name 'Power Query draft creates M script' -Passed $false -Detail $_.Exception.Message
}

try {
    $schemaVisual = & (Join-Path $scriptsPath 'New-PowerBISchemaAwareVisualPlan.ps1') -Path $samplePath -Measure 'Total Sales' -Json | ConvertFrom-Json
    Add-TestResult -Name 'Schema-aware visual planner recommends visual' -Passed ($schemaVisual.recommendation.visualType -and $schemaVisual.measure -eq 'Total Sales') -Detail $schemaVisual.recommendation.visualType
}
catch {
    Add-TestResult -Name 'Schema-aware visual planner recommends visual' -Passed $false -Detail $_.Exception.Message
}

try {
    $realReview = & (Join-Path $scriptsPath 'Invoke-PowerBIRealFeatureReview.ps1') -Path $samplePath -OutputDirectory (Join-Path $PluginRoot 'tmp/real-feature-review-test')
    $passed = (Test-Path -LiteralPath $realReview.Index) -and (Test-Path -LiteralPath (Join-Path $realReview.OutputDirectory 'visual-schema-check.json')) -and (Test-Path -LiteralPath (Join-Path $realReview.OutputDirectory 'service-integration-plan.md'))
    Add-TestResult -Name 'Real feature review creates package' -Passed $passed -Detail $realReview.OutputDirectory
}
catch {
    Add-TestResult -Name 'Real feature review creates package' -Passed $false -Detail $_.Exception.Message
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
        'Invoke-PowerBIInnovationReview.ps1',
        'New-PowerBIBusinessSemanticLayer.ps1',
        'New-PowerBIKpiTrustScore.ps1',
        'New-PowerBIFlightRecorder.ps1',
        'New-PowerBIDecisionRiskAssistant.ps1',
        'Compare-PowerBIMeasureBehavior.ps1',
        'New-PowerBIReportNarrativeCritic.ps1',
        'Optimize-PowerBICopilotModel.ps1',
        'New-PowerBIDaxFixSimulation.ps1',
        'New-PowerBIVisualMeasureImpactMap.ps1',
        'New-PowerBITrustReleaseGate.ps1',
        'New-PowerBIMeasureDraft.ps1',
        'New-PowerBICalculatedColumnDraft.ps1',
        'Test-PowerBIModelBestPractices.ps1',
        'New-PowerBIReportPageDraft.ps1',
        'New-PowerBIVisualDraft.ps1',
        'New-PowerBIReportLayoutPlan.ps1',
        'Add-PowerBIPBIPReportPage.ps1',
        'New-PowerBIPBIXCompileWorkflow.ps1'
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

try {
    $trust = & (Join-Path $scriptsPath 'New-PowerBIKpiTrustScore.ps1') -Path $samplePath -Json | ConvertFrom-Json
    Add-TestResult -Name 'KPI trust scores rate all metrics' -Passed ($trust.metricCount -eq 5 -and @($trust.metrics)[0].trustScore -ge 0 -and $trust.overallTrustScore -ge 0) -Detail "Metrics=$($trust.metricCount), Overall=$($trust.overallTrustScore)"
}
catch {
    Add-TestResult -Name 'KPI trust scores rate all metrics' -Passed $false -Detail $_.Exception.Message
}

try {
    $gate = & (Join-Path $scriptsPath 'New-PowerBITrustReleaseGate.ps1') -Path $samplePath -Json | ConvertFrom-Json
    Add-TestResult -Name 'Trust release gate returns decision' -Passed (@('Go', 'Warn', 'No-Go') -contains $gate.decision -and $gate.checkCount -ge 5) -Detail "Decision=$($gate.decision)"
}
catch {
    Add-TestResult -Name 'Trust release gate returns decision' -Passed $false -Detail $_.Exception.Message
}

try {
    $semantic = & (Join-Path $scriptsPath 'New-PowerBIBusinessSemanticLayer.ps1') -Path $samplePath -Json | ConvertFrom-Json
    Add-TestResult -Name 'Business semantic layer explains decisions' -Passed ($semantic.metricCount -eq 5 -and @($semantic.metrics)[0].decisionContext) -Detail "Metrics=$($semantic.metricCount)"
}
catch {
    Add-TestResult -Name 'Business semantic layer explains decisions' -Passed $false -Detail $_.Exception.Message
}

try {
    $uspReview = & (Join-Path $scriptsPath 'Invoke-PowerBIInnovationReview.ps1') -Path $samplePath -OutputDirectory (Join-Path $PluginRoot 'tmp/usp-review-test')
    $passed = (Test-Path -LiteralPath (Join-Path $uspReview.OutputDirectory 'trust-release-gate.md')) -and (Test-Path -LiteralPath (Join-Path $uspReview.OutputDirectory 'kpi-trust-score.md')) -and (Test-Path -LiteralPath (Join-Path $uspReview.OutputDirectory 'decision-risk-assistant.md'))
    Add-TestResult -Name 'Innovation review includes USP package' -Passed $passed -Detail $uspReview.OutputDirectory
}
catch {
    Add-TestResult -Name 'Innovation review includes USP package' -Passed $false -Detail $_.Exception.Message
}

try {
    $rulesPath = Join-Path $PluginRoot 'rules/powerbi-trust-rules.json'
    $rules = Get-Content -Raw -LiteralPath $rulesPath | ConvertFrom-Json
    Add-TestResult -Name 'Trust rules config exists' -Passed ($rules.schema -eq 'codex.powerbi.trustRules.v1' -and $rules.releaseGate.goThreshold -gt 0) -Detail $rulesPath
}
catch {
    Add-TestResult -Name 'Trust rules config exists' -Passed $false -Detail $_.Exception.Message
}

try {
    $measureDraft = & (Join-Path $scriptsPath 'New-PowerBIMeasureDraft.ps1') -TableName 'Sales' -MeasureName 'Average Sales' -Expression "DIVIDE([Total Sales], COUNTROWS('Sales'))" -OutputPath (Join-Path $PluginRoot 'tmp/measure-draft-test.md') -Json | ConvertFrom-Json
    Add-TestResult -Name 'Measure draft generator creates safe draft' -Passed ($measureDraft.objectType -eq 'Measure' -and $measureDraft.tmdl -match 'measure Average Sales') -Detail $measureDraft.outputPath
}
catch {
    Add-TestResult -Name 'Measure draft generator creates safe draft' -Passed $false -Detail $_.Exception.Message
}

try {
    $columnDraft = & (Join-Path $scriptsPath 'New-PowerBICalculatedColumnDraft.ps1') -TableName 'Sales' -ColumnName 'Sales Bucket' -Expression "IF('Sales'[Sales Amount] > 1000, ""High"", ""Standard"")" -OutputPath (Join-Path $PluginRoot 'tmp/column-draft-test.md') -Json | ConvertFrom-Json
    Add-TestResult -Name 'Calculated column draft generator creates safe draft' -Passed ($columnDraft.objectType -eq 'CalculatedColumn' -and $columnDraft.tmdl -match 'column Sales Bucket') -Detail $columnDraft.outputPath
}
catch {
    Add-TestResult -Name 'Calculated column draft generator creates safe draft' -Passed $false -Detail $_.Exception.Message
}

try {
    $bestPractices = & (Join-Path $scriptsPath 'Test-PowerBIModelBestPractices.ps1') -Path $samplePath -Json | ConvertFrom-Json
    Add-TestResult -Name 'Model best practices produce findings' -Passed ($bestPractices.findingCount -ge 1 -and $bestPractices.score -ge 0) -Detail "Findings=$($bestPractices.findingCount), Score=$($bestPractices.score)"
}
catch {
    Add-TestResult -Name 'Model best practices produce findings' -Passed $false -Detail $_.Exception.Message
}

try {
    $pesterPath = Join-Path $PluginRoot 'tests/PowerBIPlugin.Tests.ps1'
    Add-TestResult -Name 'Pester test file exists' -Passed (Test-Path -LiteralPath $pesterPath) -Detail $pesterPath
}
catch {
    Add-TestResult -Name 'Pester test file exists' -Passed $false -Detail $_.Exception.Message
}

try {
    $pageDraft = & (Join-Path $scriptsPath 'New-PowerBIReportPageDraft.ps1') -PageName 'Executive Overview' -Measures 'Total Sales','Sales YoY %' -OutputPath (Join-Path $PluginRoot 'tmp/page-draft-test.json') -Json | ConvertFrom-Json
    Add-TestResult -Name 'Report page draft creates visual specs' -Passed ($pageDraft.pageName -eq 'Executive Overview' -and @($pageDraft.visuals).Count -ge 2) -Detail "Visuals=$(@($pageDraft.visuals).Count)"
}
catch {
    Add-TestResult -Name 'Report page draft creates visual specs' -Passed $false -Detail $_.Exception.Message
}

try {
    $visualDraft = & (Join-Path $scriptsPath 'New-PowerBIVisualDraft.ps1') -VisualType 'KpiCard' -Title 'Total Sales' -Measure 'Total Sales' -Json | ConvertFrom-Json
    Add-TestResult -Name 'Visual draft creates PBIP-safe spec' -Passed ($visualDraft.visualType -eq 'KpiCard' -and $visualDraft.measure -eq 'Total Sales') -Detail $visualDraft.visualId
}
catch {
    Add-TestResult -Name 'Visual draft creates PBIP-safe spec' -Passed $false -Detail $_.Exception.Message
}

try {
    $layout = & (Join-Path $scriptsPath 'New-PowerBIReportLayoutPlan.ps1') -PageName 'Executive Overview' -VisualCount 4 -Json | ConvertFrom-Json
    Add-TestResult -Name 'Report layout plan creates stable slots' -Passed ($layout.slotCount -eq 4 -and @($layout.slots)[0].width -gt 0) -Detail "Slots=$($layout.slotCount)"
}
catch {
    Add-TestResult -Name 'Report layout plan creates stable slots' -Passed $false -Detail $_.Exception.Message
}

try {
    $applyRoot = Join-Path $PluginRoot 'tmp/pbip-page-apply-test'
    $apply = & (Join-Path $scriptsPath 'Add-PowerBIPBIPReportPage.ps1') -PbipPath $applyRoot -PageName 'Executive Overview' -Measures 'Total Sales','Sales YoY %' -Apply -Json | ConvertFrom-Json
    Add-TestResult -Name 'PBIP report page apply writes draft files' -Passed ($apply.applied -eq $true -and (Test-Path -LiteralPath $apply.pagePath)) -Detail $apply.pagePath
}
catch {
    Add-TestResult -Name 'PBIP report page apply writes draft files' -Passed $false -Detail $_.Exception.Message
}

try {
    $compile = & (Join-Path $scriptsPath 'New-PowerBIPBIXCompileWorkflow.ps1') -PbipPath (Join-Path $PluginRoot 'tmp/pbip-page-apply-test') -OutputPbix (Join-Path $PluginRoot 'tmp/report.pbix') -Json | ConvertFrom-Json
    Add-TestResult -Name 'PBIX compile workflow creates commands' -Passed ($compile.workflow -eq 'PBIP to PBIX' -and @($compile.steps).Count -ge 3) -Detail $compile.recommendedPath
}
catch {
    Add-TestResult -Name 'PBIX compile workflow creates commands' -Passed $false -Detail $_.Exception.Message
}

$results | Format-Table Name, Passed, Detail -AutoSize
if (($results | Where-Object { -not $_.Passed }).Count -gt 0) {
    exit 1
}

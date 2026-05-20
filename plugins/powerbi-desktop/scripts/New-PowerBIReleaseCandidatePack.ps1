param(
    [string]$Path = ".",
    [string]$OutputDirectory = "powerbi-release-candidate-pack",
    [switch]$SkipLive,
    [switch]$IncludeBusinessProcessDQ,
    [string]$BusinessProcessDataPath,
    [string]$BusinessProcessMappingPath
)

$ErrorActionPreference = 'Stop'
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$resolvedOut = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputDirectory)
New-Item -ItemType Directory -Force -Path $resolvedOut | Out-Null

$unifiedErrorLog = Join-Path $resolvedOut 'unified-review-errors.log'
if ($SkipLive) {
    $unified = & (Join-Path $scriptRoot 'Invoke-PowerBIUnifiedReview.ps1') -Path $Path -OutputDirectory (Join-Path $resolvedOut 'unified-review') -SkipLive 2>$unifiedErrorLog
}
else {
    $unified = & (Join-Path $scriptRoot 'Invoke-PowerBIUnifiedReview.ps1') -Path $Path -OutputDirectory (Join-Path $resolvedOut 'unified-review')
    if (Test-Path -LiteralPath $unifiedErrorLog) { Remove-Item -LiteralPath $unifiedErrorLog -Force }
}
$maxAiErrorLog = Join-Path $resolvedOut 'max-ai-review-errors.log'
if ($SkipLive) {
    $maxAi = & (Join-Path $scriptRoot 'Invoke-PowerBIMaxAIReview.ps1') -Path $Path -OutputDirectory (Join-Path $resolvedOut 'max-ai-review') 2>$maxAiErrorLog
}
else {
    $maxAi = & (Join-Path $scriptRoot 'Invoke-PowerBIMaxAIReview.ps1') -Path $Path -OutputDirectory (Join-Path $resolvedOut 'max-ai-review')
    if (Test-Path -LiteralPath $maxAiErrorLog) { Remove-Item -LiteralPath $maxAiErrorLog -Force }
}
& (Join-Path $scriptRoot 'New-PowerBIServiceScanner.ps1') -Path $Path -OutputPath (Join-Path $resolvedOut 'service-scanner.json') -Json | Out-Null
& (Join-Path $scriptRoot 'New-PowerBIModelRiskHeatmap.ps1') -Path $Path -OutputPath (Join-Path $resolvedOut 'model-risk-heatmap.json') -Json | Out-Null
& (Join-Path $scriptRoot 'Invoke-PowerBISemanticTestRunner.ps1') -Path $Path -OutputPath (Join-Path $resolvedOut 'semantic-tests.json') -Json | Out-Null
& (Join-Path $scriptRoot 'Get-PowerBIPBIPStructure.ps1') -Path $Path -OutputPath (Join-Path $resolvedOut 'pbip-structure.json') -Json | Out-Null
& (Join-Path $scriptRoot 'New-PowerBIGovernancePolicyPack.ps1') -OutputPath (Join-Path $resolvedOut 'governance-policy-pack.json') -Json | Out-Null
& (Join-Path $scriptRoot 'New-PowerBITrustReleaseGate.ps1') -Path $Path -OutputPath (Join-Path $resolvedOut 'trust-release-gate.json') -Json | Out-Null
& (Join-Path $scriptRoot 'New-PowerBITrustDebtLedger.ps1') -Path $Path -OutputPath (Join-Path $resolvedOut 'trust-debt-ledger.json') -Json | Out-Null
& (Join-Path $scriptRoot 'New-PowerBIFabricCapacityRiskForecast.ps1') -Path $Path -OutputPath (Join-Path $resolvedOut 'fabric-capacity-risk.json') -Json | Out-Null
& (Join-Path $scriptRoot 'Test-PowerBIRlsLeakage.ps1') -Path $Path -OutputPath (Join-Path $resolvedOut 'rls-leakage.json') -Json | Out-Null
& (Join-Path $scriptRoot 'New-PowerBIUsageTrustMatrix.ps1') -Path $Path -OutputPath (Join-Path $resolvedOut 'usage-trust-matrix.json') -Json | Out-Null
& (Join-Path $scriptRoot 'Test-PowerBIPBIPRollbackReadiness.ps1') -PbipPath $Path -OutputPath (Join-Path $resolvedOut 'pbip-rollback-readiness.json') -Json | Out-Null
if ($IncludeBusinessProcessDQ) {
    & (Join-Path $scriptRoot 'Invoke-PowerBIBusinessProcessDataQuality.ps1') -Path $Path -DataPath $BusinessProcessDataPath -MappingPath $BusinessProcessMappingPath -OutputDirectory (Join-Path $resolvedOut 'business-process-dq') -Json | Out-Null
}
& (Join-Path $scriptRoot 'New-PowerBIPRReleaseComment.ps1') -Path $Path -OutputPath (Join-Path $resolvedOut 'pr-release-comment.md') | Out-Null

$semantic = Get-Content -Raw -LiteralPath (Join-Path $resolvedOut 'semantic-tests.json') | ConvertFrom-Json
$pbipStructure = Get-Content -Raw -LiteralPath (Join-Path $resolvedOut 'pbip-structure.json') | ConvertFrom-Json
$releaseGate = Get-Content -Raw -LiteralPath (Join-Path $resolvedOut 'trust-release-gate.json') | ConvertFrom-Json
$trustDebt = Get-Content -Raw -LiteralPath (Join-Path $resolvedOut 'trust-debt-ledger.json') | ConvertFrom-Json
$capacityRisk = Get-Content -Raw -LiteralPath (Join-Path $resolvedOut 'fabric-capacity-risk.json') | ConvertFrom-Json
$rlsLeakage = Get-Content -Raw -LiteralPath (Join-Path $resolvedOut 'rls-leakage.json') | ConvertFrom-Json
$usageTrust = Get-Content -Raw -LiteralPath (Join-Path $resolvedOut 'usage-trust-matrix.json') | ConvertFrom-Json
$rollbackReadiness = Get-Content -Raw -LiteralPath (Join-Path $resolvedOut 'pbip-rollback-readiness.json') | ConvertFrom-Json
$businessProcessDq = if ($IncludeBusinessProcessDQ) { Get-Content -Raw -LiteralPath (Join-Path $resolvedOut 'business-process-dq/summary.json') | ConvertFrom-Json } else { $null }
$unifiedErrorCount = if (Test-Path -LiteralPath $unifiedErrorLog) { @((Get-Content -LiteralPath $unifiedErrorLog -ErrorAction SilentlyContinue) | Where-Object { $_ }).Count } else { 0 }
$maxAiErrorCount = if (Test-Path -LiteralPath $maxAiErrorLog) { @((Get-Content -LiteralPath $maxAiErrorLog -ErrorAction SilentlyContinue) | Where-Object { $_ }).Count } else { 0 }

$summary = [pscustomobject]@{
    schema = 'codex.powerbi.releaseCandidatePack.v1'
    generated = (Get-Date).ToString('s')
    source = (Resolve-Path -LiteralPath $Path).Path
    outputDirectory = $resolvedOut
    unifiedReview = $unified.Index
    unifiedReviewErrorLog = if ($unifiedErrorCount -gt 0) { $unifiedErrorLog } else { $null }
    unifiedReviewErrorCount = $unifiedErrorCount
    maxAiReview = $maxAi.Index
    maxAiReviewErrorLog = if ($maxAiErrorCount -gt 0) { $maxAiErrorLog } else { $null }
    maxAiReviewErrorCount = $maxAiErrorCount
    decision = $releaseGate.decision
    gate = [pscustomobject]@{
        decision = $releaseGate.decision
        failCount = $releaseGate.failCount
        warnCount = $releaseGate.warnCount
        openP0Count = $releaseGate.openP0Count
        openP1Count = $releaseGate.openP1Count
        pendingSemanticTestCount = $releaseGate.pendingSemanticTestCount
        liveStatus = $releaseGate.liveStatus
        blockingReasons = $releaseGate.blockingReasons
        warnings = $releaseGate.warnings
    }
    validation = [pscustomobject]@{
        semanticTestCount = $semantic.testCount
        semanticFailedCount = $semantic.failedCount
        pendingSemanticTestCount = @($semantic.tests | Where-Object { $_.result -in @('PendingLiveDax', 'NotRun') -or $_.status -eq 'Generated' }).Count
        pbipRoundtripStatus = $pbipStructure.roundtripStatus
        pbipReadiness = $pbipStructure.readiness
        liveStatus = $unified.LiveStatus
    }
    enterpriseUsps = [pscustomobject]@{
        trustDebtReleaseBlockerCount = $trustDebt.releaseBlockerCount
        fabricCapacityRiskLevel = $capacityRisk.capacityRiskLevel
        rlsHighRiskCount = $rlsLeakage.highRiskCount
        usageTrustPriority = $usageTrust.priority
        rollbackReadinessStatus = $rollbackReadiness.status
        businessProcessDqStatus = if ($businessProcessDq) { $businessProcessDq.status } else { 'NotRun' }
        businessProcessDqHighCount = if ($businessProcessDq) { $businessProcessDq.highCount } else { 0 }
    }
}
$summaryPath = Join-Path $resolvedOut 'summary.json'
$summary | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $summaryPath -Encoding UTF8

$index = @(
    '# Power BI Release Candidate Pack',
    '',
    ('Source: `{0}`' -f $summary.source),
    "Generated: $($summary.generated)",
    '',
    '## Artifacts',
    ('- Unified review: `{0}`' -f $unified.Index),
    ('- Unified review error log: `{0}`' -f $(if ($unifiedErrorCount -gt 0) { $unifiedErrorLog } else { 'none' })),
    ('- Max AI review: `{0}`' -f $maxAi.Index),
    ('- Max AI review error log: `{0}`' -f $(if ($maxAiErrorCount -gt 0) { $maxAiErrorLog } else { 'none' })),
    ('- Service scanner: `{0}`' -f (Join-Path $resolvedOut 'service-scanner.json')),
    ('- Model risk heatmap: `{0}`' -f (Join-Path $resolvedOut 'model-risk-heatmap.json')),
    ('- Semantic tests: `{0}`' -f (Join-Path $resolvedOut 'semantic-tests.json')),
    ('- PBIP structure: `{0}`' -f (Join-Path $resolvedOut 'pbip-structure.json')),
    ('- Governance policy pack: `{0}`' -f (Join-Path $resolvedOut 'governance-policy-pack.json')),
    ('- Trust release gate: `{0}`' -f (Join-Path $resolvedOut 'trust-release-gate.json')),
    ('- Trust debt ledger: `{0}`' -f (Join-Path $resolvedOut 'trust-debt-ledger.json')),
    ('- Fabric capacity risk forecast: `{0}`' -f (Join-Path $resolvedOut 'fabric-capacity-risk.json')),
    ('- RLS leakage checks: `{0}`' -f (Join-Path $resolvedOut 'rls-leakage.json')),
    ('- Usage trust matrix: `{0}`' -f (Join-Path $resolvedOut 'usage-trust-matrix.json')),
    ('- PBIP rollback readiness: `{0}`' -f (Join-Path $resolvedOut 'pbip-rollback-readiness.json')),
    ('- Business process DQ: `{0}`' -f $(if ($IncludeBusinessProcessDQ) { Join-Path $resolvedOut 'business-process-dq/summary.json' } else { 'not requested' })),
    ('- PR release comment: `{0}`' -f (Join-Path $resolvedOut 'pr-release-comment.md')),
    ('- Summary: `{0}`' -f $summaryPath)
)
$indexPath = Join-Path $resolvedOut 'README.md'
Set-Content -LiteralPath $indexPath -Value (($index -join [Environment]::NewLine) + [Environment]::NewLine) -Encoding UTF8

[pscustomobject]@{
    OutputDirectory = $resolvedOut
    Index = $indexPath
    Summary = $summaryPath
}

param(
    [string]$Path = ".",
    [string]$OutputDirectory = "powerbi-release-candidate-pack",
    [switch]$SkipLive
)

$ErrorActionPreference = 'Stop'
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$resolvedOut = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputDirectory)
New-Item -ItemType Directory -Force -Path $resolvedOut | Out-Null

$unified = & (Join-Path $scriptRoot 'Invoke-PowerBIUnifiedReview.ps1') -Path $Path -OutputDirectory (Join-Path $resolvedOut 'unified-review') -SkipLive:$SkipLive
$maxAi = & (Join-Path $scriptRoot 'Invoke-PowerBIMaxAIReview.ps1') -Path $Path -OutputDirectory (Join-Path $resolvedOut 'max-ai-review')
& (Join-Path $scriptRoot 'New-PowerBIServiceScanner.ps1') -Path $Path -OutputPath (Join-Path $resolvedOut 'service-scanner.json') -Json | Out-Null
& (Join-Path $scriptRoot 'New-PowerBIModelRiskHeatmap.ps1') -Path $Path -OutputPath (Join-Path $resolvedOut 'model-risk-heatmap.json') -Json | Out-Null
& (Join-Path $scriptRoot 'Invoke-PowerBISemanticTestRunner.ps1') -Path $Path -OutputPath (Join-Path $resolvedOut 'semantic-tests.json') -Json | Out-Null
& (Join-Path $scriptRoot 'New-PowerBIPRReleaseComment.ps1') -Path $Path -OutputPath (Join-Path $resolvedOut 'pr-release-comment.md') | Out-Null

$summary = [pscustomobject]@{
    schema = 'codex.powerbi.releaseCandidatePack.v1'
    generated = (Get-Date).ToString('s')
    source = (Resolve-Path -LiteralPath $Path).Path
    outputDirectory = $resolvedOut
    unifiedReview = $unified.Index
    maxAiReview = $maxAi.Index
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
    ('- Max AI review: `{0}`' -f $maxAi.Index),
    ('- Service scanner: `{0}`' -f (Join-Path $resolvedOut 'service-scanner.json')),
    ('- Model risk heatmap: `{0}`' -f (Join-Path $resolvedOut 'model-risk-heatmap.json')),
    ('- Semantic tests: `{0}`' -f (Join-Path $resolvedOut 'semantic-tests.json')),
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

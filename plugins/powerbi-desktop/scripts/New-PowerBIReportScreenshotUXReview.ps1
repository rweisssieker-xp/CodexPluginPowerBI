param(
    [string]$ImagePath,
    [string]$ReportName = '[TODO: report]',
    [string]$OutputPath,
    [switch]$Json
)

$ErrorActionPreference = 'Stop'
$checks = @(
    [pscustomobject]@{ area = 'Readability'; recommendation = 'Verify title hierarchy, data labels, axis density, and contrast at 100 percent zoom.' },
    [pscustomobject]@{ area = 'Executive Fit'; recommendation = 'Ensure first viewport shows decision KPI, trend, variance, and owner context.' },
    [pscustomobject]@{ area = 'Accessibility'; recommendation = 'Check color-only encoding, text contrast, and keyboard/screen-reader metadata.' },
    [pscustomobject]@{ area = 'Narrative'; recommendation = 'Confirm visuals answer one business question instead of exposing raw model structure.' }
)

$exists = $ImagePath -and (Test-Path -LiteralPath $ImagePath)
$result = [pscustomobject]@{
    schema = 'codex.powerbi.screenshotUxReview.v1'
    generated = (Get-Date).ToString('s')
    reportName = $ReportName
    imagePath = $ImagePath
    status = if ($exists) { 'ReadyForVisionReview' } else { 'ScreenshotMissing' }
    checks = $checks
    findingCount = if ($exists) { 0 } else { 1 }
    findings = if ($exists) { @() } else { @([pscustomobject]@{ severity = 'Medium'; title = 'Screenshot missing'; detail = 'Provide a rendered report screenshot for visual UX inspection.' }) }
}

if ($Json) {
    $text = $result | ConvertTo-Json -Depth 8
    if ($OutputPath) { Set-Content -LiteralPath $OutputPath -Value $text -Encoding UTF8 }
    $text
    return
}
$lines = @('# Report Screenshot UX Review', '', "Status: $($result.status)", '', '## Checks') + @($checks | ForEach-Object { "- $($_.area): $($_.recommendation)" })
$content = ($lines -join [Environment]::NewLine) + [Environment]::NewLine
if ($OutputPath) { Set-Content -LiteralPath $OutputPath -Value $content -Encoding UTF8 }
$content

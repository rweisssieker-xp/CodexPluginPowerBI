param([string]$Path = ".", [string]$OutputPath, [switch]$Json)
$ErrorActionPreference = 'Stop'
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$trust = & (Join-Path $scriptRoot 'New-PowerBIKpiTrustScore.ps1') -Path $Path -Json | ConvertFrom-Json
$scorecard = & (Join-Path $scriptRoot 'New-PowerBIModelGovernanceScorecard.ps1') -Path $Path -Json | ConvertFrom-Json
$copilot = & (Join-Path $scriptRoot 'Test-PowerBICopilotReadiness.ps1') -Path $Path -Json | ConvertFrom-Json
$fixes = & (Join-Path $scriptRoot 'New-PowerBIGuidedFixPlan.ps1') -Path $Path -Json | ConvertFrom-Json
$p0 = @($fixes.fixes | Where-Object priority -eq 'P0').Count
$lowTrust = @($trust.metrics | Where-Object { $_.trustScore -lt 60 }).Count
$checks = @(
    [pscustomobject]@{ name = 'KPI trust score'; status = $(if ($trust.overallTrustScore -ge 80) { 'Pass' } elseif ($trust.overallTrustScore -ge 60) { 'Warn' } else { 'Fail' }); value = $trust.overallTrustScore },
    [pscustomobject]@{ name = 'Low-trust KPI count'; status = $(if ($lowTrust -eq 0) { 'Pass' } else { 'Fail' }); value = $lowTrust },
    [pscustomobject]@{ name = 'P0 guided fixes'; status = $(if ($p0 -eq 0) { 'Pass' } else { 'Fail' }); value = $p0 },
    [pscustomobject]@{ name = 'Governance score'; status = $(if ($scorecard.overallScore -ge 70) { 'Pass' } else { 'Warn' }); value = $scorecard.overallScore },
    [pscustomobject]@{ name = 'Copilot readiness'; status = $(if ($copilot.score -ge 70) { 'Pass' } else { 'Warn' }); value = $copilot.score }
)
$failCount = @($checks | Where-Object status -eq 'Fail').Count
$warnCount = @($checks | Where-Object status -eq 'Warn').Count
$decision = if ($failCount -gt 0) { 'No-Go' } elseif ($warnCount -gt 0) { 'Warn' } else { 'Go' }
$result = [pscustomobject]@{ schema = 'codex.powerbi.trustReleaseGate.v1'; root = $trust.root; generated = (Get-Date).ToString('s'); decision = $decision; checkCount = $checks.Count; checks = $checks; releaseNote = $(if ($decision -eq 'Go') { 'Publish candidate after normal business sign-off.' } elseif ($decision -eq 'Warn') { 'Publish only with documented caveats.' } else { 'Block publish until failing checks are remediated.' }) }
if ($Json) { $text = $result | ConvertTo-Json -Depth 8; if ($OutputPath) { Set-Content -LiteralPath $OutputPath -Value $text -Encoding UTF8 }; $text; return }
$md = @('# Power BI Trust Release Gate', '', "Decision: **$decision**", '', "Release note: $($result.releaseNote)", '', '## Checks') + @($checks | ForEach-Object { "- [$($_.status)] $($_.name): $($_.value)" })
$content = ($md -join [Environment]::NewLine) + [Environment]::NewLine
if ($OutputPath) { Set-Content -LiteralPath $OutputPath -Value $content -Encoding UTF8 }
$content


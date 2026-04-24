param([string]$Path = ".", [string]$OutputPath, [switch]$Json)
$ErrorActionPreference = 'Stop'
$schema = & (Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) 'Test-PowerBIVisualSchema.ps1') -Path $Path -Json | ConvertFrom-Json
$checks = @(
    [pscustomobject]@{ name = 'PBIP visual JSON parses'; status = $(if (($schema.findings | Where-Object severity -eq 'High').Count -eq 0) { 'Pass' } else { 'Fail' }) },
    [pscustomobject]@{ name = 'Manual Desktop render validation'; status = 'Required' },
    [pscustomobject]@{ name = 'Screenshot inspection'; status = 'Required' }
)
$result = [pscustomobject]@{ schema = 'codex.powerbi.reportRenderReadiness.v1'; generated = (Get-Date).ToString('s'); checkCount = $checks.Count; checks = $checks; readyForAutomatedPublish = $false }
if ($Json) { $text = $result | ConvertTo-Json -Depth 6; if ($OutputPath) { Set-Content -LiteralPath $OutputPath -Value $text -Encoding UTF8 }; $text; return }
$result


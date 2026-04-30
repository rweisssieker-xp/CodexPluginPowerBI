param([string]$Path = ".", [string]$PbipPath, [int]$MaxIterations = 3, [string]$OutputPath, [switch]$Apply, [switch]$Json)
$ErrorActionPreference = 'Stop'
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$iterations = New-Object System.Collections.Generic.List[object]
for ($i = 1; $i -le $MaxIterations; $i++) {
    $fix = & (Join-Path $scriptRoot 'Invoke-PowerBIAutonomousFixAgent.ps1') -Path $Path -PbipPath $PbipPath -MaxFixes 1 -Apply:$Apply -Json | ConvertFrom-Json
    $golden = & (Join-Path $scriptRoot 'Test-PowerBIGoldenBaselines.ps1') -Json | ConvertFrom-Json
    $gate = & (Join-Path $scriptRoot 'New-PowerBITrustReleaseGate.ps1') -Path $Path -Json | ConvertFrom-Json
    $green = ($golden.failedCount -eq 0 -and $gate.decision -ne 'No-Go')
    $iterations.Add([pscustomobject]@{ iteration = $i; fixCount = $fix.fixCount; applied = $fix.applied; goldenFailed = $golden.failedCount; releaseDecision = $gate.decision; green = $green })
    if ($green -or $fix.fixCount -eq 0) { break }
}
$iterationArray = @($iterations.ToArray())
$finalGreen = if ($iterationArray.Count -gt 0) { $iterationArray[-1].green } else { $false }
$result = [pscustomobject]@{ schema='codex.powerbi.fixUntilGreenLoop.v1'; generated=(Get-Date).ToString('s'); applied=[bool]$Apply; iterationCount=$iterationArray.Count; finalGreen=$finalGreen; iterations=$iterationArray }
if ($Json) { $text=$result|ConvertTo-Json -Depth 8; if($OutputPath){Set-Content -LiteralPath $OutputPath -Value $text -Encoding UTF8}; $text; return }
$md = @('# Power BI Fix Until Green Loop','',"Applied: $($result.applied)","Final green: $($result.finalGreen)",'') + @($result.iterations | ForEach-Object { "- Iteration $($_.iteration): decision=$($_.releaseDecision), goldenFailed=$($_.goldenFailed), fixes=$($_.fixCount)" })
$content=($md -join [Environment]::NewLine)+[Environment]::NewLine; if($OutputPath){Set-Content -LiteralPath $OutputPath -Value $content -Encoding UTF8}; $content

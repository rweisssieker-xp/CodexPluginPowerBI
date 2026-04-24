param([Parameter(Mandatory=$true)][string]$BeforePath, [Parameter(Mandatory=$true)][string]$AfterPath, [string]$OutputPath, [switch]$Json)
$ErrorActionPreference = 'Stop'
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$diff = & (Join-Path $scriptRoot 'Compare-PowerBISemanticModel.ps1') -BeforePath $BeforePath -AfterPath $AfterPath -Json | ConvertFrom-Json
$tests = & (Join-Path $scriptRoot 'New-PowerBIMeasureTestPlan.ps1') -Path $AfterPath -Json | ConvertFrom-Json
$items = foreach ($change in @($diff.changes)) {
    [pscustomobject]@{ id = $change.id; changeType = $change.type; behaviorRisk = $change.risk; validationQueries = @($tests.tests | Where-Object { $_.measure -eq (($change.id -split '\.')[-1] -replace '-', ' ') } | Select-Object -ExpandProperty daxQuery); tolerance = 'Business owner defines acceptable variance.'; rollbackNote = 'Revert changed measure expression from previous PBIP/TMDL version if validation fails.' }
}
$result = [pscustomobject]@{ schema = 'codex.powerbi.measureBehaviorComparison.v1'; before = $diff.before; after = $diff.after; generated = (Get-Date).ToString('s'); comparisonCount = @($items).Count; comparisons = @($items) }
if ($Json) { $text = $result | ConvertTo-Json -Depth 8; if ($OutputPath) { Set-Content -LiteralPath $OutputPath -Value $text -Encoding UTF8 }; $text; return }
$md = @('# Power BI Before/After Measure Behavior', '', "Comparisons: $($result.comparisonCount)", '') + @($items | ForEach-Object { "- [$($_.behaviorRisk)] $($_.changeType): `$($_.id)` - $($_.rollbackNote)" })
$content = ($md -join [Environment]::NewLine) + [Environment]::NewLine
if ($OutputPath) { Set-Content -LiteralPath $OutputPath -Value $content -Encoding UTF8 }
$content


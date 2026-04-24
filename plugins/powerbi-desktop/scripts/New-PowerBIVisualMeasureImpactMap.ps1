param([string]$Path = ".", [string]$OutputPath, [switch]$Json)
$ErrorActionPreference = 'Stop'
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$catalog = & (Join-Path $scriptRoot 'New-PowerBIMetricCatalog.ps1') -Path $Path -Json | ConvertFrom-Json
$resolved = (Resolve-Path -LiteralPath $Path).Path
$reportText = (Get-ChildItem -LiteralPath $resolved -Recurse -File -Include *.json -ErrorAction SilentlyContinue | ForEach-Object { Get-Content -Raw -LiteralPath $_.FullName }) -join [Environment]::NewLine
$items = foreach ($metric in @($catalog.metrics)) {
    $hits = if ($reportText) { ([regex]::Matches($reportText, [regex]::Escape($metric.name))).Count } else { 0 }
    [pscustomobject]@{ measure = $metric.name; detectedVisualReferences = $hits; affectedPages = $(if ($hits -gt 0) { @('Detected in report metadata') } else { @() }); impactGuidance = $(if ($hits -gt 0) { 'Validate affected visuals, tooltips, and drillthrough paths.' } else { 'No visual metadata reference detected; validate manually or export PBIP report metadata.' }) }
}
$result = [pscustomobject]@{ schema = 'codex.powerbi.visualMeasureImpactMap.v1'; root = $catalog.root; generated = (Get-Date).ToString('s'); measureCount = @($items).Count; impacts = @($items) }
if ($Json) { $text = $result | ConvertTo-Json -Depth 8; if ($OutputPath) { Set-Content -LiteralPath $OutputPath -Value $text -Encoding UTF8 }; $text; return }
$md = @('# Power BI Visual-to-Measure Impact Map', '') + @($result.impacts | ForEach-Object { "- `$($_.measure)`: $($_.detectedVisualReferences) visual metadata references. $($_.impactGuidance)" })
$content = ($md -join [Environment]::NewLine) + [Environment]::NewLine
if ($OutputPath) { Set-Content -LiteralPath $OutputPath -Value $content -Encoding UTF8 }
$content


param(
    [string]$Path = ".",
    [string]$OutputPath,
    [switch]$Json
)

$ErrorActionPreference = 'Stop'

$root = (Resolve-Path -LiteralPath $Path).Path
$files = Get-ChildItem -LiteralPath $root -Recurse -File -ErrorAction SilentlyContinue

function Test-Any {
    param([string[]]$Patterns)
    foreach ($pattern in $Patterns) {
        if ($files | Where-Object { $_.FullName -like $pattern }) {
            return $true
        }
    }
    return $false
}

$pbipFiles = @($files | Where-Object { $_.Extension -eq '.pbip' })
$semanticModelDirs = @(Get-ChildItem -LiteralPath $root -Recurse -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -like '*.SemanticModel' })
$reportDirs = @(Get-ChildItem -LiteralPath $root -Recurse -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -like '*.Report' })
$tmdlFiles = @($files | Where-Object { $_.Extension -eq '.tmdl' })
$reportJsonFiles = @($files | Where-Object { $_.Name -in @('report.json', 'definition.pbir') })
$modelFiles = @($files | Where-Object { $_.Name -in @('model.bim', 'definition.pbism') })

$score = 0
if ($pbipFiles.Count -gt 0) { $score += 20 }
if ($semanticModelDirs.Count -gt 0) { $score += 20 }
if ($reportDirs.Count -gt 0) { $score += 15 }
if ($tmdlFiles.Count -gt 0) { $score += 20 }
if ($reportJsonFiles.Count -gt 0) { $score += 10 }
if ($modelFiles.Count -gt 0) { $score += 15 }

$readiness = if ($score -ge 70) { 'Strong' } elseif ($score -ge 35) { 'Partial' } else { 'Limited' }
$recommendations = New-Object System.Collections.Generic.List[string]
if ($pbipFiles.Count -eq 0) { $recommendations.Add('Create or export a PBIP entry point for source-controlled Desktop round-tripping.') }
if ($semanticModelDirs.Count -eq 0 -and $tmdlFiles.Count -eq 0 -and $modelFiles.Count -eq 0) { $recommendations.Add('Export the semantic model to TMDL or model.bim before requesting structural changes.') }
if ($reportDirs.Count -eq 0 -and $reportJsonFiles.Count -eq 0) { $recommendations.Add('Export report metadata if layout or visual analysis is required.') }
if ($recommendations.Count -eq 0) { $recommendations.Add('Project structure is ready for deeper model and report review.') }

$result = [pscustomobject]@{
    schema = 'codex.powerbi.pbipStructure.v1'
    root = $root
    generated = (Get-Date).ToString('s')
    readiness = $readiness
    score = $score
    pbipFiles = @($pbipFiles | Select-Object -ExpandProperty FullName)
    semanticModelDirectories = @($semanticModelDirs | Select-Object -ExpandProperty FullName)
    reportDirectories = @($reportDirs | Select-Object -ExpandProperty FullName)
    tmdlFileCount = $tmdlFiles.Count
    reportMetadataFileCount = $reportJsonFiles.Count
    modelMetadataFileCount = $modelFiles.Count
    recommendations = @($recommendations)
}

if ($Json) {
    $jsonText = $result | ConvertTo-Json -Depth 6
    if ($OutputPath) { Set-Content -LiteralPath $OutputPath -Value $jsonText -Encoding UTF8 }
    $jsonText
    return
}

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add('# Power BI PBIP Structure')
$lines.Add('')
$lines.Add(('Readiness: **{0}** ({1}/100)' -f $result.readiness, $result.score))
$lines.Add(('PBIP files: {0}' -f @($result.pbipFiles).Count))
$lines.Add(('Semantic model directories: {0}' -f @($result.semanticModelDirectories).Count))
$lines.Add(('Report directories: {0}' -f @($result.reportDirectories).Count))
$lines.Add(('TMDL files: {0}' -f $result.tmdlFileCount))
$lines.Add(('Report metadata files: {0}' -f $result.reportMetadataFileCount))
$lines.Add(('Model metadata files: {0}' -f $result.modelMetadataFileCount))
$lines.Add('')
$lines.Add('## Recommendations')
$lines.Add('')
foreach ($recommendation in $result.recommendations) {
    $lines.Add(('- {0}' -f $recommendation))
}

$content = ($lines -join [Environment]::NewLine) + [Environment]::NewLine
if ($OutputPath) { Set-Content -LiteralPath $OutputPath -Value $content -Encoding UTF8 }
$content

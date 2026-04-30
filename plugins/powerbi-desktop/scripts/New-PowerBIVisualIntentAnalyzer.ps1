param([string]$Path='.', [string]$OutputPath, [switch]$Json)
$ErrorActionPreference='Stop'
$scriptRoot=Split-Path -Parent $MyInvocation.MyCommand.Path
$blueprint=&(Join-Path $scriptRoot 'New-PowerBIReportBlueprint.ps1') -Path $Path -Json|ConvertFrom-Json
$impact=&(Join-Path $scriptRoot 'New-PowerBIVisualMeasureImpactMap.ps1') -Path $Path -Json|ConvertFrom-Json
$intents=foreach($page in @($blueprint.pages)){[pscustomobject]@{page=$page.name; intendedDecision=$page.goal; primaryMeasures=@($page.measures); contradictionRisk=$(if(@($page.measures).Count -gt 5){'Medium'}else{'Low'}); redundancyRisk=$(if(@($impact.impacts|Where-Object detectedVisualReferences -gt 3).Count -gt 0){'Medium'}else{'Low'}); recommendedNarrative=('Use the page to answer: {0}' -f $page.goal)}}
$result=[pscustomobject]@{schema='codex.powerbi.visualIntentAnalyzer.v1'; generated=(Get-Date).ToString('s'); pageCount=@($intents).Count; intents=@($intents)}
if($Json){$text=$result|ConvertTo-Json -Depth 8;if($OutputPath){Set-Content -LiteralPath $OutputPath -Value $text -Encoding UTF8};$text;return}
$md=@('# Power BI Visual Intent Analyzer','')+@($intents|ForEach-Object{"## $($_.page)`n- Decision: $($_.intendedDecision)`n- Contradiction risk: $($_.contradictionRisk)`n"})
$content=($md -join [Environment]::NewLine)+[Environment]::NewLine;if($OutputPath){Set-Content -LiteralPath $OutputPath -Value $content -Encoding UTF8};$content

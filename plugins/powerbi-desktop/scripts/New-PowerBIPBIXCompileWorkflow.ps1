param(
    [Parameter(Mandatory=$true)][string]$PbipPath,
    [Parameter(Mandatory=$true)][string]$OutputPbix,
    [string]$OutputPath,
    [switch]$Json
)
$ErrorActionPreference = 'Stop'
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$tools = & (Join-Path $scriptRoot 'Get-PowerBIExternalToolInventory.ps1') -Json | ConvertFrom-Json
$pbiTools = @($tools.tools | Where-Object name -eq 'pbi-tools' | Select-Object -First 1)
$desktop = @($tools.tools | Where-Object name -eq 'Power BI Desktop' | Select-Object -First 1)
$resolvedPbip = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($PbipPath)
$recommended = if ($pbiTools.installed) { 'pbi-tools compile' } else { 'Power BI Desktop Save As PBIX' }
$commands = @()
if ($pbiTools.installed) {
    $commands += ('"{0}" compile "{1}" -format PBIX -out "{2}"' -f $pbiTools.path, $resolvedPbip, $OutputPbix)
}
if ($desktop.installed) {
    $commands += ('Open PBIP in Power BI Desktop: "{0}"' -f $desktop.path)
    $commands += ('Use File > Save As and choose PBIX output: "{0}"' -f $OutputPbix)
}
$steps = @(
    'Run Trust Release Gate and resolve No-Go findings.',
    'Open the PBIP project and validate pages/visuals in Power BI Desktop.',
    'Compile with pbi-tools if installed, otherwise Save As PBIX in Power BI Desktop.',
    'Open the produced PBIX and rerun live validation before publishing.'
)
$result = [pscustomobject]@{
    schema = 'codex.powerbi.pbixCompileWorkflow.v1'
    workflow = 'PBIP to PBIX'
    pbipPath = $resolvedPbip
    outputPbix = $OutputPbix
    recommendedPath = $recommended
    pbiToolsInstalled = [bool]$pbiTools.installed
    powerBIDesktopInstalled = [bool]$desktop.installed
    commands = $commands
    steps = $steps
}
if ($Json) { $text = $result | ConvertTo-Json -Depth 8; if ($OutputPath) { Set-Content -LiteralPath $OutputPath -Value $text -Encoding UTF8 }; $text; return }
$md = @('# Power BI PBIP to PBIX Compile Workflow', '', "Recommended path: $recommended", '', '## Steps') + @($steps | ForEach-Object { "- $_" }) + @('', '## Commands') + @($commands | ForEach-Object { '```powershell' + [Environment]::NewLine + $_ + [Environment]::NewLine + '```' })
$content = ($md -join [Environment]::NewLine) + [Environment]::NewLine
if ($OutputPath) { Set-Content -LiteralPath $OutputPath -Value $content -Encoding UTF8 }
$content

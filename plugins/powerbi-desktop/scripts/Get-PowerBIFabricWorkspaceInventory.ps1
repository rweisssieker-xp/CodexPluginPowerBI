param(
    [string]$WorkspaceName = '[TODO: Fabric workspace]',
    [string]$TenantId,
    [string]$AccessTokenPath,
    [string]$OutputPath,
    [switch]$UseRest,
    [switch]$Json
)

$ErrorActionPreference = 'Stop'

$mode = 'OfflinePlan'
$items = @()
$findings = New-Object System.Collections.Generic.List[object]
$nextActions = New-Object System.Collections.Generic.List[object]

if ($UseRest) {
    if (-not $AccessTokenPath -or -not (Test-Path -LiteralPath $AccessTokenPath)) {
        $findings.Add([pscustomobject]@{
            severity = 'High'
            category = 'Authentication'
            title = 'REST mode requested without token file'
            detail = 'Provide AccessTokenPath with a valid bearer token file. The plugin never signs in implicitly.'
        })
    }
    else {
        $mode = 'RestPrepared'
        $nextActions.Add([pscustomobject]@{
            phase = 'REST inventory'
            action = 'Use the token file to call Fabric/Power BI workspace and item APIs from an explicit operator session.'
            required = $true
        })
    }
}

$nextActions.Add([pscustomobject]@{ phase = 'Scope'; action = "Confirm workspace name and tenant boundary: $WorkspaceName"; required = $true })
$nextActions.Add([pscustomobject]@{ phase = 'Inventory'; action = 'Collect reports, semantic models, refresh schedules, lineage, endorsements, labels, and owners.'; required = $true })
$nextActions.Add([pscustomobject]@{ phase = 'Drift'; action = 'Compare service inventory with PBIP repository artifacts before release.'; required = $true })
$nextActions.Add([pscustomobject]@{ phase = 'Governance'; action = 'Review sensitivity labels, certification state, app exposure, and refresh ownership.'; required = $true })

$result = [pscustomobject]@{
    schema = 'codex.powerbi.fabricWorkspaceInventory.v1'
    generated = (Get-Date).ToString('s')
    mode = $mode
    workspaceName = $WorkspaceName
    tenantId = $TenantId
    itemCount = @($items).Count
    items = $items
    findingCount = $findings.Count
    findings = $findings.ToArray()
    nextActions = $nextActions.ToArray()
}

if ($Json) {
    $text = $result | ConvertTo-Json -Depth 8
    if ($OutputPath) { Set-Content -LiteralPath $OutputPath -Value $text -Encoding UTF8 }
    $text
    return
}

$lines = @(
    '# Fabric Workspace Inventory',
    '',
    "Workspace: $WorkspaceName",
    "Mode: $mode",
    '',
    '## Next Actions'
) + @($nextActions | ForEach-Object { "- [$($_.phase)] $($_.action)" })

if ($findings.Count -gt 0) {
    $lines += @('', '## Findings')
    $lines += @($findings | ForEach-Object { "- [$($_.severity)] $($_.title): $($_.detail)" })
}

$content = ($lines -join [Environment]::NewLine) + [Environment]::NewLine
if ($OutputPath) { Set-Content -LiteralPath $OutputPath -Value $content -Encoding UTF8 }
$content

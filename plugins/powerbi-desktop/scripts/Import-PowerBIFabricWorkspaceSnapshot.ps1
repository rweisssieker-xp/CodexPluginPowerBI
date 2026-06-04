param(
    [string]$TenantId,
    [string]$WorkspaceId,
    [string]$WorkspaceName,
    [string]$ItemId,
    [string]$AccessTokenPath,
    [string]$SnapshotDirectory,
    [string]$OutputDirectory = "fabric-workspace-snapshot",
    [switch]$Json
)

$ErrorActionPreference = 'Stop'
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$resolvedOut = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputDirectory)
New-Item -ItemType Directory -Force -Path $resolvedOut | Out-Null

function Read-SnapshotJson {
    param([string]$Root, [string]$Name, $Fallback)
    $path = Join-Path $Root $Name
    if (Test-Path -LiteralPath $path) { return Get-Content -Raw -LiteralPath $path | ConvertFrom-Json }
    return $Fallback
}

$accessPlanPath = Join-Path $resolvedOut 'access-plan.json'
$accessPlan = & (Join-Path $scriptRoot 'Get-PowerBIFabricAccessPlan.ps1') -TenantId $TenantId -WorkspaceId $WorkspaceId -WorkspaceName $WorkspaceName -ItemId $ItemId -AccessTokenPath $AccessTokenPath -SnapshotDirectory $SnapshotDirectory -OutputPath $accessPlanPath -Json | ConvertFrom-Json

if ($SnapshotDirectory -and (Test-Path -LiteralPath $SnapshotDirectory)) {
    foreach ($name in @('workspace.json','items.json','reports.json','semantic-models.json','refresh-history.json','lineage.json','deployment-pipelines.json','capacities.json','gateways.json','activity.json','endorsements.json','sensitivity-labels.json')) {
        $source = Join-Path $SnapshotDirectory $name
        if (Test-Path -LiteralPath $source) { Copy-Item -LiteralPath $source -Destination (Join-Path $resolvedOut $name) -Force }
    }
    $mode = 'SnapshotDirectory'
}
elseif ($accessPlan.status -eq 'ReadyForReadOnlySnapshot') {
    $workspace = [pscustomobject]@{ id = $WorkspaceId; name = $WorkspaceName; tenantId = $TenantId; source = 'LiveReadPrepared' }
    $workspace | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath (Join-Path $resolvedOut 'workspace.json') -Encoding UTF8
    @() | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $resolvedOut 'items.json') -Encoding UTF8
    $mode = 'LiveReadPrepared'
}
else {
    $workspace = [pscustomobject]@{ id = $WorkspaceId; name = $WorkspaceName; tenantId = $TenantId; source = 'AccessPlanOnly' }
    $workspace | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath (Join-Path $resolvedOut 'workspace.json') -Encoding UTF8
    @() | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $resolvedOut 'items.json') -Encoding UTF8
    $mode = 'AccessPlanOnly'
}

$items = @(Read-SnapshotJson -Root $resolvedOut -Name 'items.json' -Fallback @())
$refresh = @(Read-SnapshotJson -Root $resolvedOut -Name 'refresh-history.json' -Fallback @())
$lineage = @(Read-SnapshotJson -Root $resolvedOut -Name 'lineage.json' -Fallback @())
$accessIssues = @($accessPlan.accessIssues)

$summary = [pscustomobject]@{
    schema = 'codex.powerbi.fabricWorkspaceSnapshot.v1'
    generated = (Get-Date).ToString('s')
    mode = $mode
    tenantId = $TenantId
    workspaceId = $WorkspaceId
    workspaceName = $WorkspaceName
    outputDirectory = $resolvedOut
    status = if ($accessIssues.Count -gt 0 -and $mode -eq 'AccessPlanOnly') { 'NeedsAccessPlan' } else { 'SnapshotReady' }
    itemCount = $items.Count
    refreshRecordCount = $refresh.Count
    lineageEdgeCount = $lineage.Count
    accessIssueCount = $accessIssues.Count
    accessIssues = $accessIssues
}
$summaryPath = Join-Path $resolvedOut 'summary.json'
$summary | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $summaryPath -Encoding UTF8

$result = [pscustomobject]@{ OutputDirectory = $resolvedOut; Summary = $summaryPath; Status = $summary.status; Mode = $mode }
if ($Json) { $result | ConvertTo-Json -Depth 6; return }
$result

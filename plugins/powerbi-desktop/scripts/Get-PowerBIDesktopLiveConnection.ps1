param(
    [switch]$Json
)

$ErrorActionPreference = 'Stop'

function Get-WorkspaceRoots {
    $roots = @(
        (Join-Path $env:LOCALAPPDATA 'Microsoft\Power BI Desktop\AnalysisServicesWorkspaces'),
        (Join-Path $env:LOCALAPPDATA 'Microsoft\Power BI Desktop Store App\AnalysisServicesWorkspaces'),
        (Join-Path $env:USERPROFILE 'Microsoft\Power BI Desktop Store App\AnalysisServicesWorkspaces')
    )
    $roots | Where-Object { $_ -and (Test-Path -LiteralPath $_) }
}

function Get-PortFromWorkspace {
    param([string]$WorkspacePath)

    $portFiles = @(
        (Join-Path $WorkspacePath 'Data\msmdsrv.port.txt'),
        (Join-Path $WorkspacePath 'msmdsrv.port.txt')
    )
    foreach ($portFile in $portFiles) {
        if (Test-Path -LiteralPath $portFile) {
            $raw = (Get-Content -Raw -LiteralPath $portFile)
            $raw = ([regex]::Matches($raw, '\d') | ForEach-Object { $_.Value }) -join ''
            if ($raw -match '^\d+$') {
                return [int]$raw
            }
        }
    }
    return $null
}

$desktopProcesses = @(Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -eq 'PBIDesktop' })
$msmdsrvProcesses = @(Get-CimInstance Win32_Process -Filter "name = 'msmdsrv.exe'" -ErrorAction SilentlyContinue)
$workspaces = New-Object System.Collections.Generic.List[object]
$workspacePaths = New-Object System.Collections.Generic.HashSet[string]

foreach ($root in Get-WorkspaceRoots) {
    foreach ($workspace in Get-ChildItem -LiteralPath $root -Directory -ErrorAction SilentlyContinue) {
        [void]$workspacePaths.Add($workspace.FullName)
    }
}

foreach ($process in $msmdsrvProcesses) {
    if ($process.CommandLine -match '-s\s+"(?<path>[^"]+)"') {
        $dataPath = $Matches.path
        $workspacePath = Split-Path -Parent $dataPath
        if ($workspacePath -and (Test-Path -LiteralPath $workspacePath)) {
            [void]$workspacePaths.Add($workspacePath)
        }
    }
}

foreach ($workspacePath in $workspacePaths) {
        $workspace = Get-Item -LiteralPath $workspacePath -ErrorAction SilentlyContinue
        if (-not $workspace) { continue }
        $port = Get-PortFromWorkspace -WorkspacePath $workspace.FullName
        $isListening = $false
        if ($port) {
            $isListening = [bool](Get-NetTCPConnection -State Listen -LocalPort $port -ErrorAction SilentlyContinue)
        }
        $workspaces.Add([pscustomobject]@{
            Workspace = $workspace.FullName
            Port = $port
            IsListening = $isListening
            ConnectionString = if ($port) { "Data Source=localhost:$port" } else { $null }
            LastWriteTime = $workspace.LastWriteTime
        })
}

$result = [pscustomobject]@{
    schema = 'codex.powerbi.liveConnection.v1'
    generated = (Get-Date).ToString('s')
    powerBIDesktopRunning = $desktopProcesses.Count -gt 0
    powerBIDesktopProcesses = @($desktopProcesses | Select-Object Id, ProcessName, Path, StartTime)
    msmdsrvProcesses = @($msmdsrvProcesses | Select-Object ProcessId, CommandLine)
    workspaces = @($workspaces | Sort-Object IsListening, LastWriteTime -Descending)
    preferredConnection = @($workspaces | Where-Object { $_.IsListening -and $_.Port } | Sort-Object LastWriteTime -Descending | Select-Object -First 1)
}

if ($Json) {
    $result | ConvertTo-Json -Depth 8
    return
}

"Power BI Desktop running: $($result.powerBIDesktopRunning)"
if ($result.preferredConnection) {
    "Preferred connection: $($result.preferredConnection.ConnectionString)"
    "Workspace: $($result.preferredConnection.Workspace)"
}
elseif ($result.workspaces.Count -gt 0) {
    'Workspace folders found, but no listening local model port was detected.'
}
else {
    'No live Power BI Desktop Analysis Services workspace was detected.'
}

if ($result.workspaces.Count -gt 0) {
    $result.workspaces | Format-Table Port, IsListening, LastWriteTime, Workspace -AutoSize
}

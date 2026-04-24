param(
    [switch]$Json
)

$ErrorActionPreference = 'Stop'

function Find-CommandPath {
    param([string[]]$Names)

    foreach ($name in $Names) {
        $cmd = Get-Command $name -ErrorAction SilentlyContinue
        if ($cmd) {
            return $cmd.Source
        }
    }

    return $null
}

$desktopCandidates = @(@(
    "$env:ProgramFiles\Microsoft Power BI Desktop\bin\PBIDesktop.exe",
    "${env:ProgramFiles(x86)}\Microsoft Power BI Desktop\bin\PBIDesktop.exe",
    "$env:LOCALAPPDATA\Microsoft\WindowsApps\PBIDesktop.exe"
) | Where-Object { $_ -and (Test-Path -LiteralPath $_) })

$result = [ordered]@{
    PowerBIDesktop = if ($desktopCandidates.Count -gt 0) { $desktopCandidates[0] } else { $null }
    TabularEditor = Find-CommandPath @('TabularEditor.exe', 'TabularEditor3.exe', 'te.exe')
    DaxStudio = Find-CommandPath @('DaxStudio.exe')
    PbiTools = Find-CommandPath @('pbi-tools.exe', 'pbi-tools')
    DotNet = Find-CommandPath @('dotnet.exe', 'dotnet')
}

if ($Json) {
    $result | ConvertTo-Json -Depth 3
    return
}

$result.GetEnumerator() | ForEach-Object {
    $status = if ($_.Value) { $_.Value } else { 'not found' }
    "{0}: {1}" -f $_.Key, $status
}

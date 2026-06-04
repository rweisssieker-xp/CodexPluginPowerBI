param(
    [switch]$Unset
)

$ErrorActionPreference = 'Stop'

$repoRoot = (& git rev-parse --show-toplevel).Trim()
Set-Location -LiteralPath $repoRoot

if ($Unset) {
    git config --unset core.hooksPath
    Write-Host 'Git hooks disabled for this repository.'
    return
}

$hooksPath = '.githooks'
if (-not (Test-Path -LiteralPath $hooksPath)) {
    throw "Hooks directory not found: $hooksPath"
}

git config core.hooksPath $hooksPath
Write-Host "Git hooks enabled: core.hooksPath=$hooksPath"

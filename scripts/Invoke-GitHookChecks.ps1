param(
    [ValidateSet('PreCommit', 'PrePush')]
    [string]$Mode = 'PreCommit'
)

$ErrorActionPreference = 'Stop'

$repoRoot = (& git rev-parse --show-toplevel).Trim()
Set-Location -LiteralPath $repoRoot

function Invoke-Step {
    param(
        [string]$Name,
        [scriptblock]$Script
    )

    Write-Host "git hook: $Name"
    & $Script
}

Invoke-Step -Name 'parse plugin manifest' -Script {
    Get-Content -Raw -LiteralPath 'plugins/powerbi-desktop/.codex-plugin/plugin.json' | ConvertFrom-Json | Out-Null
}

Invoke-Step -Name 'parse marketplace manifest' -Script {
    Get-Content -Raw -LiteralPath '.agents/plugins/marketplace.json' | ConvertFrom-Json | Out-Null
}

Invoke-Step -Name 'block staged generated outputs' -Script {
    $staged = @(& git diff --cached --name-only)
    $blocked = @($staged | Where-Object {
        $_ -match '^plugins/powerbi-desktop/tmp/' -or
        $_ -match '^powerbi-.*' -or
        $_ -match '\.(pbix|pbit|pbix\.bak|pbit\.bak)$'
    })

    if ($blocked.Count -gt 0) {
        $blocked | ForEach-Object { Write-Host "Blocked generated or binary artifact: $_" }
        throw 'Generated review outputs and Power BI binaries must not be committed.'
    }
}

Invoke-Step -Name 'documentation coverage' -Script {
    & 'plugins/powerbi-desktop/scripts/Test-PowerBIDocumentationCoverage.ps1'
}

if ($Mode -eq 'PrePush') {
    Invoke-Step -Name 'golden baselines' -Script {
        & 'plugins/powerbi-desktop/scripts/Test-PowerBIGoldenBaselines.ps1' -PluginRoot 'plugins/powerbi-desktop' | Out-Host
    }

    if ($env:POWERBI_HOOK_RUN_PESTER -eq '1') {
        Invoke-Step -Name 'pester specs' -Script {
            if (-not (Get-Module -ListAvailable -Name Pester)) {
                throw 'Pester is not installed. Install Pester or unset POWERBI_HOOK_RUN_PESTER.'
            }
            Invoke-Pester 'plugins/powerbi-desktop/tests/pester' | Out-Host
        }
    }
}

Write-Host "git hook: $Mode checks passed"

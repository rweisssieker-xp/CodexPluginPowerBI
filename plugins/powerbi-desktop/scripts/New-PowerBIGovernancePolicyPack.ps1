param(
    [ValidateSet('EnterpriseBI','Finance','Healthcare','ExecutiveReporting','SelfServiceBI','FabricPremium')]
    [string]$Profile = 'EnterpriseBI',
    [string]$OutputPath,
    [switch]$Json
)

$ErrorActionPreference = 'Stop'

$baseRules = @(
    @{ id = 'metric-owner'; severity = 'High'; rule = 'Every certified KPI must have owner and business definition.' },
    @{ id = 'pbip-source'; severity = 'High'; rule = 'Production reports must have PBIP/TMDL source-control representation.' },
    @{ id = 'refresh-owner'; severity = 'Medium'; rule = 'Refresh schedule, gateway, and credential owner must be documented.' },
    @{ id = 'dax-determinism'; severity = 'Medium'; rule = 'Avoid volatile DAX in governed release KPIs unless documented.' },
    @{ id = 'sensitivity-label'; severity = 'Medium'; rule = 'Service items require a reviewed sensitivity label.' },
    @{ id = 'release-gate'; severity = 'High'; rule = 'No production deployment when trust release gate is No-Go.' }
)

$profileRules = switch ($Profile) {
    'Finance' { @(@{ id = 'finance-reconciliation'; severity = 'High'; rule = 'Finance KPIs require reconciliation source and period-close owner.' }) }
    'Healthcare' { @(@{ id = 'phi-minimization'; severity = 'High'; rule = 'Healthcare reports must minimize patient-identifiable columns and document access scope.' }) }
    'ExecutiveReporting' { @(@{ id = 'executive-first-view'; severity = 'Medium'; rule = 'First viewport must expose KPI, variance, trend, and business action.' }) }
    'SelfServiceBI' { @(@{ id = 'self-service-certified-dataset'; severity = 'Medium'; rule = 'Self-service reports should reuse certified semantic models where possible.' }) }
    'FabricPremium' { @(@{ id = 'capacity-aware'; severity = 'High'; rule = 'Fabric Premium rollout requires capacity, deployment pipeline, and refresh concurrency review.' }) }
    default { @(@{ id = 'enterprise-endorsement'; severity = 'Medium'; rule = 'Enterprise reports need endorsement and audience review.' }) }
}

$rules = @($baseRules + $profileRules | ForEach-Object { [pscustomobject]$_ })
$result = [pscustomobject]@{
    schema = 'codex.powerbi.governancePolicyPack.v1'
    generated = (Get-Date).ToString('s')
    profile = $Profile
    ruleCount = $rules.Count
    rules = $rules
}

if ($Json) {
    $text = $result | ConvertTo-Json -Depth 8
    if ($OutputPath) { Set-Content -LiteralPath $OutputPath -Value $text -Encoding UTF8 }
    $text
    return
}
$lines = @('# Governance Policy Pack', '', "Profile: $Profile", '', '## Rules') + @($rules | ForEach-Object { "- [$($_.severity)] $($_.id): $($_.rule)" })
$content = ($lines -join [Environment]::NewLine) + [Environment]::NewLine
if ($OutputPath) { Set-Content -LiteralPath $OutputPath -Value $content -Encoding UTF8 }
$content

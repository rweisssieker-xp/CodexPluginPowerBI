$pluginRoot = Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')
$scriptsPath = Join-Path $pluginRoot 'scripts'
$samplePath = Join-Path $pluginRoot 'examples/sample-model'

Describe 'Power BI Desktop plugin' {
    It 'parses the plugin manifest' {
        { Get-Content -Raw -LiteralPath (Join-Path $pluginRoot '.codex-plugin/plugin.json') | ConvertFrom-Json } | Should Not Throw
    }

    It 'generates KPI trust scores' {
        $trust = & (Join-Path $scriptsPath 'New-PowerBIKpiTrustScore.ps1') -Path $samplePath -Json | ConvertFrom-Json
        $trust.metricCount | Should Be 5
        ($trust.overallTrustScore -ge 0) | Should Be $true
    }

    It 'creates safe measure drafts' {
        $draft = & (Join-Path $scriptsPath 'New-PowerBIMeasureDraft.ps1') -TableName 'Sales' -MeasureName 'Average Sales' -Expression "DIVIDE([Total Sales], COUNTROWS('Sales'))" -Json | ConvertFrom-Json
        $draft.objectType | Should Be 'Measure'
        $draft.safety | Should Match 'Draft only'
    }
}

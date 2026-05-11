$pluginRoot = Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../..')
$scriptsPath = Join-Path $pluginRoot 'scripts'
$fixturePath = Join-Path $pluginRoot 'examples/ai-forecast/segment-monthly.json'
$outputPath = Join-Path $pluginRoot 'tmp/pester-ai-forecast'

Describe 'Power BI AI forecast' {
    It 'runs forecast from fixture input and writes detail output' {
        $forecast = & (Join-Path $scriptsPath 'Invoke-PowerBIAIForecast.ps1') -InputPath $fixturePath -OutputDirectory $outputPath -StartMonth 5 -EndMonth 6 -Json | ConvertFrom-Json

        $forecast.schema | Should Be 'codex.powerbi.aiForecast.v1'
        ($forecast.rowCount -gt 0) | Should Be $true
        (Test-Path -LiteralPath $forecast.detailPath) | Should Be $true
        ([string]::IsNullOrWhiteSpace($forecast.summaryPath)) | Should Be $false
        ([string]::IsNullOrWhiteSpace($forecast.topDeltaPath)) | Should Be $false
        (Test-Path -LiteralPath $forecast.summaryPath) | Should Be $true
        (Test-Path -LiteralPath $forecast.topDeltaPath) | Should Be $true
        $summaryRows = Import-Csv -LiteralPath $forecast.summaryPath -Delimiter ';'
        $summaryRows.Count | Should Be 2
    }

    It 'returns the DAX query plan in dry-run mode' {
        $plan = & (Join-Path $scriptsPath 'Invoke-PowerBIAIForecast.ps1') -DryRun -Json | ConvertFrom-Json

        $plan.schema | Should Be 'codex.powerbi.aiForecast.plan.v1'
        $plan.queries.segmentMonthly | Should Match 'SUMMARIZECOLUMNS'
        $plan.queries.segmentMonthly | Should Match 'Backlog'
    }
}

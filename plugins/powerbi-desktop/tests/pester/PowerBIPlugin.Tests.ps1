$pluginRoot = Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../..')
$scriptsPath = Join-Path $pluginRoot 'scripts'
$samplePath = Join-Path $pluginRoot 'examples/sample-model'

Describe 'Power BI Desktop plugin' {
    It 'parses the plugin manifest' {
        { Get-Content -Raw -LiteralPath (Join-Path $pluginRoot '.codex-plugin/plugin.json') | ConvertFrom-Json } | Should Not Throw
    }

    It 'includes the AI forecast entrypoint' {
        $scriptPath = Join-Path $scriptsPath 'Invoke-PowerBIAIForecast.ps1'
        Test-Path -LiteralPath $scriptPath | Should Be $true
        { & $scriptPath -DryRun -Json | ConvertFrom-Json } | Should Not Throw
    }

    It 'includes autonomous planning engine skills' {
        $skillsPath = Join-Path $pluginRoot 'skills'
        @(
            'powerbi-autonomous-planning-loop',
            'powerbi-goal-seeking-planning',
            'powerbi-constraint-aware-planning',
            'powerbi-revenue-digital-twin',
            'powerbi-autonomous-forecast-agents',
            'powerbi-autonomous-exception-management',
            'powerbi-revenue-rescue-mode',
            'powerbi-forecast-trust-market',
            'powerbi-causal-counterfactual-forecasting',
            'powerbi-self-healing-forecast-governance',
            'powerbi-planning-memory',
            'powerbi-planning-readiness-score',
            'powerbi-forecast-war-room'
        ) | ForEach-Object {
            $skillPath = Join-Path $skillsPath $_
            Test-Path -LiteralPath (Join-Path $skillPath 'SKILL.md') | Should Be $true
            (Get-Content -Raw -LiteralPath (Join-Path $skillPath 'SKILL.md')) | Should Match '^---'
        }
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

    It 'passes golden baselines' {
        $result = & (Join-Path $scriptsPath 'Test-PowerBIGoldenBaselines.ps1') -PluginRoot $pluginRoot -Json | ConvertFrom-Json
        $result.failedCount | Should Be 0
        ($result.checkCount -ge 20) | Should Be $true
    }

    It 'creates an External Tools registration file' {
        $outputPath = Join-Path $pluginRoot 'tmp/pester/Codex Power BI Workbench.pbitool.json'
        $registration = & (Join-Path $scriptsPath 'New-PowerBIExternalToolRegistration.ps1') -PluginRoot $pluginRoot -OutputPath $outputPath -Json | ConvertFrom-Json
        $registration.tool.name | Should Be 'Codex Power BI Workbench'
        (Test-Path -LiteralPath $registration.outputPath) | Should Be $true
    }

    It 'creates autonomous fix plans and KPI trust contracts' {
        $fixAgent = & (Join-Path $scriptsPath 'Invoke-PowerBIAutonomousFixAgent.ps1') -Path $samplePath -MaxFixes 1 -Json | ConvertFrom-Json
        $contract = & (Join-Path $scriptsPath 'New-PowerBIKpiTrustContract.ps1') -Path $samplePath -Json | ConvertFrom-Json
        $fixAgent.fixCount | Should Be 1
        $contract.metricCount | Should Be 5
    }

    It 'answers local model questions and creates Fabric readiness plans' {
        $ask = & (Join-Path $scriptsPath 'Invoke-PowerBIAskModel.ps1') -Path $samplePath -Question 'Which sales measures matter?' -Json | ConvertFrom-Json
        $fabric = & (Join-Path $scriptsPath 'New-PowerBIFabricReadinessPlan.ps1') -Path $samplePath -Json | ConvertFrom-Json
        ($ask.matchCount -ge 1) | Should Be $true
        $fabric.stepCount | Should Be 5
    }

    It 'creates the 12-USP Max AI review package' {
        $review = & (Join-Path $scriptsPath 'Invoke-PowerBIMaxAIReview.ps1') -Path $samplePath -OutputDirectory (Join-Path $pluginRoot 'tmp/pester-max-ai')
        $review.ArtifactCount | Should Be 12
        (Test-Path -LiteralPath $review.Index) | Should Be $true
    }
}

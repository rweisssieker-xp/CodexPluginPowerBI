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

    It 'resolves live Desktop targets without requiring Desktop to be open' {
        $live = & (Join-Path $scriptsPath 'Get-PowerBIDesktopLiveConnection.ps1') -RequireSingle -Json | ConvertFrom-Json
        $live.schema | Should Be 'codex.powerbi.liveConnection.v1'
        (@('TargetResolved','AmbiguousLiveTarget','NoLiveTarget') -contains $live.status) | Should Be $true
    }

    It 'honors explicit live Desktop port selection' {
        $live = & (Join-Path $scriptsPath 'Get-PowerBIDesktopLiveConnection.ps1') -Port 12345 -Json | ConvertFrom-Json
        $live.status | Should Be 'TargetResolved'
        $live.target.connectionString | Should Be 'Data Source=localhost:12345'
        $live.target.source | Should Be 'Explicit'

        $serverLive = & (Join-Path $scriptsPath 'Get-PowerBIDesktopLiveConnection.ps1') -Server 'Data Source=localhost:54321' -Json | ConvertFrom-Json
        $serverLive.status | Should Be 'TargetResolved'
        $serverLive.target.connectionString | Should Be 'Data Source=localhost:54321'
    }

    It 'creates machine-readable live safety plans' {
        $plan = & (Join-Path $scriptsPath 'New-PowerBILiveSafetyPlan.ps1') -OperationType Mutating -DryRun -Json | ConvertFrom-Json
        $plan.schema | Should Be 'codex.powerbi.liveSafetyPlan.v1'
        $plan.mode | Should Be 'DryRun'
        $plan.allowedToExecute | Should Be $false
        ($plan.guardrails -join ' ') | Should Match 'No SaveChanges'
        ($plan.guardrails -join ' ') | Should Match 'No publish'
        ($plan.guardrails -join ' ') | Should Match 'No credential'
    }

    It 'reports live-vs-repo drift as unavailable when no live endpoint exists' {
        $drift = & (Join-Path $scriptsPath 'Compare-PowerBILiveRepoModel.ps1') -Path $samplePath -RequireSingle -Json | ConvertFrom-Json
        $drift.schema | Should Be 'codex.powerbi.liveRepoReconciliation.v1'
        (@('LiveUnavailable','NoDrift','DriftDetected') -contains $drift.liveStatus) | Should Be $true
        $drift.liveStatus | Should Not Be 'NotAvailable'
        $drift.repoMeasureCount | Should Be 5
        ($drift.repoTableCount -ge 1) | Should Be $true
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

    It 'creates the 38-USP AI/KI expansion artifacts' {
        $agentic = & (Join-Path $scriptsPath 'New-PowerBIAgenticRemediationPlan.ps1') -Path $samplePath -Json | ConvertFrom-Json
        $outcome = & (Join-Path $scriptsPath 'New-PowerBIBusinessOutcomeSimulator.ps1') -Path $samplePath -Json | ConvertFrom-Json
        $semantic = & (Join-Path $scriptsPath 'New-PowerBISemanticLayerAutopilot.ps1') -Path $samplePath -Json | ConvertFrom-Json
        $override = & (Join-Path $scriptsPath 'New-PowerBIHumanOverrideLearning.ps1') -Path $samplePath -Json | ConvertFrom-Json
        $conflicts = & (Join-Path $scriptsPath 'New-PowerBICrossReportKpiConflictDetector.ps1') -Path $samplePath -ComparisonPath $samplePath -Json | ConvertFrom-Json
        $impactGate = & (Join-Path $scriptsPath 'New-PowerBIPBIPChangeImpactGate.ps1') -Path $samplePath -Json | ConvertFrom-Json
        $fixtures = & (Join-Path $scriptsPath 'New-PowerBISemanticTestFixtureGenerator.ps1') -Path $samplePath -OutputDirectory (Join-Path $pluginRoot 'tmp/pester-semantic-fixtures') -Json | ConvertFrom-Json
        $signoff = & (Join-Path $scriptsPath 'New-PowerBIKpiOwnerSignoffWorkflow.ps1') -Path $samplePath -Json | ConvertFrom-Json
        $blastRadius = & (Join-Path $scriptsPath 'New-PowerBIRefreshBlastRadiusAnalyzer.ps1') -Path $samplePath -Json | ConvertFrom-Json
        $exposure = & (Join-Path $scriptsPath 'New-PowerBISensitiveDataExposureMap.ps1') -Path $samplePath -Json | ConvertFrom-Json
        $capacityPlan = & (Join-Path $scriptsPath 'New-PowerBICapacityMitigationPlanner.ps1') -Path $samplePath -Json | ConvertFrom-Json
        $retirement = & (Join-Path $scriptsPath 'New-PowerBIReportRetirementAdvisor.ps1') -Path $samplePath -Json | ConvertFrom-Json
        $evidence = & (Join-Path $scriptsPath 'New-PowerBILiveValidationEvidenceRecorder.ps1') -Path $samplePath -OutputDirectory (Join-Path $pluginRoot 'tmp/pester-live-validation-evidence') -Json | ConvertFrom-Json
        $drift = & (Join-Path $scriptsPath 'New-PowerBISemanticContractDriftMonitor.ps1') -Path $samplePath -Json | ConvertFrom-Json
        $persona = & (Join-Path $scriptsPath 'New-PowerBIRlsPersonaCoverageMatrix.ps1') -Path $samplePath -Json | ConvertFrom-Json

        $agentic.schema | Should Be 'codex.powerbi.agenticRemediationPlan.v1'
        $outcome.schema | Should Be 'codex.powerbi.businessOutcomeSimulator.v1'
        $semantic.schema | Should Be 'codex.powerbi.semanticLayerAutopilot.v1'
        $override.schema | Should Be 'codex.powerbi.humanOverrideLearning.v1'
        $conflicts.schema | Should Be 'codex.powerbi.crossReportKpiConflicts.v1'
        $impactGate.schema | Should Be 'codex.powerbi.pbipChangeImpactGate.v1'
        $fixtures.schema | Should Be 'codex.powerbi.semanticTestFixtureGenerator.v1'
        $signoff.schema | Should Be 'codex.powerbi.kpiOwnerSignoffWorkflow.v1'
        $blastRadius.schema | Should Be 'codex.powerbi.refreshBlastRadius.v1'
        $exposure.schema | Should Be 'codex.powerbi.sensitiveDataExposureMap.v1'
        $capacityPlan.schema | Should Be 'codex.powerbi.capacityMitigationPlanner.v1'
        $retirement.schema | Should Be 'codex.powerbi.reportRetirementAdvisor.v1'
        $evidence.schema | Should Be 'codex.powerbi.liveValidationEvidenceRecorder.v1'
        $drift.schema | Should Be 'codex.powerbi.semanticContractDriftMonitor.v1'
        $persona.schema | Should Be 'codex.powerbi.rlsPersonaCoverageMatrix.v1'
        $agentic.itemCount | Should BeGreaterThan 0
        $semantic.metricCount | Should Be 5
        $override.status | Should Be 'NeedsOverrideInput'
        $fixtures.expectationCount | Should BeGreaterThan 0
        $signoff.signoffItemCount | Should BeGreaterThan 0
        $capacityPlan.mitigationCount | Should BeGreaterThan 0
    }

    It 'creates the 39-artifact Max AI review package' {
        $review = & (Join-Path $scriptsPath 'Invoke-PowerBIMaxAIReview.ps1') -Path $samplePath -OutputDirectory (Join-Path $pluginRoot 'tmp/pester-max-ai')
        $review.ArtifactCount | Should Be 39
        (Test-Path -LiteralPath $review.Index) | Should Be $true
        (Test-Path -LiteralPath (Join-Path $pluginRoot 'tmp/pester-max-ai/trust-debt-ledger.json')) | Should Be $true
        (Test-Path -LiteralPath (Join-Path $pluginRoot 'tmp/pester-max-ai/usage-trust-matrix.json')) | Should Be $true
        (Test-Path -LiteralPath (Join-Path $pluginRoot 'tmp/pester-max-ai/agentic-remediation-plan.json')) | Should Be $true
        (Test-Path -LiteralPath (Join-Path $pluginRoot 'tmp/pester-max-ai/ai-governance-evidence-pack/summary.json')) | Should Be $true
        (Test-Path -LiteralPath (Join-Path $pluginRoot 'tmp/pester-max-ai/autonomous-qa-lab/summary.json')) | Should Be $true
        (Test-Path -LiteralPath (Join-Path $pluginRoot 'tmp/pester-max-ai/pbip-change-impact-gate.json')) | Should Be $true
        (Test-Path -LiteralPath (Join-Path $pluginRoot 'tmp/pester-max-ai/semantic-test-fixtures/measure-expectations.json')) | Should Be $true
        (Test-Path -LiteralPath (Join-Path $pluginRoot 'tmp/pester-max-ai/kpi-owner-signoff.json')) | Should Be $true
        (Test-Path -LiteralPath (Join-Path $pluginRoot 'tmp/pester-max-ai/refresh-blast-radius.json')) | Should Be $true
        (Test-Path -LiteralPath (Join-Path $pluginRoot 'tmp/pester-max-ai/sensitive-data-exposure.json')) | Should Be $true
        (Test-Path -LiteralPath (Join-Path $pluginRoot 'tmp/pester-max-ai/capacity-mitigation-plan.json')) | Should Be $true
        (Test-Path -LiteralPath (Join-Path $pluginRoot 'tmp/pester-max-ai/report-retirement-advisor.json')) | Should Be $true
        (Test-Path -LiteralPath (Join-Path $pluginRoot 'tmp/pester-max-ai/live-validation-evidence/summary.json')) | Should Be $true
        (Test-Path -LiteralPath (Join-Path $pluginRoot 'tmp/pester-max-ai/semantic-contract-drift.json')) | Should Be $true
        (Test-Path -LiteralPath (Join-Path $pluginRoot 'tmp/pester-max-ai/rls-persona-coverage.json')) | Should Be $true
    }

    It 'creates enterprise USP governance artifacts' {
        $trustDebt = & (Join-Path $scriptsPath 'New-PowerBITrustDebtLedger.ps1') -Path $samplePath -Json | ConvertFrom-Json
        $incident = & (Join-Path $scriptsPath 'New-PowerBIKpiIncidentReport.ps1') -Path $samplePath -Json | ConvertFrom-Json
        $rls = & (Join-Path $scriptsPath 'Test-PowerBIRlsLeakage.ps1') -Path $samplePath -Json | ConvertFrom-Json
        $capacity = & (Join-Path $scriptsPath 'New-PowerBIFabricCapacityRiskForecast.ps1') -Path $samplePath -Json | ConvertFrom-Json
        $duplicates = & (Join-Path $scriptsPath 'Find-PowerBIMetricDuplicates.ps1') -Path $samplePath -Json | ConvertFrom-Json
        $usage = & (Join-Path $scriptsPath 'Import-PowerBIUsageSignals.ps1') -Path $samplePath -Json | ConvertFrom-Json
        $usageTrust = & (Join-Path $scriptsPath 'New-PowerBIUsageTrustMatrix.ps1') -Path $samplePath -Json | ConvertFrom-Json

        $trustDebt.schema | Should Be 'codex.powerbi.trustDebtLedger.v1'
        $incident.schema | Should Be 'codex.powerbi.kpiIncidentReport.v1'
        $rls.schema | Should Be 'codex.powerbi.rlsLeakage.v1'
        $capacity.schema | Should Be 'codex.powerbi.fabricCapacityRiskForecast.v1'
        $duplicates.schema | Should Be 'codex.powerbi.metricDuplicates.v1'
        $usage.schema | Should Be 'codex.powerbi.usageSignals.v1'
        $usageTrust.schema | Should Be 'codex.powerbi.usageTrustMatrix.v1'
        $trustDebt.debtItemCount | Should Be 5
        $incident.affectedMeasures.Count | Should BeGreaterThan 0
        $usageTrust.metricCount | Should Be 5
    }

    It 'reports PBIP roundtrip structure checks as machine-readable JSON' {
        $pbipRoot = Join-Path $pluginRoot 'tmp/pester-pbip-roundtrip'
        $semanticRoot = Join-Path $pbipRoot 'Demo.SemanticModel'
        $reportRoot = Join-Path $pbipRoot 'Demo.Report'
        New-Item -ItemType Directory -Force -Path $semanticRoot | Out-Null
        New-Item -ItemType Directory -Force -Path $reportRoot | Out-Null
        Set-Content -LiteralPath (Join-Path $pbipRoot 'Demo.pbip') -Value '{}' -Encoding UTF8
        Set-Content -LiteralPath (Join-Path $semanticRoot 'model.tmdl') -Value 'model Demo' -Encoding UTF8
        Set-Content -LiteralPath (Join-Path $semanticRoot '.platform') -Value '{}' -Encoding UTF8
        Set-Content -LiteralPath (Join-Path $reportRoot 'definition.pbir') -Value '{}' -Encoding UTF8

        $structure = & (Join-Path $scriptsPath 'Get-PowerBIPBIPStructure.ps1') -Path $pbipRoot -Json | ConvertFrom-Json
        $structure.schema | Should Be 'codex.powerbi.pbipStructure.v1'
        $structure.roundtripStatus | Should Be 'Ready'
        @($structure.checks).Count | Should BeGreaterThan 4
    }

    It 'creates a PBIX compile workflow warning when pbi-tools is unavailable or structure is incomplete' {
        $pbipRoot = Join-Path $pluginRoot 'tmp/pester-pbip-compile'
        New-Item -ItemType Directory -Force -Path $pbipRoot | Out-Null
        $pbipPath = Join-Path $pbipRoot 'Incomplete.pbip'
        Set-Content -LiteralPath $pbipPath -Value '{}' -Encoding UTF8

        $workflow = & (Join-Path $scriptsPath 'New-PowerBIPBIXCompileWorkflow.ps1') -PbipPath $pbipPath -OutputPbix (Join-Path $pbipRoot 'Candidate.pbix') -Json | ConvertFrom-Json
        $workflow.schema | Should Be 'codex.powerbi.pbixCompileWorkflow.v1'
        $workflow.status | Should Be 'Warning'
        $workflow.pbipStructure.roundtripStatus | Should Be 'Incomplete'
        @($workflow.validationPlan).Count | Should BeGreaterThan 2
    }

    It 'emits governance policy and release gate machine-readable warning fields' {
        $policy = & (Join-Path $scriptsPath 'New-PowerBIGovernancePolicyPack.ps1') -Json | ConvertFrom-Json
        $gate = & (Join-Path $scriptsPath 'New-PowerBITrustReleaseGate.ps1') -Path $samplePath -Json | ConvertFrom-Json

        $policy.gatePolicy.machineReadableResultsRequired | Should Be $true
        @($policy.rules | Where-Object id -eq 'semantic-tests-pending').Count | Should Be 1
        $gate.schema | Should Be 'codex.powerbi.trustReleaseGate.v2'
        $gate.machineReadable | Should Be $true
        $gate.pendingSemanticTestCount | Should BeGreaterThan 0
        @($gate.checks | Where-Object id -eq 'fixes.openP1').Count | Should Be 1
        @($gate.checks | Where-Object id -eq 'live.availability').Count | Should Be 1
    }
}

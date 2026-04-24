param([string]$Path = ".", [string]$OutputDirectory = "powerbi-innovation-review")
$ErrorActionPreference = 'Stop'
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$resolvedOut = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputDirectory)
New-Item -ItemType Directory -Force -Path $resolvedOut | Out-Null
$outputs = [ordered]@{
    GuidedFixPlan = Join-Path $resolvedOut 'guided-fix-plan.md'
    MeasureLineageImpact = Join-Path $resolvedOut 'measure-lineage-impact.md'
    MeasureTestPlan = Join-Path $resolvedOut 'measure-test-plan.md'
    PerformanceAdvisor = Join-Path $resolvedOut 'performance-advisor.md'
    ReportUXCritic = Join-Path $resolvedOut 'report-ux-critic.md'
    ExecutiveExplainabilityPack = Join-Path $resolvedOut 'executive-explainability-pack.md'
    GovernanceScorecard = Join-Path $resolvedOut 'governance-scorecard.md'
    CopilotReadiness = Join-Path $resolvedOut 'copilot-readiness.md'
    ReleaseChecklist = Join-Path $resolvedOut 'release-checklist.md'
    BusinessSemanticLayer = Join-Path $resolvedOut 'business-semantic-layer.md'
    KpiTrustScore = Join-Path $resolvedOut 'kpi-trust-score.md'
    DecisionRiskAssistant = Join-Path $resolvedOut 'decision-risk-assistant.md'
    ReportNarrativeCritic = Join-Path $resolvedOut 'report-narrative-critic.md'
    CopilotOptimization = Join-Path $resolvedOut 'copilot-optimization.md'
    DaxFixSimulation = Join-Path $resolvedOut 'dax-fix-simulation.md'
    VisualMeasureImpactMap = Join-Path $resolvedOut 'visual-measure-impact-map.md'
    TrustReleaseGate = Join-Path $resolvedOut 'trust-release-gate.md'
    ModelBestPractices = Join-Path $resolvedOut 'model-best-practices.md'
    ExternalToolsReview = Join-Path $resolvedOut 'external-tools'
}
& (Join-Path $scriptRoot 'New-PowerBIGuidedFixPlan.ps1') -Path $Path -OutputPath $outputs.GuidedFixPlan | Out-Null
& (Join-Path $scriptRoot 'New-PowerBIMeasureLineageImpact.ps1') -Path $Path -OutputPath $outputs.MeasureLineageImpact | Out-Null
& (Join-Path $scriptRoot 'New-PowerBIMeasureTestPlan.ps1') -Path $Path -OutputPath $outputs.MeasureTestPlan | Out-Null
& (Join-Path $scriptRoot 'New-PowerBIPerformanceAdvisor.ps1') -Path $Path -OutputPath $outputs.PerformanceAdvisor | Out-Null
& (Join-Path $scriptRoot 'New-PowerBIReportUXCritic.ps1') -Path $Path -OutputPath $outputs.ReportUXCritic | Out-Null
& (Join-Path $scriptRoot 'New-PowerBIExecutiveExplainabilityPack.ps1') -Path $Path -OutputPath $outputs.ExecutiveExplainabilityPack | Out-Null
& (Join-Path $scriptRoot 'New-PowerBIModelGovernanceScorecard.ps1') -Path $Path -OutputPath $outputs.GovernanceScorecard | Out-Null
& (Join-Path $scriptRoot 'Test-PowerBICopilotReadiness.ps1') -Path $Path -OutputPath $outputs.CopilotReadiness | Out-Null
& (Join-Path $scriptRoot 'New-PowerBIReleaseChecklist.ps1') -Path $Path -OutputPath $outputs.ReleaseChecklist | Out-Null
& (Join-Path $scriptRoot 'New-PowerBIBusinessSemanticLayer.ps1') -Path $Path -OutputPath $outputs.BusinessSemanticLayer | Out-Null
& (Join-Path $scriptRoot 'New-PowerBIKpiTrustScore.ps1') -Path $Path -OutputPath $outputs.KpiTrustScore | Out-Null
& (Join-Path $scriptRoot 'New-PowerBIDecisionRiskAssistant.ps1') -Path $Path -OutputPath $outputs.DecisionRiskAssistant | Out-Null
& (Join-Path $scriptRoot 'New-PowerBIReportNarrativeCritic.ps1') -Path $Path -OutputPath $outputs.ReportNarrativeCritic | Out-Null
& (Join-Path $scriptRoot 'Optimize-PowerBICopilotModel.ps1') -Path $Path -OutputPath $outputs.CopilotOptimization | Out-Null
& (Join-Path $scriptRoot 'New-PowerBIDaxFixSimulation.ps1') -Path $Path -OutputPath $outputs.DaxFixSimulation | Out-Null
& (Join-Path $scriptRoot 'New-PowerBIVisualMeasureImpactMap.ps1') -Path $Path -OutputPath $outputs.VisualMeasureImpactMap | Out-Null
& (Join-Path $scriptRoot 'New-PowerBITrustReleaseGate.ps1') -Path $Path -OutputPath $outputs.TrustReleaseGate | Out-Null
& (Join-Path $scriptRoot 'Test-PowerBIModelBestPractices.ps1') -Path $Path -OutputPath $outputs.ModelBestPractices | Out-Null
& (Join-Path $scriptRoot 'Invoke-PowerBIExternalToolsReview.ps1') -Path $Path -OutputDirectory $outputs.ExternalToolsReview | Out-Null
$index = @('# Power BI Innovation Review', '', ('Source: `{0}`' -f (Resolve-Path -LiteralPath $Path).Path), ('Generated: {0}' -f (Get-Date).ToString('s')), '', '## Artifacts') + @($outputs.GetEnumerator() | ForEach-Object { '- {0}: `{1}`' -f $_.Key, $_.Value })
$indexPath = Join-Path $resolvedOut 'README.md'
Set-Content -LiteralPath $indexPath -Value (($index -join [Environment]::NewLine) + [Environment]::NewLine) -Encoding UTF8
[pscustomobject]@{ OutputDirectory = $resolvedOut; Index = $indexPath }

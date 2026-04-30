param([string]$Path='.', [string]$OutputDirectory='powerbi-max-ai-review')
$ErrorActionPreference='Stop'
$scriptRoot=Split-Path -Parent $MyInvocation.MyCommand.Path
$out=$ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputDirectory)
New-Item -ItemType Directory -Force -Path $out|Out-Null
$outputs=[ordered]@{
 FixUntilGreen=Join-Path $out 'fix-until-green.md'; CopilotEvaluator=Join-Path $out 'semantic-copilot-evaluator.md'; DataContract=Join-Path $out 'data-contract.md'; FabricDeploymentRisk=Join-Path $out 'fabric-deployment-risk.md'; VisualIntent=Join-Path $out 'visual-intent.md'; RootCauseGraph=Join-Path $out 'root-cause-graph.md'; KpiTrustTwin=Join-Path $out 'kpi-trust-twin.json'; ReviewMemory=Join-Path $out 'review-memory.json'; ReviewMemoryStore=Join-Path $out 'review-memory-store.json'; NaturalLanguageAuthoring=Join-Path $out 'natural-language-authoring.json'; GovernanceRuleMiner=Join-Path $out 'governance-rule-miner.md'; ExplainableDaxRefactoring=Join-Path $out 'explainable-dax-refactoring.md'; ReportDecisionSimulator=Join-Path $out 'report-decision-simulator.md'
}
& (Join-Path $scriptRoot 'Invoke-PowerBIFixUntilGreenLoop.ps1') -Path $Path -OutputPath $outputs.FixUntilGreen|Out-Null
& (Join-Path $scriptRoot 'Test-PowerBISemanticModelCopilotEvaluator.ps1') -Path $Path -OutputPath $outputs.CopilotEvaluator|Out-Null
& (Join-Path $scriptRoot 'New-PowerBIDataContract.ps1') -Path $Path -OutputPath $outputs.DataContract|Out-Null
& (Join-Path $scriptRoot 'New-PowerBIFabricDeploymentRiskSimulator.ps1') -Path $Path -OutputPath $outputs.FabricDeploymentRisk|Out-Null
& (Join-Path $scriptRoot 'New-PowerBIVisualIntentAnalyzer.ps1') -Path $Path -OutputPath $outputs.VisualIntent|Out-Null
& (Join-Path $scriptRoot 'New-PowerBIBrokenMeasureRootCauseGraph.ps1') -Path $Path -OutputPath $outputs.RootCauseGraph|Out-Null
& (Join-Path $scriptRoot 'New-PowerBIKpiTrustTwin.ps1') -Path $Path -Json -OutputPath $outputs.KpiTrustTwin|Out-Null
& (Join-Path $scriptRoot 'Update-PowerBIReviewMemory.ps1') -Path $Path -MemoryPath $outputs.ReviewMemoryStore -Json -OutputPath $outputs.ReviewMemory|Out-Null
& (Join-Path $scriptRoot 'New-PowerBINaturalLanguagePBIPAuthoring.ps1') -Path $Path -Intent 'Create an executive overview with the most important risk and trust KPIs.' -Json -OutputPath $outputs.NaturalLanguageAuthoring|Out-Null
& (Join-Path $scriptRoot 'New-PowerBIGovernanceRuleMiner.ps1') -Path $Path -OutputPath $outputs.GovernanceRuleMiner|Out-Null
& (Join-Path $scriptRoot 'New-PowerBIExplainableDaxRefactoring.ps1') -Path $Path -OutputPath $outputs.ExplainableDaxRefactoring|Out-Null
& (Join-Path $scriptRoot 'New-PowerBIReportDecisionSimulator.ps1') -Path $Path -OutputPath $outputs.ReportDecisionSimulator|Out-Null
$index=@('# Power BI Max AI Review','',('Source: `{0}`' -f (Resolve-Path -LiteralPath $Path).Path),('Generated: {0}' -f (Get-Date).ToString('s')),'','## Artifacts')+@($outputs.GetEnumerator()|ForEach-Object{ '- {0}: `{1}`' -f $_.Key, $_.Value })
$indexPath=Join-Path $out 'README.md'; Set-Content -LiteralPath $indexPath -Value (($index -join [Environment]::NewLine)+[Environment]::NewLine) -Encoding UTF8
[pscustomobject]@{OutputDirectory=$out;Index=$indexPath;ArtifactCount=12}

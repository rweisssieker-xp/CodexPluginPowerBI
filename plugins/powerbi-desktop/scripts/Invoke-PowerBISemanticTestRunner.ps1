param(
    [string]$Path = ".",
    [string]$ExpectationsPath,
    [string]$OutputPath,
    [switch]$Json
)

$ErrorActionPreference = 'Stop'
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$catalog = & (Join-Path $scriptRoot 'New-PowerBIMetricCatalog.ps1') -Path $Path -Json | ConvertFrom-Json

$expectations = @()
if ($ExpectationsPath -and (Test-Path -LiteralPath $ExpectationsPath)) {
    $loaded = Get-Content -Raw -LiteralPath $ExpectationsPath | ConvertFrom-Json
    $expectations = @($loaded.tests)
}

$tests = New-Object System.Collections.Generic.List[object]
foreach ($metric in @($catalog.metrics)) {
    $matching = @($expectations | Where-Object { $_.measure -eq $metric.name })
    if ($matching.Count -eq 0) {
        $tests.Add([pscustomobject]@{
            measure = $metric.name
            status = 'Generated'
            filterContext = 'All'
            expected = '[TODO]'
            tolerance = 0
            result = 'NotRun'
            detail = 'No expectation supplied. Generated semantic test placeholder.'
        })
    }
    else {
        foreach ($test in $matching) {
            $tests.Add([pscustomobject]@{
                measure = $metric.name
                status = 'Configured'
                filterContext = $test.filterContext
                expected = $test.expected
                tolerance = $test.tolerance
                result = 'PendingLiveDax'
                detail = 'Configured test requires live DAX execution or captured result input.'
            })
        }
    }
}

$failed = @($tests | Where-Object { $_.result -eq 'Failed' })
$result = [pscustomobject]@{
    schema = 'codex.powerbi.semanticTestRunner.v1'
    generated = (Get-Date).ToString('s')
    source = (Resolve-Path -LiteralPath $Path).Path
    testCount = $tests.Count
    failedCount = $failed.Count
    tests = $tests.ToArray()
}

if ($Json) {
    $text = $result | ConvertTo-Json -Depth 8
    if ($OutputPath) { Set-Content -LiteralPath $OutputPath -Value $text -Encoding UTF8 }
    $text
    return
}
$lines = @('# Semantic Test Runner', '', "Tests: $($tests.Count)", "Failed: $($failed.Count)", '', '## Tests') + @($tests | ForEach-Object { "- [$($_.result)] $($_.measure): $($_.detail)" })
$content = ($lines -join [Environment]::NewLine) + [Environment]::NewLine
if ($OutputPath) { Set-Content -LiteralPath $OutputPath -Value $content -Encoding UTF8 }
$content

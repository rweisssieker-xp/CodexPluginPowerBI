param(
    [string]$Path = ".",
    [string]$ExpectationsPath,
    [string]$OutputPath,
    [switch]$Json
)

$ErrorActionPreference = 'Stop'
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$catalog = & (Join-Path $scriptRoot 'New-PowerBIMetricCatalog.ps1') -Path $Path -Json | ConvertFrom-Json

if (-not $ExpectationsPath) {
    $ExpectationsPath = Join-Path (Resolve-Path -LiteralPath $Path).Path 'measure-expectations.json'
}

if (-not (Test-Path -LiteralPath $ExpectationsPath)) {
    $template = [pscustomobject]@{
        schema = 'codex.powerbi.measureExpectations.v1'
        expectations = @($catalog.metrics | Select-Object -First 3 | ForEach-Object {
            [pscustomobject]@{ measure = $_.name; expected = $null; tolerance = 0; filters = [pscustomobject]@{} }
        })
    }
    $result = [pscustomobject]@{
        schema = 'codex.powerbi.measureExpectationResults.v1'
        generated = (Get-Date).ToString('s')
        status = 'TemplateCreated'
        expectationsPath = $ExpectationsPath
        checkCount = 0
        passedCount = 0
        failedCount = 0
        checks = @()
    }
    $template | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $ExpectationsPath -Encoding UTF8
}
else {
    $expectations = Get-Content -Raw -LiteralPath $ExpectationsPath | ConvertFrom-Json
    $checks = foreach ($expectation in @($expectations.expectations)) {
        $metric = @($catalog.metrics | Where-Object { $_.name -eq $expectation.measure } | Select-Object -First 1)
        $exists = $metric.Count -gt 0
        [pscustomobject]@{
            measure = $expectation.measure
            passed = $exists
            expected = $expectation.expected
            tolerance = $expectation.tolerance
            filters = $expectation.filters
            daxQuery = if ($exists) { ('EVALUATE ROW("{0}", [{0}])' -f $expectation.measure) } else { $null }
            detail = if ($exists) { 'Expectation is bound to a known measure. Execute DAX query in live validation to compare value.' } else { 'Measure not found in catalog.' }
        }
    }
    $result = [pscustomobject]@{
        schema = 'codex.powerbi.measureExpectationResults.v1'
        generated = (Get-Date).ToString('s')
        status = 'Validated'
        expectationsPath = $ExpectationsPath
        checkCount = @($checks).Count
        passedCount = @($checks | Where-Object { $_.passed }).Count
        failedCount = @($checks | Where-Object { -not $_.passed }).Count
        checks = @($checks)
    }
}

if ($Json) {
    $text = $result | ConvertTo-Json -Depth 10
    if ($OutputPath) { Set-Content -LiteralPath $OutputPath -Value $text -Encoding UTF8 }
    $text
    return
}

$md = New-Object System.Collections.Generic.List[string]
$md.Add('# Power BI Measure Expectations')
$md.Add('')
$md.Add(('Status: {0}' -f $result.status))
$md.Add(('Expectations path: `{0}`' -f $result.expectationsPath))
$md.Add(('Checks: {0}' -f $result.checkCount))
$md.Add(('Passed: {0}' -f $result.passedCount))
$md.Add(('Failed: {0}' -f $result.failedCount))
$md.Add('')
foreach ($check in @($result.checks)) {
    $md.Add(('## [{0}] {1}' -f ($(if ($check.passed) { 'Pass' } else { 'Fail' })), $check.measure))
    $md.Add(('- Detail: {0}' -f $check.detail))
    if ($check.daxQuery) {
        $md.Add('')
        $md.Add('```DAX')
        $md.Add($check.daxQuery)
        $md.Add('```')
    }
    $md.Add('')
}
$content = ($md -join [Environment]::NewLine) + [Environment]::NewLine
if ($OutputPath) { Set-Content -LiteralPath $OutputPath -Value $content -Encoding UTF8 }
$content

param(
    [string]$Server,
    [string]$InputPath,
    [string]$OutputDirectory = (Join-Path (Get-Location) 'powerbi-ai-forecast'),
    [int]$ForecastYear = 2026,
    [int]$StartMonth = 5,
    [int]$EndMonth = 12,
    [switch]$DryRun,
    [switch]$Json
)

$ErrorActionPreference = 'Stop'

function ConvertTo-OutputJson {
    param([Parameter(Mandatory = $true)]$InputObject)

    $InputObject | ConvertTo-Json -Depth 12
}

function Find-PythonExecutable {
    $commands = @('python', 'py')
    foreach ($command in $commands) {
        if (Get-Command $command -ErrorAction SilentlyContinue) {
            return $command
        }
    }
    throw 'Python was not found on PATH. Install Python 3 or add it to PATH, then retry.'
}

if ($StartMonth -lt 1 -or $StartMonth -gt 12) {
    throw 'StartMonth must be between 1 and 12.'
}
if ($EndMonth -lt 1 -or $EndMonth -gt 12) {
    throw 'EndMonth must be between 1 and 12.'
}
if ($StartMonth -gt $EndMonth) {
    throw 'StartMonth must be less than or equal to EndMonth.'
}

$fromYear = $ForecastYear - 5
$segmentQuery = @"
EVALUATE
FILTER(
    SUMMARIZECOLUMNS(
        'dw Custtable'[CustHierachy01],
        'dw Inventtable'[ProductLineHerachy01],
        'Dates'[Calendar Year],
        'Dates'[Calendar MonthNumber],
        'Dates'[Calendar Month Year],
        'Dates'[MonthStart],
        FILTER(
            ALL('Dates'[Calendar Year]),
            'Dates'[Calendar Year] >= $fromYear
                && 'Dates'[Calendar Year] <= $ForecastYear
        ),
        "Sales", [_SumSalesTotal],
        "Qty", [_SumQTY],
        "Budget", [_SumBudgetAmount],
        "ForecastRoll", [_SumForecastAmountRoll],
        "Backlog", [_BacklogAmountMst]
    ),
    NOT (ISBLANK([Sales]))
        || NOT (ISBLANK([Qty]))
        || NOT (ISBLANK([Budget]))
        || NOT (ISBLANK([ForecastRoll]))
        || NOT (ISBLANK([Backlog]))
)
ORDER BY
    'dw Custtable'[CustHierachy01],
    'dw Inventtable'[ProductLineHerachy01],
    'Dates'[Calendar Year],
    'Dates'[Calendar MonthNumber]
"@

$plan = [pscustomobject]@{
    schema = 'codex.powerbi.aiForecast.plan.v1'
    forecastYear = $ForecastYear
    startMonth = $StartMonth
    endMonth = $EndMonth
    outputDirectory = $OutputDirectory
    queries = [pscustomobject]@{
        segmentMonthly = $segmentQuery
    }
}

if ($DryRun) {
    if ($Json) {
        ConvertTo-OutputJson -InputObject $plan
        return
    }
    return $plan
}

if (-not (Test-Path -LiteralPath $OutputDirectory)) {
    New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
}

if (-not $InputPath) {
    $liveDaxScript = Join-Path $PSScriptRoot 'Invoke-PowerBILiveDaxQuery.ps1'
    $liveArgs = @(
        '-Query', $segmentQuery,
        '-Json'
    )
    if ($Server) {
        $liveArgs += @('-Server', $Server)
    }

    $segmentJson = & $liveDaxScript @liveArgs
    if ($LASTEXITCODE) {
        exit $LASTEXITCODE
    }

    $InputPath = Join-Path $OutputDirectory 'segment-monthly.json'
    $segmentJson | Set-Content -LiteralPath $InputPath -Encoding UTF8
}

$resolvedInputPath = Resolve-Path -LiteralPath $InputPath
$workerPath = Join-Path $PSScriptRoot 'support/powerbi_ai_forecast.py'
$python = Find-PythonExecutable
$pythonArgs = @()
if ($python -eq 'py') {
    $pythonArgs += '-3'
}
$pythonArgs += @(
    $workerPath,
    '--input', $resolvedInputPath.Path,
    '--output-directory', $OutputDirectory,
    '--forecast-year', $ForecastYear,
    '--start-month', $StartMonth,
    '--end-month', $EndMonth
)

$workerJson = & $python @pythonArgs
if ($LASTEXITCODE) {
    exit $LASTEXITCODE
}

$result = $workerJson | ConvertFrom-Json
$result | Add-Member -NotePropertyName inputPath -NotePropertyValue $resolvedInputPath.Path -Force

if ($Json) {
    ConvertTo-OutputJson -InputObject $result
    return
}

$result

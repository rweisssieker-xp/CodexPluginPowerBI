Add-Type -Path 'C:\Program Files\DAX Studio\bin\Microsoft.AnalysisServices.Tabular.dll'

$server = [Microsoft.AnalysisServices.Tabular.Server]::new()
$server.Connect('localhost:57411')

try {
    $database = $server.Databases[0]
    $model = $database.Model
    $projects = $model.Tables.Find('Projects')
    if (-not $projects) {
        throw 'Table Projects was not found in the open model.'
    }

    $measureDefinitions = @(
        @{
            Name = '_Projects Without Recent Status'
            Expression = @"
COUNTROWS(
    FILTER(
        'Projects',
        ISBLANK('Projects'[gbl_laststatusupdate])
            || 'Projects'[gbl_laststatusupdate] < TODAY() - 14
    )
)
"@
            FormatString = '#,0'
            Description = 'Counts projects whose last status update is blank or older than 14 days.'
        },
        @{
            Name = '_Status Report Compliance %'
            Expression = @"
DIVIDE(
    COUNTROWS(
        FILTER(
            'Projects',
            NOT ISBLANK('Projects'[gbl_laststatusupdate])
                && 'Projects'[gbl_laststatusupdate] >= TODAY() - 14
        )
    ),
    COUNTROWS('Projects'),
    0
)
"@
            FormatString = '0.0%'
            Description = 'Share of projects with a status update in the last 14 days.'
        },
        @{
            Name = '_Overdue Projects'
            Expression = @"
COUNTROWS(
    FILTER(
        'Projects',
        NOT ISBLANK('Projects'[Finish Date])
            && 'Projects'[Finish Date] < TODAY()
            && COALESCE('Projects'[Progress], 0) < 1
    )
)
"@
            FormatString = '#,0'
            Description = 'Counts projects past finish date that are not fully completed.'
        },
        @{
            Name = '_Projects Ending Next 30 Days'
            Expression = @"
COUNTROWS(
    FILTER(
        'Projects',
        NOT ISBLANK('Projects'[Finish Date])
            && 'Projects'[Finish Date] >= TODAY()
            && 'Projects'[Finish Date] <= TODAY() + 30
    )
)
"@
            FormatString = '#,0'
            Description = 'Counts projects with a planned finish date in the next 30 days.'
        },
        @{
            Name = '_Average Project Duration Days'
            Expression = @"
AVERAGEX(
    FILTER(
        'Projects',
        NOT ISBLANK('Projects'[Start Date])
            && NOT ISBLANK('Projects'[Finish Date])
    ),
    DATEDIFF('Projects'[Start Date], 'Projects'[Finish Date], DAY)
)
"@
            FormatString = '#,0'
            Description = 'Average planned project duration in days.'
        },
        @{
            Name = '_Project Progress %'
            Expression = @"
AVERAGE('Projects'[Progress])
"@
            FormatString = '0.0%'
            Description = 'Average project progress in the current filter context.'
        },
        @{
            Name = '_Projects At Risk by Progress'
            Expression = @"
COUNTROWS(
    FILTER(
        'Projects',
        NOT ISBLANK('Projects'[Finish Date])
            && 'Projects'[Finish Date] <= TODAY() + 30
            && COALESCE('Projects'[Progress], 0) < 0.8
    )
)
"@
            FormatString = '#,0'
            Description = 'Counts projects ending within 30 days with less than 80 percent progress.'
        },
        @{
            Name = '_Project Cost Variance %'
            Expression = @"
DIVIDE(
    SUM('Projects'[Actual Cost]) - SUM('Projects'[Budget Cost]),
    SUM('Projects'[Budget Cost]),
    0
)
"@
            FormatString = '0.0%'
            Description = 'Actual cost variance versus budget as a percentage.'
        },
        @{
            Name = '_Forecast Budget Overrun'
            Expression = @"
SUM('Projects'[Forecast Cost]) - SUM('Projects'[Budget Cost])
"@
            FormatString = '#,0.00'
            Description = 'Forecast cost above or below budget.'
        },
        @{
            Name = '_Forecast Budget Overrun %'
            Expression = @"
DIVIDE(
    [_Forecast Budget Overrun],
    SUM('Projects'[Budget Cost]),
    0
)
"@
            FormatString = '0.0%'
            Description = 'Forecast budget overrun as a percentage of budget.'
        },
        @{
            Name = '_Effort Variance'
            Expression = @"
SUM('Projects'[gbl_actualeffort]) - SUM('Projects'[Forecast Effort])
"@
            FormatString = '#,0.00'
            Description = 'Actual effort minus forecast effort.'
        },
        @{
            Name = '_Effort Burn Rate %'
            Expression = @"
DIVIDE(
    SUM('Projects'[gbl_actualeffort]),
    SUM('Projects'[Forecast Effort]),
    0
)
"@
            FormatString = '0.0%'
            Description = 'Actual effort consumed versus forecast effort.'
        }
    )

    foreach ($definition in $measureDefinitions) {
        $measure = $projects.Measures.Find($definition.Name)
        if (-not $measure) {
            $measure = [Microsoft.AnalysisServices.Tabular.Measure]::new()
            $measure.Name = $definition.Name
            $projects.Measures.Add($measure)
        }

        $measure.Expression = $definition.Expression.Trim()
        $measure.FormatString = $definition.FormatString
        $measure.Description = $definition.Description
        $measure.DisplayFolder = 'Business KPIs'
    }

    $model.SaveChanges()

    [pscustomobject]@{
        Server = 'localhost:57411'
        Database = $database.Name
        Table = 'Projects'
        Measures = $measureDefinitions.Name
    } | ConvertTo-Json -Depth 4
}
finally {
    $server.Disconnect()
}

Add-Type -Path 'C:\Program Files\DAX Studio\bin\Microsoft.AnalysisServices.Tabular.dll'

$server = [Microsoft.AnalysisServices.Tabular.Server]::new()
$server.Connect('localhost:57411')

try {
    $database = $server.Databases[0]
    $model = $database.Model
    $resources = $model.Tables.Find('Resources')
    if (-not $resources) {
        throw 'Table Resources was not found in the open model.'
    }

    $measureDefinitions = @(
        @{
            Name = '_Resource Demand Hours'
            Expression = "SUM('Resource Demand'[Forecast Demand])"
            FormatString = '#,0.00'
            Description = 'Forecast demand hours for resources in the current filter context.'
        },
        @{
            Name = '_Resource Demand Hours excl. ATOSS'
            Expression = "SUM('Resource Demand'[ForecastDemandWithoutAtossAbsent])"
            FormatString = '#,0.00'
            Description = 'Forecast demand hours excluding ATOSS absence demand.'
        },
        @{
            Name = '_Resource Capacity Gap Hours'
            Expression = "[_CapacityHoursNetto] - [_Resource Demand Hours]"
            FormatString = '#,0.00'
            Description = 'Net capacity minus forecast demand hours.'
        },
        @{
            Name = '_Resource Capacity Gap %'
            Expression = "DIVIDE([_Resource Capacity Gap Hours], [_CapacityHoursNetto], 0)"
            FormatString = '0.0%'
            Description = 'Capacity gap as share of net capacity.'
        },
        @{
            Name = '_Resources Overallocated'
            Expression = @"
COUNTROWS(
    FILTER(
        VALUES('Resources'[ResourceID]),
        [% Utilization] > 1
    )
)
"@
            FormatString = '#,0'
            Description = 'Counts resources with utilization above 100 percent.'
        },
        @{
            Name = '_Resources Critically Overallocated'
            Expression = @"
COUNTROWS(
    FILTER(
        VALUES('Resources'[ResourceID]),
        [% Utilization] > 1.2
    )
)
"@
            FormatString = '#,0'
            Description = 'Counts resources with utilization above 120 percent.'
        },
        @{
            Name = '_Resources Underutilized'
            Expression = @"
COUNTROWS(
    FILTER(
        VALUES('Resources'[ResourceID]),
        [% Utilization] > 0
            && [% Utilization] < 0.7
    )
)
"@
            FormatString = '#,0'
            Description = 'Counts resources with utilization below 70 percent but above zero.'
        },
        @{
            Name = '_Resources Without Demand'
            Expression = @"
COUNTROWS(
    FILTER(
        VALUES('Resources'[ResourceID]),
        COALESCE([_Resource Demand Hours], 0) = 0
    )
)
"@
            FormatString = '#,0'
            Description = 'Counts resources without forecast demand in the current filter context.'
        },
        @{
            Name = '_Resources Without Capacity'
            Expression = @"
COUNTROWS(
    FILTER(
        VALUES('Resources'[ResourceID]),
        COALESCE([_CapacityHoursNetto], 0) = 0
    )
)
"@
            FormatString = '#,0'
            Description = 'Counts resources without net capacity in the current filter context.'
        },
        @{
            Name = '_Resources With Demand No Capacity'
            Expression = @"
COUNTROWS(
    FILTER(
        VALUES('Resources'[ResourceID]),
        COALESCE([_Resource Demand Hours], 0) > 0
            && COALESCE([_CapacityHoursNetto], 0) = 0
    )
)
"@
            FormatString = '#,0'
            Description = 'Counts resources with demand but no net capacity.'
        },
        @{
            Name = '_Timesheet Coverage %'
            Expression = "DIVIDE([_TS-Hours], [_CapacityHoursNetto], 0)"
            FormatString = '0.0%'
            Description = 'Actual timesheet hours as share of net capacity.'
        },
        @{
            Name = '_Timesheet vs Demand Gap Hours'
            Expression = "[_TS-Hours] - [_Resource Demand Hours]"
            FormatString = '#,0.00'
            Description = 'Actual timesheet hours minus forecast demand hours.'
        },
        @{
            Name = '_Planned vs Actual Utilization Gap %'
            Expression = "DIVIDE([_TS-Hours], [_Resource Demand Hours], 0) - 1"
            FormatString = '0.0%'
            Description = 'Actual timesheet hours versus forecast demand, expressed as variance percentage.'
        },
        @{
            Name = '_Avg Demand per Resource'
            Expression = @"
AVERAGEX(
    VALUES('Resources'[ResourceID]),
    [_Resource Demand Hours]
)
"@
            FormatString = '#,0.00'
            Description = 'Average forecast demand hours per resource.'
        },
        @{
            Name = '_Avg Capacity per Resource'
            Expression = @"
AVERAGEX(
    VALUES('Resources'[ResourceID]),
    [_CapacityHoursNetto]
)
"@
            FormatString = '#,0.00'
            Description = 'Average net capacity hours per resource.'
        },
        @{
            Name = '_Avg Timesheet Hours per Resource'
            Expression = @"
AVERAGEX(
    VALUES('Resources'[ResourceID]),
    [_TS-Hours]
)
"@
            FormatString = '#,0.00'
            Description = 'Average actual timesheet hours per resource.'
        },
        @{
            Name = '_Available Capacity Hours'
            Expression = "MAX(0, [_Resource Capacity Gap Hours])"
            FormatString = '#,0.00'
            Description = 'Positive remaining capacity hours after forecast demand.'
        },
        @{
            Name = '_Overallocated Hours'
            Expression = "MAX(0, -[_Resource Capacity Gap Hours])"
            FormatString = '#,0.00'
            Description = 'Demand hours exceeding net capacity.'
        },
        @{
            Name = '_Overallocated Hours %'
            Expression = "DIVIDE([_Overallocated Hours], [_CapacityHoursNetto], 0)"
            FormatString = '0.0%'
            Description = 'Overallocated hours as share of net capacity.'
        },
        @{
            Name = '_Resources Missing Department'
            Expression = @"
COUNTROWS(
    FILTER(
        VALUES('Resources'[ResourceID]),
        ISBLANK(CALCULATE(SELECTEDVALUE('Resources'[DepartmentID])))
    )
)
"@
            FormatString = '#,0'
            Description = 'Counts resources without department assignment.'
        },
        @{
            Name = '_Resource Master Data Completeness %'
            Expression = @"
DIVIDE(
    COUNTROWS(
        FILTER(
            VALUES('Resources'[ResourceID]),
            NOT ISBLANK(CALCULATE(SELECTEDVALUE('Resources'[DepartmentID])))
                && NOT ISBLANK(CALCULATE(SELECTEDVALUE('Resources'[ResourceName])))
        )
    ),
    COUNTROWS(VALUES('Resources'[ResourceID])),
    0
)
"@
            FormatString = '0.0%'
            Description = 'Share of resources with core master data filled.'
        }
    )

    foreach ($definition in $measureDefinitions) {
        $measure = $resources.Measures.Find($definition.Name)
        if (-not $measure) {
            $measure = [Microsoft.AnalysisServices.Tabular.Measure]::new()
            $measure.Name = $definition.Name
            $resources.Measures.Add($measure)
        }

        $measure.Expression = $definition.Expression.Trim()
        $measure.FormatString = $definition.FormatString
        $measure.Description = $definition.Description
        $measure.DisplayFolder = 'Business KPIs'
        $measure.IsHidden = $false
    }

    $model.SaveChanges()

    [pscustomobject]@{
        Server = 'localhost:57411'
        Database = $database.Name
        Table = 'Resources'
        Measures = $measureDefinitions.Name
    } | ConvertTo-Json -Depth 4
}
finally {
    $server.Disconnect()
}

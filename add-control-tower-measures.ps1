Add-Type -Path 'C:\Program Files\DAX Studio\bin\Microsoft.AnalysisServices.Tabular.dll'

$server = [Microsoft.AnalysisServices.Tabular.Server]::new()
$server.Connect('localhost:57411')

try {
    $database = $server.Databases[0]
    $model = $database.Model
    $projects = $model.Tables.Find('Projects')
    $resources = $model.Tables.Find('Resources')

    if (-not $projects) { throw 'Table Projects was not found in the open model.' }
    if (-not $resources) { throw 'Table Resources was not found in the open model.' }

    $thresholdTableName = 'KPI Thresholds'
    $thresholdTable = $model.Tables.Find($thresholdTableName)
    if (-not $thresholdTable) {
        $thresholdTable = [Microsoft.AnalysisServices.Tabular.Table]::new()
        $thresholdTable.Name = $thresholdTableName
        $thresholdTable.Description = 'Disconnected threshold table used by Control Tower measures.'

        $partition = [Microsoft.AnalysisServices.Tabular.Partition]::new()
        $partition.Name = $thresholdTableName
        $partition.Source = [Microsoft.AnalysisServices.Tabular.CalculatedPartitionSource]@{
            Expression = @"
DATATABLE(
    "Threshold", STRING,
    "Value", DOUBLE,
    "Description", STRING,
    {
        { "StaleStatusDays", 14, "Maximum age in days for a current project status update" },
        { "DueSoonDays", 30, "Window in days for due-soon project checks" },
        { "LowProgressThreshold", 0.8, "Minimum expected progress for projects finishing soon" },
        { "ForecastVarianceThreshold", 0.15, "Forecast budget overrun percentage that indicates cost risk" },
        { "OverallocatedThreshold", 1.0, "Utilization threshold for overloaded resources" },
        { "CriticalOverallocatedThreshold", 1.2, "Utilization threshold for critically overloaded resources" },
        { "UnderutilizedThreshold", 0.7, "Utilization threshold for underutilized resources" },
        { "TimesheetCoverageLowThreshold", 0.7, "Low timesheet coverage threshold versus net capacity" },
        { "ForecastAccuracyWarningThreshold", 0.2, "Warning threshold for demand versus actual variance" }
    }
)
"@
        }
        $thresholdTable.Partitions.Add($partition)

        foreach ($columnInfo in @(
            @{ Name = 'Threshold'; Type = [Microsoft.AnalysisServices.Tabular.DataType]::String },
            @{ Name = 'Value'; Type = [Microsoft.AnalysisServices.Tabular.DataType]::Double },
            @{ Name = 'Description'; Type = [Microsoft.AnalysisServices.Tabular.DataType]::String }
        )) {
            $column = [Microsoft.AnalysisServices.Tabular.CalculatedTableColumn]::new()
            $column.Name = $columnInfo.Name
            $column.SourceColumn = "[$($columnInfo.Name)]"
            $column.DataType = $columnInfo.Type
            $thresholdTable.Columns.Add($column)
        }

        $model.Tables.Add($thresholdTable)
    }

    function Upsert-Measure {
        param(
            [Microsoft.AnalysisServices.Tabular.Table]$Table,
            [hashtable]$Definition
        )

        $measure = $Table.Measures.Find($Definition.Name)
        if (-not $measure) {
            $measure = [Microsoft.AnalysisServices.Tabular.Measure]::new()
            $measure.Name = $Definition.Name
            $Table.Measures.Add($measure)
        }

        $measure.Expression = $Definition.Expression.Trim()
        if ($Definition.ContainsKey('FormatString')) { $measure.FormatString = $Definition.FormatString }
        if ($Definition.ContainsKey('Description')) { $measure.Description = $Definition.Description }
        if ($Definition.ContainsKey('DisplayFolder')) { $measure.DisplayFolder = $Definition.DisplayFolder }
        $measure.IsHidden = $false
    }

    $folder = 'Business KPIs\Control Tower'

    $projectMeasures = @(
        @{
            Name = '_KPI Threshold Value'
            Expression = @"
VAR ThresholdName = SELECTEDVALUE('KPI Thresholds'[Threshold])
RETURN
    SELECTEDVALUE('KPI Thresholds'[Value])
"@
            FormatString = '0.00'
            DisplayFolder = $folder
            Description = 'Returns the selected KPI threshold value for diagnostics.'
        },
        @{
            Name = '_Project Schedule Risk Score'
            Expression = @"
VAR DueSoonDays =
    COALESCE(
        LOOKUPVALUE('KPI Thresholds'[Value], 'KPI Thresholds'[Threshold], "DueSoonDays"),
        30
    )
VAR LowProgress =
    COALESCE(
        LOOKUPVALUE('KPI Thresholds'[Value], 'KPI Thresholds'[Threshold], "LowProgressThreshold"),
        0.8
    )
VAR Overdue =
    COUNTROWS(
        FILTER(
            'Projects',
            NOT ISBLANK('Projects'[Finish Date])
                && 'Projects'[Finish Date] < TODAY()
                && COALESCE('Projects'[Progress], 0) < 1
        )
    )
VAR DueSoonLowProgress =
    COUNTROWS(
        FILTER(
            'Projects',
            NOT ISBLANK('Projects'[Finish Date])
                && 'Projects'[Finish Date] >= TODAY()
                && 'Projects'[Finish Date] <= TODAY() + DueSoonDays
                && COALESCE('Projects'[Progress], 0) < LowProgress
        )
    )
RETURN
    MIN(100, Overdue * 40 + DueSoonLowProgress * 25)
"@
            FormatString = '0'
            DisplayFolder = $folder
            Description = 'Schedule risk score based on overdue projects and projects due soon with low progress.'
        },
        @{
            Name = '_Project Cost Risk Score'
            Expression = @"
VAR ForecastVarianceThreshold =
    COALESCE(
        LOOKUPVALUE('KPI Thresholds'[Value], 'KPI Thresholds'[Threshold], "ForecastVarianceThreshold"),
        0.15
    )
VAR OverBudgetProjects =
    COUNTROWS(
        FILTER(
            'Projects',
            'Projects'[Budget Cost] > 0
                && DIVIDE('Projects'[Forecast Cost] - 'Projects'[Budget Cost], 'Projects'[Budget Cost], 0) > ForecastVarianceThreshold
        )
    )
VAR BudgetVariance =
    MAX(0, [_Forecast Budget Overrun %])
RETURN
    MIN(100, OverBudgetProjects * 25 + BudgetVariance * 100)
"@
            FormatString = '0'
            DisplayFolder = $folder
            Description = 'Cost risk score based on forecast budget overruns.'
        },
        @{
            Name = '_Project Status Quality Score'
            Expression = @"
VAR StaleStatusDays =
    COALESCE(
        LOOKUPVALUE('KPI Thresholds'[Value], 'KPI Thresholds'[Threshold], "StaleStatusDays"),
        14
    )
VAR TotalProjects = COUNTROWS('Projects')
VAR CurrentStatusProjects =
    COUNTROWS(
        FILTER(
            'Projects',
            NOT ISBLANK('Projects'[gbl_laststatusupdate])
                && 'Projects'[gbl_laststatusupdate] >= TODAY() - StaleStatusDays
        )
    )
RETURN
    DIVIDE(CurrentStatusProjects, TotalProjects, 0) * 100
"@
            FormatString = '0'
            DisplayFolder = $folder
            Description = 'Status quality score from 0 to 100 based on current status update coverage.'
        },
        @{
            Name = '_Project Overall Risk Score'
            Expression = @"
VAR ScheduleRisk = [_Project Schedule Risk Score]
VAR CostRisk = [_Project Cost Risk Score]
VAR StatusRisk = 100 - [_Project Status Quality Score]
RETURN
    ROUND(
        MIN(100, ScheduleRisk * 0.4 + CostRisk * 0.3 + StatusRisk * 0.3),
        0
    )
"@
            FormatString = '0'
            DisplayFolder = $folder
            Description = 'Weighted overall project risk score from 0 to 100.'
        },
        @{
            Name = '_Project Delivery Confidence %'
            Expression = "1 - DIVIDE([_Project Overall Risk Score], 100, 0)"
            FormatString = '0.0%'
            DisplayFolder = $folder
            Description = 'Delivery confidence derived from the overall project risk score.'
        },
        @{
            Name = '_Project Risk Category'
            Expression = @"
VAR Score = [_Project Overall Risk Score]
RETURN
    SWITCH(
        TRUE(),
        ISBLANK(Score), "No Data",
        Score >= 70, "Critical",
        Score >= 40, "Watch",
        "Healthy"
    )
"@
            FormatString = ''
            DisplayFolder = $folder
            Description = 'Text category for project risk.'
        },
        @{
            Name = '_Project Risk Color'
            Expression = @"
SWITCH(
    [_Project Risk Category],
    "Critical", "#C00000",
    "Watch", "#ED7D31",
    "Healthy", "#70AD47",
    "#A6A6A6"
)
"@
            FormatString = ''
            DisplayFolder = $folder
            Description = 'Hex color for project risk category.'
        },
        @{
            Name = '_Projects Requiring Attention'
            Expression = @"
COUNTROWS(
    FILTER(
        VALUES('Projects'[ProjectID]),
        [_Project Overall Risk Score] >= 40
    )
)
"@
            FormatString = '#,0'
            DisplayFolder = $folder
            Description = 'Counts projects in Watch or Critical risk categories.'
        },
        @{
            Name = '_Projects Due Soon And Low Progress'
            Expression = @"
VAR DueSoonDays =
    COALESCE(
        LOOKUPVALUE('KPI Thresholds'[Value], 'KPI Thresholds'[Threshold], "DueSoonDays"),
        30
    )
VAR LowProgress =
    COALESCE(
        LOOKUPVALUE('KPI Thresholds'[Value], 'KPI Thresholds'[Threshold], "LowProgressThreshold"),
        0.8
    )
RETURN
    COUNTROWS(
        FILTER(
            'Projects',
            NOT ISBLANK('Projects'[Finish Date])
                && 'Projects'[Finish Date] >= TODAY()
                && 'Projects'[Finish Date] <= TODAY() + DueSoonDays
                && COALESCE('Projects'[Progress], 0) < LowProgress
        )
    )
"@
            FormatString = '#,0'
            DisplayFolder = $folder
            Description = 'Counts projects due soon with progress below threshold.'
        },
        @{
            Name = '_Projects Over Forecast Budget'
            Expression = @"
VAR ForecastVarianceThreshold =
    COALESCE(
        LOOKUPVALUE('KPI Thresholds'[Value], 'KPI Thresholds'[Threshold], "ForecastVarianceThreshold"),
        0.15
    )
RETURN
    COUNTROWS(
        FILTER(
            'Projects',
            'Projects'[Budget Cost] > 0
                && DIVIDE('Projects'[Forecast Cost] - 'Projects'[Budget Cost], 'Projects'[Budget Cost], 0) > ForecastVarianceThreshold
        )
    )
"@
            FormatString = '#,0'
            DisplayFolder = $folder
            Description = 'Counts projects whose forecast cost exceeds budget by the configured threshold.'
        },
        @{
            Name = '_Portfolio Investment at Risk'
            Expression = @"
SUMX(
    FILTER(
        VALUES('Projects'[ProjectID]),
        [_Project Overall Risk Score] >= 40
    ),
    CALCULATE(SUM('Projects'[Forecast Cost]))
)
"@
            FormatString = '#,0.00'
            DisplayFolder = $folder
            Description = 'Forecast cost of projects in Watch or Critical risk categories.'
        },
        @{
            Name = '_High Value Projects at Risk'
            Expression = @"
VAR AvgForecast =
    AVERAGEX(
        VALUES('Projects'[ProjectID]),
        CALCULATE(SUM('Projects'[Forecast Cost]))
    )
RETURN
    COUNTROWS(
        FILTER(
            VALUES('Projects'[ProjectID]),
            [_Project Overall Risk Score] >= 40
                && CALCULATE(SUM('Projects'[Forecast Cost])) >= AvgForecast
        )
    )
"@
            FormatString = '#,0'
            DisplayFolder = $folder
            Description = 'Counts above-average forecast-cost projects that are in Watch or Critical risk categories.'
        },
        @{
            Name = '_Projects With Stale Status'
            Expression = @"
VAR StaleStatusDays =
    COALESCE(
        LOOKUPVALUE('KPI Thresholds'[Value], 'KPI Thresholds'[Threshold], "StaleStatusDays"),
        14
    )
RETURN
    COUNTROWS(
        FILTER(
            'Projects',
            ISBLANK('Projects'[gbl_laststatusupdate])
                || 'Projects'[gbl_laststatusupdate] < TODAY() - StaleStatusDays
        )
    )
"@
            FormatString = '#,0'
            DisplayFolder = $folder
            Description = 'Counts projects with missing or stale status updates.'
        },
        @{
            Name = '_Project Attention Reason'
            Expression = @"
VAR StaleStatusDays =
    COALESCE(
        LOOKUPVALUE('KPI Thresholds'[Value], 'KPI Thresholds'[Threshold], "StaleStatusDays"),
        14
    )
VAR DueSoonDays =
    COALESCE(
        LOOKUPVALUE('KPI Thresholds'[Value], 'KPI Thresholds'[Threshold], "DueSoonDays"),
        30
    )
VAR LowProgress =
    COALESCE(
        LOOKUPVALUE('KPI Thresholds'[Value], 'KPI Thresholds'[Threshold], "LowProgressThreshold"),
        0.8
    )
VAR ForecastVarianceThreshold =
    COALESCE(
        LOOKUPVALUE('KPI Thresholds'[Value], 'KPI Thresholds'[Threshold], "ForecastVarianceThreshold"),
        0.15
    )
VAR HasStaleStatus =
    MAXX(
        'Projects',
        IF(
            ISBLANK('Projects'[gbl_laststatusupdate])
                || 'Projects'[gbl_laststatusupdate] < TODAY() - StaleStatusDays,
            1,
            0
        )
    ) = 1
VAR IsOverdue =
    MAXX(
        'Projects',
        IF(
            NOT ISBLANK('Projects'[Finish Date])
                && 'Projects'[Finish Date] < TODAY()
                && COALESCE('Projects'[Progress], 0) < 1,
            1,
            0
        )
    ) = 1
VAR IsDueSoonLowProgress =
    MAXX(
        'Projects',
        IF(
            NOT ISBLANK('Projects'[Finish Date])
                && 'Projects'[Finish Date] >= TODAY()
                && 'Projects'[Finish Date] <= TODAY() + DueSoonDays
                && COALESCE('Projects'[Progress], 0) < LowProgress,
            1,
            0
        )
    ) = 1
VAR HasBudgetRisk =
    MAXX(
        'Projects',
        IF(
            'Projects'[Budget Cost] > 0
                && DIVIDE('Projects'[Forecast Cost] - 'Projects'[Budget Cost], 'Projects'[Budget Cost], 0) > ForecastVarianceThreshold,
            1,
            0
        )
    ) = 1
VAR Reasons =
    {
        IF(HasStaleStatus, "Stale status", BLANK()),
        IF(IsOverdue, "Overdue", BLANK()),
        IF(IsDueSoonLowProgress, "Due soon and low progress", BLANK()),
        IF(HasBudgetRisk, "Forecast over budget", BLANK())
    }
VAR Result =
    CONCATENATEX(
        FILTER(Reasons, NOT ISBLANK([Value])),
        [Value],
        "; "
    )
RETURN
    IF(Result = BLANK(), "No attention reason", Result)
"@
            FormatString = ''
            DisplayFolder = $folder
            Description = 'Human-readable reasons why the project context needs attention.'
        }
    )

    $resourceMeasures = @(
        @{
            Name = '_Resource Overload Score'
            Expression = @"
VAR CriticalThreshold =
    COALESCE(
        LOOKUPVALUE('KPI Thresholds'[Value], 'KPI Thresholds'[Threshold], "CriticalOverallocatedThreshold"),
        1.2
    )
VAR OverThreshold =
    COALESCE(
        LOOKUPVALUE('KPI Thresholds'[Value], 'KPI Thresholds'[Threshold], "OverallocatedThreshold"),
        1.0
    )
VAR Utilization = [% Utilization]
RETURN
    SWITCH(
        TRUE(),
        ISBLANK(Utilization), BLANK(),
        Utilization >= CriticalThreshold, 100,
        Utilization > OverThreshold, 70,
        Utilization >= 0.9, 30,
        0
    )
"@
            FormatString = '0'
            DisplayFolder = $folder
            Description = 'Resource overload score from 0 to 100 based on utilization thresholds.'
        },
        @{
            Name = '_Resource Availability Score'
            Expression = @"
VAR GapPercent = [_Resource Capacity Gap %]
RETURN
    SWITCH(
        TRUE(),
        ISBLANK(GapPercent), BLANK(),
        GapPercent < 0, 0,
        GapPercent < 0.1, 40,
        GapPercent < 0.3, 70,
        100
    )
"@
            FormatString = '0'
            DisplayFolder = $folder
            Description = 'Availability score from 0 to 100 based on capacity gap percentage.'
        },
        @{
            Name = '_Resource Forecast Quality Score'
            Expression = @"
VAR WarningThreshold =
    COALESCE(
        LOOKUPVALUE('KPI Thresholds'[Value], 'KPI Thresholds'[Threshold], "ForecastAccuracyWarningThreshold"),
        0.2
    )
VAR Demand = [_Resource Demand Hours]
VAR Actuals = [_TS-Hours]
VAR VariancePercent = ABS(DIVIDE(Actuals - Demand, Demand, 0))
RETURN
    SWITCH(
        TRUE(),
        Demand = 0 && Actuals = 0, BLANK(),
        VariancePercent <= WarningThreshold, 100,
        VariancePercent <= WarningThreshold * 2, 70,
        VariancePercent <= WarningThreshold * 3, 40,
        0
    )
"@
            FormatString = '0'
            DisplayFolder = $folder
            Description = 'Forecast quality score based on demand versus actual timesheet hours.'
        },
        @{
            Name = '_Resource Bottleneck Score'
            Expression = @"
VAR OverloadScore = [_Resource Overload Score]
VAR AvailabilityRisk = 100 - [_Resource Availability Score]
VAR ForecastRisk = 100 - [_Resource Forecast Quality Score]
RETURN
    ROUND(
        MIN(
            100,
            COALESCE(OverloadScore, 0) * 0.5
                + COALESCE(AvailabilityRisk, 0) * 0.3
                + COALESCE(ForecastRisk, 0) * 0.2
        ),
        0
    )
"@
            FormatString = '0'
            DisplayFolder = $folder
            Description = 'Weighted resource bottleneck score from 0 to 100.'
        },
        @{
            Name = '_Department Capacity Risk Score'
            Expression = @"
VAR GapPercent = [_Resource Capacity Gap %]
VAR Overallocated = [_Resources Overallocated]
VAR WithDemandNoCapacity = [_Resources With Demand No Capacity]
RETURN
    ROUND(
        MIN(
            100,
            IF(GapPercent < 0, ABS(GapPercent) * 100, 0)
                + Overallocated * 10
                + WithDemandNoCapacity * 20
        ),
        0
    )
"@
            FormatString = '0'
            DisplayFolder = $folder
            Description = 'Capacity risk score for resource or department context.'
        },
        @{
            Name = '_Resource Load Category'
            Expression = @"
VAR Score = [_Resource Bottleneck Score]
RETURN
    SWITCH(
        TRUE(),
        ISBLANK(Score), "No Data",
        Score >= 70, "Critical",
        Score >= 40, "Watch",
        "Healthy"
    )
"@
            FormatString = ''
            DisplayFolder = $folder
            Description = 'Text category for resource load risk.'
        },
        @{
            Name = '_Resource Load Color'
            Expression = @"
SWITCH(
    [_Resource Load Category],
    "Critical", "#C00000",
    "Watch", "#ED7D31",
    "Healthy", "#70AD47",
    "#A6A6A6"
)
"@
            FormatString = ''
            DisplayFolder = $folder
            Description = 'Hex color for resource load category.'
        },
        @{
            Name = '_Resources Overallocated Next 30 Days'
            Expression = @"
CALCULATE(
    [_Resources Overallocated],
    DATESINPERIOD('Resource Demand'[Capacity Date], TODAY(), 30, DAY)
)
"@
            FormatString = '#,0'
            DisplayFolder = $folder
            Description = 'Counts overallocated resources in the next 30 days.'
        },
        @{
            Name = '_Resources Overallocated Next 90 Days'
            Expression = @"
CALCULATE(
    [_Resources Overallocated],
    DATESINPERIOD('Resource Demand'[Capacity Date], TODAY(), 90, DAY)
)
"@
            FormatString = '#,0'
            DisplayFolder = $folder
            Description = 'Counts overallocated resources in the next 90 days.'
        },
        @{
            Name = '_Resources Underutilized Next 30 Days'
            Expression = @"
CALCULATE(
    [_Resources Underutilized],
    DATESINPERIOD('Resource Demand'[Capacity Date], TODAY(), 30, DAY)
)
"@
            FormatString = '#,0'
            DisplayFolder = $folder
            Description = 'Counts underutilized resources in the next 30 days.'
        },
        @{
            Name = '_Demand Without Capacity Hours'
            Expression = @"
SUMX(
    FILTER(
        VALUES('Resources'[ResourceID]),
        COALESCE([_Resource Demand Hours], 0) > 0
            && COALESCE([_CapacityHoursNetto], 0) = 0
    ),
    [_Resource Demand Hours]
)
"@
            FormatString = '#,0.00'
            DisplayFolder = $folder
            Description = 'Demand hours assigned to resources without net capacity.'
        },
        @{
            Name = '_Missing Timesheet Hours'
            Expression = @"
MAX(0, [_Resource Demand Hours] - [_TS-Hours])
"@
            FormatString = '#,0.00'
            DisplayFolder = $folder
            Description = 'Forecast demand hours not covered by timesheet actuals.'
        },
        @{
            Name = '_Forecast Accuracy %'
            Expression = @"
VAR Demand = [_Resource Demand Hours]
VAR Actuals = [_TS-Hours]
VAR VariancePercent = ABS(DIVIDE(Actuals - Demand, Demand, 0))
RETURN
    IF(
        Demand = 0 && Actuals = 0,
        BLANK(),
        MAX(0, 1 - VariancePercent)
    )
"@
            FormatString = '0.0%'
            DisplayFolder = $folder
            Description = 'Forecast accuracy from demand versus actual timesheet hours.'
        },
        @{
            Name = '_Demand vs Actual Variance Hours'
            Expression = "[_TS-Hours] - [_Resource Demand Hours]"
            FormatString = '#,0.00'
            DisplayFolder = $folder
            Description = 'Actual timesheet hours minus forecast demand hours.'
        },
        @{
            Name = '_Resources With Missing Master Data'
            Expression = @"
COUNTROWS(
    FILTER(
        VALUES('Resources'[ResourceID]),
        ISBLANK(CALCULATE(SELECTEDVALUE('Resources'[DepartmentID])))
            || ISBLANK(CALCULATE(SELECTEDVALUE('Resources'[ResourceName])))
    )
)
"@
            FormatString = '#,0'
            DisplayFolder = $folder
            Description = 'Counts resources with missing core master data.'
        },
        @{
            Name = '_Resource Attention Reason'
            Expression = @"
VAR CriticalThreshold =
    COALESCE(
        LOOKUPVALUE('KPI Thresholds'[Value], 'KPI Thresholds'[Threshold], "CriticalOverallocatedThreshold"),
        1.2
    )
VAR OverThreshold =
    COALESCE(
        LOOKUPVALUE('KPI Thresholds'[Value], 'KPI Thresholds'[Threshold], "OverallocatedThreshold"),
        1.0
    )
VAR TimesheetLowThreshold =
    COALESCE(
        LOOKUPVALUE('KPI Thresholds'[Value], 'KPI Thresholds'[Threshold], "TimesheetCoverageLowThreshold"),
        0.7
    )
VAR Utilization = [% Utilization]
VAR HasCriticalOverload = Utilization >= CriticalThreshold
VAR HasOverload = Utilization > OverThreshold && NOT HasCriticalOverload
VAR HasDemandNoCapacity = [_Resources With Demand No Capacity] > 0
VAR HasLowTimesheetCoverage = [_Timesheet Coverage %] > 0 && [_Timesheet Coverage %] < TimesheetLowThreshold
VAR HasMissingMasterData = [_Resources With Missing Master Data] > 0
VAR Reasons =
    {
        IF(HasCriticalOverload, "Critical overallocation", BLANK()),
        IF(HasOverload, "Overallocation", BLANK()),
        IF(HasDemandNoCapacity, "Demand without capacity", BLANK()),
        IF(HasLowTimesheetCoverage, "Low timesheet coverage", BLANK()),
        IF(HasMissingMasterData, "Missing master data", BLANK())
    }
VAR Result =
    CONCATENATEX(
        FILTER(Reasons, NOT ISBLANK([Value])),
        [Value],
        "; "
    )
RETURN
    IF(Result = BLANK(), "No attention reason", Result)
"@
            FormatString = ''
            DisplayFolder = $folder
            Description = 'Human-readable reasons why the resource context needs attention.'
        }
    )

    foreach ($definition in $projectMeasures) {
        Upsert-Measure -Table $projects -Definition $definition
    }
    foreach ($definition in $resourceMeasures) {
        Upsert-Measure -Table $resources -Definition $definition
    }

    $model.SaveChanges()

    [pscustomobject]@{
        Server = 'localhost:57411'
        Database = $database.Name
        ThresholdTable = $thresholdTableName
        ProjectMeasures = $projectMeasures.Name
        ResourceMeasures = $resourceMeasures.Name
    } | ConvertTo-Json -Depth 5
}
finally {
    $server.Disconnect()
}

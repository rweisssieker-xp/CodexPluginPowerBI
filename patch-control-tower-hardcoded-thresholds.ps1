Add-Type -Path 'C:\Program Files\DAX Studio\bin\Microsoft.AnalysisServices.Tabular.dll'

$server = [Microsoft.AnalysisServices.Tabular.Server]::new()
$server.Connect('localhost:57411')

try {
    $database = $server.Databases[0]
    $model = $database.Model
    $projects = $model.Tables.Find('Projects')
    $resources = $model.Tables.Find('Resources')
    $folder = 'Business KPIs\Control Tower'

    function Set-MeasureExpression {
        param(
            [Microsoft.AnalysisServices.Tabular.Table]$Table,
            [string]$Name,
            [string]$Expression
        )

        $measure = $Table.Measures.Find($Name)
        if (-not $measure) {
            $measure = [Microsoft.AnalysisServices.Tabular.Measure]::new()
            $measure.Name = $Name
            $Table.Measures.Add($measure)
        }
        $measure.Expression = $Expression.Trim()
        $measure.DisplayFolder = $folder
        $measure.IsHidden = $false
    }

    Set-MeasureExpression -Table $projects -Name '_KPI Threshold Value' -Expression @"
BLANK()
"@

    Set-MeasureExpression -Table $projects -Name '_Project Schedule Risk Score' -Expression @"
VAR DueSoonDays = 30
VAR LowProgress = 0.8
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

    Set-MeasureExpression -Table $projects -Name '_Project Cost Risk Score' -Expression @"
VAR ForecastVarianceThreshold = 0.15
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

    Set-MeasureExpression -Table $projects -Name '_Project Status Quality Score' -Expression @"
VAR StaleStatusDays = 14
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

    Set-MeasureExpression -Table $projects -Name '_Projects Due Soon And Low Progress' -Expression @"
VAR DueSoonDays = 30
VAR LowProgress = 0.8
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

    Set-MeasureExpression -Table $projects -Name '_Projects Over Forecast Budget' -Expression @"
VAR ForecastVarianceThreshold = 0.15
RETURN
    COUNTROWS(
        FILTER(
            'Projects',
            'Projects'[Budget Cost] > 0
                && DIVIDE('Projects'[Forecast Cost] - 'Projects'[Budget Cost], 'Projects'[Budget Cost], 0) > ForecastVarianceThreshold
        )
    )
"@

    Set-MeasureExpression -Table $projects -Name '_Projects With Stale Status' -Expression @"
VAR StaleStatusDays = 14
RETURN
    COUNTROWS(
        FILTER(
            'Projects',
            ISBLANK('Projects'[gbl_laststatusupdate])
                || 'Projects'[gbl_laststatusupdate] < TODAY() - StaleStatusDays
        )
    )
"@

    Set-MeasureExpression -Table $projects -Name '_Project Attention Reason' -Expression @"
VAR StaleStatusDays = 14
VAR DueSoonDays = 30
VAR LowProgress = 0.8
VAR ForecastVarianceThreshold = 0.15
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

    Set-MeasureExpression -Table $resources -Name '_Resource Overload Score' -Expression @"
VAR CriticalThreshold = 1.2
VAR OverThreshold = 1.0
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

    Set-MeasureExpression -Table $resources -Name '_Resource Forecast Quality Score' -Expression @"
VAR WarningThreshold = 0.2
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

    Set-MeasureExpression -Table $resources -Name '_Resource Attention Reason' -Expression @"
VAR CriticalThreshold = 1.2
VAR OverThreshold = 1.0
VAR TimesheetLowThreshold = 0.7
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

    $model.SaveChanges()
    'Control Tower measures patched to use internal default thresholds.'
}
finally {
    $server.Disconnect()
}

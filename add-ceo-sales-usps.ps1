param(
    [string]$ServerName = 'localhost:53585',
    [string]$TabularDll = 'C:\Program Files\Tabular Editor 3\Microsoft.AnalysisServices.Tabular.dll'
)

$ErrorActionPreference = 'Stop'

Add-Type -Path $TabularDll

$server = [Microsoft.AnalysisServices.Tabular.Server]::new()
$server.Connect($ServerName)

try {
    $database = $server.Databases[0]
    if (-not $database) {
        throw "No database found on $ServerName"
    }

    $model = $database.Model
    $financials = $model.Tables.Find('financials')
    $measureTable = $model.Tables.Find('_Measures')

    if (-not $financials) {
        throw "Table 'financials' was not found."
    }

    function Upsert-CalculatedTable {
        param(
            [Microsoft.AnalysisServices.Tabular.Model]$Model,
            [string]$Name,
            [string]$Expression,
            [string]$Description = ''
        )

        $table = $Model.Tables.Find($Name)
        if (-not $table) {
            $table = [Microsoft.AnalysisServices.Tabular.Table]::new()
            $table.Name = $Name
            $Model.Tables.Add($table)
        }

        $partition = $table.Partitions | Select-Object -First 1
        if (-not $partition) {
            $partition = [Microsoft.AnalysisServices.Tabular.Partition]::new()
            $partition.Name = $Name
            $table.Partitions.Add($partition)
        }

        $source = [Microsoft.AnalysisServices.Tabular.CalculatedPartitionSource]::new()
        $source.Expression = $Expression
        $partition.Source = $source
        $table.Description = $Description
        return $table
    }

    if (-not $measureTable) {
        $measureTable = Upsert-CalculatedTable `
            -Model $model `
            -Name '_Measures' `
            -Expression 'ROW("Measure Table", 1)' `
            -Description 'Container for explicit report measures.'
    }

    foreach ($column in $measureTable.Columns) {
        $column.IsHidden = $true
    }

    $targetScenario = Upsert-CalculatedTable `
        -Model $model `
        -Name 'Target Scenario' `
        -Expression @"
DATATABLE(
    "Scenario", STRING,
    "Target Growth %", DOUBLE,
    "Target Margin %", DOUBLE,
    "Max Discount %", DOUBLE,
    {
        {"Conservative", 0.05, 0.12, 0.08},
        {"Base", 0.10, 0.15, 0.10},
        {"Ambitious", 0.20, 0.18, 0.12}
    }
)
"@ `
        -Description 'Disconnected scenario table for CEO and sales targets.'

    $scenarioColumn = $targetScenario.Columns.Find('Scenario')
    if ($scenarioColumn) {
        $scenarioColumn.Description = 'Scenario selector for target-based executive measures.'
    }
    foreach ($columnName in @('Target Growth %','Target Margin %','Max Discount %')) {
        $column = $targetScenario.Columns.Find($columnName)
        if ($column) {
            $column.FormatString = '0.00%'
            $column.SummarizeBy = [Microsoft.AnalysisServices.Tabular.AggregateFunction]::None
        }
    }

    function Upsert-Measure {
        param(
            [Microsoft.AnalysisServices.Tabular.Table]$Table,
            [string]$Name,
            [string]$Expression,
            [string]$FormatString,
            [string]$DisplayFolder,
            [string]$Description
        )

        $measure = $Table.Measures.Find($Name)
        if (-not $measure) {
            $measure = [Microsoft.AnalysisServices.Tabular.Measure]::new()
            $measure.Name = $Name
            $Table.Measures.Add($measure)
        }

        $measure.Expression = $Expression
        $measure.FormatString = $FormatString
        $measure.DisplayFolder = $DisplayFolder
        $measure.Description = $Description
        return $measure
    }

    $currency = '$#,0.00;($#,0.00);$#,0.00'
    $whole = '#,0'
    $decimal = '#,0.00'
    $percent = '0.00%'

    $measureSpecs = @(
        @{ Name='Gross Margin'; Expression='[Sales] - [COGS]'; Format=$currency; Folder='CEO\Profitability'; Description='Sales minus cost of goods sold.' },
        @{ Name='Gross Margin %'; Expression='DIVIDE([Gross Margin], [Sales])'; Format=$percent; Folder='CEO\Profitability'; Description='Gross margin divided by sales.' },
        @{ Name='COGS %'; Expression='DIVIDE([COGS], [Sales])'; Format=$percent; Folder='CEO\Profitability'; Description='Cost of goods sold as a share of sales.' },
        @{ Name='Profit per Unit'; Expression='DIVIDE([Profit], [Units Sold])'; Format=$currency; Folder='Sales\Unit Economics'; Description='Profit generated per unit sold.' },
        @{ Name='Gross Sales per Unit'; Expression='DIVIDE([Gross Sales], [Units Sold])'; Format=$currency; Folder='Sales\Unit Economics'; Description='Gross sales per unit sold.' },
        @{ Name='Discount per Unit'; Expression='DIVIDE([Discounts], [Units Sold])'; Format=$currency; Folder='Sales\Unit Economics'; Description='Discount value per unit sold.' },
        @{ Name='Discount Impact %'; Expression='DIVIDE([Discounts], [Sales] + [Discounts])'; Format=$percent; Folder='Margin and Discount'; Description='Discounts as share of net sales plus discounts.' },
        @{ Name='Net Realization %'; Expression='DIVIDE([Sales], [Gross Sales])'; Format=$percent; Folder='Margin and Discount'; Description='Net sales retained after discounts.' },
        @{ Name='Sales Share %'; Expression='DIVIDE([Sales], CALCULATE([Sales], ALLSELECTED(''financials'')))'; Format=$percent; Folder='CEO\Contribution'; Description='Current item sales share within the selected context.' },
        @{ Name='Profit Share %'; Expression='DIVIDE([Profit], CALCULATE([Profit], ALLSELECTED(''financials'')))'; Format=$percent; Folder='CEO\Contribution'; Description='Current item profit share within the selected context.' },
        @{ Name='Units Share %'; Expression='DIVIDE([Units Sold], CALCULATE([Units Sold], ALLSELECTED(''financials'')))'; Format=$percent; Folder='Sales\Contribution'; Description='Current item unit share within the selected context.' },
        @{ Name='Product Count'; Expression='DISTINCTCOUNT(''financials''[Product])'; Format=$whole; Folder='Sales\Coverage'; Description='Number of products in the current context.' },
        @{ Name='Country Count'; Expression='DISTINCTCOUNT(''financials''[Country])'; Format=$whole; Folder='Sales\Coverage'; Description='Number of countries in the current context.' },
        @{ Name='Segment Count'; Expression='DISTINCTCOUNT(''financials''[Segment])'; Format=$whole; Folder='Sales\Coverage'; Description='Number of customer segments in the current context.' },
        @{ Name='Product Sales Rank'; Expression='IF(ISINSCOPE(''financials''[Product]), RANKX(ALLSELECTED(''financials''[Product]), [Sales], , DESC, DENSE))'; Format=$whole; Folder='Sales\Ranking'; Description='Product rank by sales inside the selected context.' },
        @{ Name='Product Profit Rank'; Expression='IF(ISINSCOPE(''financials''[Product]), RANKX(ALLSELECTED(''financials''[Product]), [Profit], , DESC, DENSE))'; Format=$whole; Folder='Sales\Ranking'; Description='Product rank by profit inside the selected context.' },
        @{ Name='Country Sales Rank'; Expression='IF(ISINSCOPE(''financials''[Country]), RANKX(ALLSELECTED(''financials''[Country]), [Sales], , DESC, DENSE))'; Format=$whole; Folder='Sales\Ranking'; Description='Country rank by sales inside the selected context.' },
        @{ Name='Country Profit Rank'; Expression='IF(ISINSCOPE(''financials''[Country]), RANKX(ALLSELECTED(''financials''[Country]), [Profit], , DESC, DENSE))'; Format=$whole; Folder='Sales\Ranking'; Description='Country rank by profit inside the selected context.' },
        @{ Name='Segment Sales Rank'; Expression='IF(ISINSCOPE(''financials''[Segment]), RANKX(ALLSELECTED(''financials''[Segment]), [Sales], , DESC, DENSE))'; Format=$whole; Folder='Sales\Ranking'; Description='Segment rank by sales inside the selected context.' },
        @{ Name='Top Product Sales'; Expression='MAXX(TOPN(1, ALLSELECTED(''financials''[Product]), [Sales], DESC), [Sales])'; Format=$currency; Folder='CEO\Top Drivers'; Description='Sales of the best-performing product in the selected context.' },
        @{ Name='Top Country Sales'; Expression='MAXX(TOPN(1, ALLSELECTED(''financials''[Country]), [Sales], DESC), [Sales])'; Format=$currency; Folder='CEO\Top Drivers'; Description='Sales of the best-performing country in the selected context.' },
        @{ Name='Top Segment Sales'; Expression='MAXX(TOPN(1, ALLSELECTED(''financials''[Segment]), [Sales], DESC), [Sales])'; Format=$currency; Folder='CEO\Top Drivers'; Description='Sales of the best-performing segment in the selected context.' },
        @{ Name='Top Product Sales Share %'; Expression='DIVIDE([Top Product Sales], [Sales])'; Format=$percent; Folder='CEO\Concentration'; Description='Share of sales contributed by the leading product.' },
        @{ Name='Top Country Sales Share %'; Expression='DIVIDE([Top Country Sales], [Sales])'; Format=$percent; Folder='CEO\Concentration'; Description='Share of sales contributed by the leading country.' },
        @{ Name='Top Segment Sales Share %'; Expression='DIVIDE([Top Segment Sales], [Sales])'; Format=$percent; Folder='CEO\Concentration'; Description='Share of sales contributed by the leading segment.' },
        @{ Name='Top 3 Product Sales'; Expression='SUMX(TOPN(3, ALLSELECTED(''financials''[Product]), [Sales], DESC), [Sales])'; Format=$currency; Folder='CEO\Concentration'; Description='Combined sales of the top three products.' },
        @{ Name='Top 3 Product Sales Share %'; Expression='DIVIDE([Top 3 Product Sales], [Sales])'; Format=$percent; Folder='CEO\Concentration'; Description='Share of sales contributed by the top three products.' },
        @{ Name='Low Margin Flag'; Expression='IF([Profit Margin %] < 0.10, 1, 0)'; Format=$whole; Folder='CEO\Risk Flags'; Description='Flags contexts with profit margin below 10%.' },
        @{ Name='High Discount Flag'; Expression='IF([Discount %] > 0.10, 1, 0)'; Format=$whole; Folder='CEO\Risk Flags'; Description='Flags contexts with discount percentage above 10%.' },
        @{ Name='High Discount Low Margin Flag'; Expression='IF([Discount %] > 0.10 && [Profit Margin %] < 0.10, 1, 0)'; Format=$whole; Folder='CEO\Risk Flags'; Description='Flags contexts where discounting is high and margin is low.' },
        @{ Name='Margin Risk Sales'; Expression='IF([High Discount Low Margin Flag] = 1, [Sales])'; Format=$currency; Folder='CEO\Risk Exposure'; Description='Sales exposed to combined high-discount and low-margin risk.' },
        @{ Name='Margin Risk Profit'; Expression='IF([High Discount Low Margin Flag] = 1, [Profit])'; Format=$currency; Folder='CEO\Risk Exposure'; Description='Profit exposed to combined high-discount and low-margin risk.' },
        @{ Name='Margin Risk Sales Share %'; Expression='DIVIDE([Margin Risk Sales], [Sales])'; Format=$percent; Folder='CEO\Risk Exposure'; Description='Share of sales in high-discount and low-margin contexts.' },
        @{ Name='Sales Previous Month'; Expression='CALCULATE([Sales], DATEADD(''Date''[Date], -1, MONTH))'; Format=$currency; Folder='Time Intelligence'; Description='Sales in the previous month.' },
        @{ Name='Sales MoM %'; Expression='DIVIDE([Sales] - [Sales Previous Month], [Sales Previous Month])'; Format=$percent; Folder='Time Intelligence'; Description='Month-over-month sales growth.' },
        @{ Name='Profit Previous Month'; Expression='CALCULATE([Profit], DATEADD(''Date''[Date], -1, MONTH))'; Format=$currency; Folder='Time Intelligence'; Description='Profit in the previous month.' },
        @{ Name='Profit MoM %'; Expression='DIVIDE([Profit] - [Profit Previous Month], [Profit Previous Month])'; Format=$percent; Folder='Time Intelligence'; Description='Month-over-month profit growth.' },
        @{ Name='Sales Rolling 3M'; Expression='CALCULATE([Sales], DATESINPERIOD(''Date''[Date], MAX(''Date''[Date]), -3, MONTH))'; Format=$currency; Folder='Time Intelligence'; Description='Rolling three-month sales.' },
        @{ Name='Profit Rolling 3M'; Expression='CALCULATE([Profit], DATESINPERIOD(''Date''[Date], MAX(''Date''[Date]), -3, MONTH))'; Format=$currency; Folder='Time Intelligence'; Description='Rolling three-month profit.' },
        @{ Name='Target Growth %'; Expression='SELECTEDVALUE(''Target Scenario''[Target Growth %], 0.10)'; Format=$percent; Folder='CEO\Targets'; Description='Selected target growth rate.' },
        @{ Name='Target Margin %'; Expression='SELECTEDVALUE(''Target Scenario''[Target Margin %], 0.15)'; Format=$percent; Folder='CEO\Targets'; Description='Selected target margin rate.' },
        @{ Name='Max Discount %'; Expression='SELECTEDVALUE(''Target Scenario''[Max Discount %], 0.10)'; Format=$percent; Folder='CEO\Targets'; Description='Selected maximum discount threshold.' },
        @{ Name='Sales Target'; Expression='[Sales Previous Year] * (1 + [Target Growth %])'; Format=$currency; Folder='CEO\Targets'; Description='Sales target based on previous-year sales and selected target growth.' },
        @{ Name='Sales Gap to Target'; Expression='[Sales] - [Sales Target]'; Format=$currency; Folder='CEO\Targets'; Description='Actual sales minus scenario target.' },
        @{ Name='Sales Attainment %'; Expression='DIVIDE([Sales], [Sales Target])'; Format=$percent; Folder='CEO\Targets'; Description='Actual sales divided by scenario target.' },
        @{ Name='Margin Gap to Target %'; Expression='[Profit Margin %] - [Target Margin %]'; Format=$percent; Folder='CEO\Targets'; Description='Actual profit margin minus selected target margin.' },
        @{ Name='Discount Over Threshold %'; Expression='[Discount %] - [Max Discount %]'; Format=$percent; Folder='CEO\Targets'; Description='Actual discount rate minus selected discount threshold.' },
        @{ Name='CEO Health Score'; Expression='VAR GrowthScore = MIN(1, MAX(0, DIVIDE([Sales Attainment %], 1))) VAR MarginScore = MIN(1, MAX(0, DIVIDE([Profit Margin %], [Target Margin %]))) VAR DiscountScore = MIN(1, MAX(0, DIVIDE([Max Discount %], [Discount %]))) RETURN 100 * (0.45 * GrowthScore + 0.35 * MarginScore + 0.20 * DiscountScore)'; Format=$decimal; Folder='CEO\Scorecards'; Description='Composite 0-100 score weighted by growth attainment, margin, and discount discipline.' },
        @{ Name='Sales Motion Label'; Expression='SWITCH(TRUE(), [Sales Attainment %] >= 1 && [Profit Margin %] >= [Target Margin %], "Scale", [Sales Attainment %] >= 1 && [Profit Margin %] < [Target Margin %], "Grow but fix margin", [Sales Attainment %] < 1 && [Profit Margin %] >= [Target Margin %], "Sell more", "Intervene")'; Format=''; Folder='CEO\Scorecards'; Description='Executive action label for the current context.' },
        @{ Name='Top Product Name'; Expression='CONCATENATEX(TOPN(1, ALLSELECTED(''financials''[Product]), [Sales], DESC), ''financials''[Product], ", ")'; Format=''; Folder='CEO\Narratives'; Description='Name of the top product by sales.' },
        @{ Name='Top Country Name'; Expression='CONCATENATEX(TOPN(1, ALLSELECTED(''financials''[Country]), [Sales], DESC), ''financials''[Country], ", ")'; Format=''; Folder='CEO\Narratives'; Description='Name of the top country by sales.' },
        @{ Name='Top Segment Name'; Expression='CONCATENATEX(TOPN(1, ALLSELECTED(''financials''[Segment]), [Sales], DESC), ''financials''[Segment], ", ")'; Format=''; Folder='CEO\Narratives'; Description='Name of the top customer segment by sales.' },
        @{ Name='Lowest Margin Product Name'; Expression='CONCATENATEX(TOPN(1, ALLSELECTED(''financials''[Product]), [Profit Margin %], ASC), ''financials''[Product], ", ")'; Format=''; Folder='CEO\Narratives'; Description='Name of the product with the lowest profit margin.' },
        @{ Name='Highest Discount Product Name'; Expression='CONCATENATEX(TOPN(1, ALLSELECTED(''financials''[Product]), [Discount %], DESC), ''financials''[Product], ", ")'; Format=''; Folder='CEO\Narratives'; Description='Name of the product with the highest discount rate.' },
        @{ Name='Portfolio Concentration Label'; Expression='SWITCH(TRUE(), [Top 3 Product Sales Share %] >= 0.70, "High concentration risk", [Top 3 Product Sales Share %] >= 0.50, "Moderate concentration", "Diversified")'; Format=''; Folder='CEO\Narratives'; Description='Readable concentration assessment based on top-three product sales share.' },
        @{ Name='Margin Status Label'; Expression='SWITCH(TRUE(), [Profit Margin %] >= [Target Margin %], "Margin on target", [Profit Margin %] >= [Target Margin %] - 0.03, "Margin slightly below target", "Margin intervention needed")'; Format=''; Folder='CEO\Narratives'; Description='Readable margin status versus selected target.' },
        @{ Name='Discount Discipline Label'; Expression='SWITCH(TRUE(), [Discount %] <= [Max Discount %], "Discounts controlled", [Discount %] <= [Max Discount %] + 0.03, "Discounts watchlist", "Discounts too high")'; Format=''; Folder='CEO\Narratives'; Description='Readable discount status versus selected threshold.' },
        @{ Name='CEO Board Statement'; Expression='"Sales " & FORMAT([Sales] / 1000000, "$#,0.0") & "M, profit margin " & FORMAT([Profit Margin %], "0.0%") & ", health score " & FORMAT([CEO Health Score], "0") & "/100: " & [Sales Motion Label] & ". Top product: " & [Top Product Name] & "."'; Format=''; Folder='CEO\Narratives'; Description='One-line executive board statement for cards and report subtitles.' },
        @{ Name='Sales Focus Statement'; Expression='"Focus: " & [Top Country Name] & " / " & [Top Segment Name] & ". Watch " & [Highest Discount Product Name] & " for discounting and " & [Lowest Margin Product Name] & " for margin."'; Format=''; Folder='Sales\Narratives'; Description='One-line sales management recommendation.' }
    )

    foreach ($spec in $measureSpecs) {
        $null = Upsert-Measure `
            -Table $measureTable `
            -Name $spec.Name `
            -Expression $spec.Expression `
            -FormatString $spec.Format `
            -DisplayFolder $spec.Folder `
            -Description $spec.Description
    }

    $targetScenario.RequestRefresh([Microsoft.AnalysisServices.Tabular.RefreshType]::Full)
    $measureTable.RequestRefresh([Microsoft.AnalysisServices.Tabular.RefreshType]::Full)
    $model.SaveChanges()

    [pscustomobject]@{
        Server = $ServerName
        Database = $database.Name
        Measures = $measureTable.Measures.Count
        Tables = $model.Tables.Count
        AddedOrUpdated = $measureSpecs.Count
        ScenarioTable = $targetScenario.Name
    } | ConvertTo-Json -Depth 4
}
finally {
    $server.Disconnect()
}

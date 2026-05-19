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
    if (-not $financials) {
        throw "Table 'financials' was not found."
    }

    function Upsert-Measure {
        param(
            [Microsoft.AnalysisServices.Tabular.Table]$Table,
            [string]$Name,
            [string]$Expression,
            [string]$FormatString,
            [string]$DisplayFolder = 'Core KPIs',
            [string]$Description = ''
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

    function Upsert-CalculatedColumn {
        param(
            [Microsoft.AnalysisServices.Tabular.Table]$Table,
            [string]$Name,
            [string]$Expression,
            [string]$FormatString = '',
            [string]$DataCategory = ''
        )

        $column = $Table.Columns.Find($Name)
        if (-not $column) {
            $column = [Microsoft.AnalysisServices.Tabular.CalculatedColumn]::new()
            $column.Name = $Name
            $Table.Columns.Add($column)
        }

        $column.Expression = $Expression
        if ($FormatString) { $column.FormatString = $FormatString }
        if ($DataCategory) { $column.DataCategory = $DataCategory }
        return $column
    }

    $dateTableExpression = @"
ADDCOLUMNS(
    CALENDAR(MIN('financials'[Date]), MAX('financials'[Date])),
    "Year", YEAR([Date]),
    "Month Number", MONTH([Date]),
    "Month Name", FORMAT([Date], "MMMM"),
    "Quarter Number", INT((MONTH([Date]) + 2) / 3),
    "Quarter", "Q" & INT((MONTH([Date]) + 2) / 3),
    "Year Month", FORMAT([Date], "YYYY-MM")
)
"@

    $dateTable = Upsert-CalculatedTable `
        -Model $model `
        -Name 'Date' `
        -Expression $dateTableExpression `
        -Description 'Explicit calendar table generated from the Financials date range. Use this table for all time filtering.'

    $measureTable = Upsert-CalculatedTable `
        -Model $model `
        -Name '_Measures' `
        -Expression 'ROW("Measure Table", 1)' `
        -Description 'Container for explicit report measures.'

    $descriptions = @{
        'Segment' = 'Customer segment.'
        'Country' = 'Sales country.'
        'Product' = 'Product name.'
        'Discount Band' = 'Discount grouping.'
        'Units Sold' = 'Raw units sold column. Prefer the [Units Sold] measure for reporting.'
        'Manufacturing Price' = 'Raw manufacturing price column. Prefer explicit measures for reporting.'
        'Sale Price' = 'Raw sale price column. Prefer explicit measures for reporting.'
        'Gross Sales' = 'Raw gross sales amount. Prefer the [Gross Sales] measure.'
        'Discounts' = 'Raw discount amount. Prefer the [Discounts] measure.'
        'Sales' = 'Raw net sales amount. Prefer the [Sales] measure.'
        'COGS' = 'Raw cost of goods sold amount. Prefer the [COGS] measure.'
        'Profit' = 'Raw profit amount. Prefer the [Profit] measure.'
        'Date' = 'Transaction date.'
        'Month Number' = 'Source month number. Prefer Date[Month Number] for time analysis.'
        'Month Name' = 'Source month name. Prefer Date[Month Name] for time analysis.'
        'Year' = 'Source year. Prefer Date[Year] for time analysis.'
    }

    foreach ($entry in $descriptions.GetEnumerator()) {
        $column = $financials.Columns.Find($entry.Key)
        if ($column) {
            $column.Description = $entry.Value
        }
    }

    foreach ($columnName in @('Units Sold','Manufacturing Price','Sale Price','Gross Sales','Discounts','Sales','COGS','Profit','Month Number','Year')) {
        $column = $financials.Columns.Find($columnName)
        if ($column) {
            $column.IsHidden = $true
        }
    }

    foreach ($columnName in @('Manufacturing Price','Sale Price','Gross Sales','Discounts','Sales','COGS','Profit')) {
        $column = $financials.Columns.Find($columnName)
        if ($column) {
            $column.FormatString = '$#,0.00;($#,0.00);$#,0.00'
        }
    }

    $unitsColumn = $financials.Columns.Find('Units Sold')
    if ($unitsColumn) {
        $unitsColumn.FormatString = '#,0'
    }

    $null = Upsert-Measure -Table $measureTable -Name 'Sales' -Expression "SUM('financials'[Sales])" -FormatString '$#,0.00;($#,0.00);$#,0.00' -Description 'Net sales after discounts.'
    $null = Upsert-Measure -Table $measureTable -Name 'Gross Sales' -Expression "SUM('financials'[Gross Sales])" -FormatString '$#,0.00;($#,0.00);$#,0.00' -Description 'Sales before discounts.'
    $null = Upsert-Measure -Table $measureTable -Name 'Discounts' -Expression "SUM('financials'[Discounts])" -FormatString '$#,0.00;($#,0.00);$#,0.00' -Description 'Total discounts.'
    $null = Upsert-Measure -Table $measureTable -Name 'COGS' -Expression "SUM('financials'[COGS])" -FormatString '$#,0.00;($#,0.00);$#,0.00' -Description 'Cost of goods sold.'
    $null = Upsert-Measure -Table $measureTable -Name 'Profit' -Expression "SUM('financials'[Profit])" -FormatString '$#,0.00;($#,0.00);$#,0.00' -Description 'Net profit.'
    $null = Upsert-Measure -Table $measureTable -Name 'Units Sold' -Expression "SUM('financials'[Units Sold])" -FormatString '#,0' -Description 'Total units sold.'
    $null = Upsert-Measure -Table $measureTable -Name 'Average Sale Price' -Expression "DIVIDE([Sales], [Units Sold])" -FormatString '$#,0.00;($#,0.00);$#,0.00' -Description 'Net sales per unit sold.'
    $null = Upsert-Measure -Table $measureTable -Name 'Profit Margin %' -Expression "DIVIDE([Profit], [Sales])" -FormatString '0.00%' -DisplayFolder 'Margin and Discount' -Description 'Profit divided by net sales.'
    $null = Upsert-Measure -Table $measureTable -Name 'Discount %' -Expression "DIVIDE([Discounts], [Gross Sales])" -FormatString '0.00%' -DisplayFolder 'Margin and Discount' -Description 'Discount amount divided by gross sales.'
    $null = Upsert-Measure -Table $measureTable -Name 'Sales YTD' -Expression "TOTALYTD([Sales], 'Date'[Date])" -FormatString '$#,0.00;($#,0.00);$#,0.00' -DisplayFolder 'Time Intelligence' -Description 'Year-to-date net sales.'
    $null = Upsert-Measure -Table $measureTable -Name 'Profit YTD' -Expression "TOTALYTD([Profit], 'Date'[Date])" -FormatString '$#,0.00;($#,0.00);$#,0.00' -DisplayFolder 'Time Intelligence' -Description 'Year-to-date profit.'
    $null = Upsert-Measure -Table $measureTable -Name 'Sales Previous Year' -Expression "CALCULATE([Sales], SAMEPERIODLASTYEAR('Date'[Date]))" -FormatString '$#,0.00;($#,0.00);$#,0.00' -DisplayFolder 'Time Intelligence' -Description 'Net sales in the equivalent prior-year period.'
    $null = Upsert-Measure -Table $measureTable -Name 'Sales YoY %' -Expression "DIVIDE([Sales] - [Sales Previous Year], [Sales Previous Year])" -FormatString '0.00%' -DisplayFolder 'Time Intelligence' -Description 'Year-over-year net sales growth.'

    $model.SaveChanges()

    [pscustomobject]@{
        Server = $ServerName
        Database = $database.Name
        Tables = $model.Tables.Count
        Measures = $measureTable.Measures.Count
        Relationships = $model.Relationships.Count
        DateTable = $dateTable.Name
    } | ConvertTo-Json -Depth 4
}
finally {
    $server.Disconnect()
}

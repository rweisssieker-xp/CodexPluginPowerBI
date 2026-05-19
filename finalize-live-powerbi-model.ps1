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
    $model = $database.Model

    $financials = $model.Tables.Find('financials')
    $dateTable = $model.Tables.Find('Date')
    $measureTable = $model.Tables.Find('_Measures')

    if (-not $financials -or -not $dateTable -or -not $measureTable) {
        throw 'Expected tables financials, Date, and _Measures were not found.'
    }

    foreach ($column in $measureTable.Columns) {
        $column.IsHidden = $true
    }

    $dateColumn = $dateTable.Columns.Find('Date')
    $yearColumn = $dateTable.Columns.Find('Year')
    $monthNumberColumn = $dateTable.Columns.Find('Month Number')
    $monthNameColumn = $dateTable.Columns.Find('Month Name')
    $quarterNumberColumn = $dateTable.Columns.Find('Quarter Number')
    $quarterColumn = $dateTable.Columns.Find('Quarter')
    $yearMonthColumn = $dateTable.Columns.Find('Year Month')

    if ($dateColumn) {
        $dateColumn.FormatString = 'Short Date'
        $dateColumn.DataCategory = 'PaddedDateTableDates'
        $dateColumn.Description = 'Continuous calendar date.'
    }
    if ($yearColumn) {
        $yearColumn.FormatString = '0'
        $yearColumn.DataCategory = 'Years'
        $yearColumn.SummarizeBy = [Microsoft.AnalysisServices.Tabular.AggregateFunction]::None
    }
    if ($monthNumberColumn) {
        $monthNumberColumn.FormatString = '0'
        $monthNumberColumn.DataCategory = 'MonthOfYear'
        $monthNumberColumn.SummarizeBy = [Microsoft.AnalysisServices.Tabular.AggregateFunction]::None
    }
    if ($monthNameColumn) {
        $monthNameColumn.DataCategory = 'Months'
        if ($monthNumberColumn) { $monthNameColumn.SortByColumn = $monthNumberColumn }
    }
    if ($quarterNumberColumn) {
        $quarterNumberColumn.FormatString = '0'
        $quarterNumberColumn.DataCategory = 'QuarterOfYear'
        $quarterNumberColumn.SummarizeBy = [Microsoft.AnalysisServices.Tabular.AggregateFunction]::None
    }
    if ($quarterColumn) {
        $quarterColumn.DataCategory = 'Quarters'
        if ($quarterNumberColumn) { $quarterColumn.SortByColumn = $quarterNumberColumn }
    }
    if ($yearMonthColumn) {
        $yearMonthColumn.Description = 'Year-month label for chronological reporting.'
        if ($dateColumn) { $yearMonthColumn.SortByColumn = $dateColumn }
    }

    $financialsDateColumn = $financials.Columns.Find('Date')
    if (-not $financialsDateColumn -or -not $dateColumn) {
        throw 'Could not find the source and target date columns for the relationship.'
    }

    $relationshipExists = $false
    foreach ($relationship in $model.Relationships) {
        if ($relationship.FromTable.Name -eq 'financials' -and
            $relationship.FromColumn.Name -eq 'Date' -and
            $relationship.ToTable.Name -eq 'Date' -and
            $relationship.ToColumn.Name -eq 'Date') {
            $relationshipExists = $true
            $relationship.IsActive = $true
            $relationship.CrossFilteringBehavior = [Microsoft.AnalysisServices.Tabular.CrossFilteringBehavior]::OneDirection
        }
    }

    if (-not $relationshipExists) {
        $relationship = [Microsoft.AnalysisServices.Tabular.SingleColumnRelationship]::new()
        $relationship.Name = 'financials Date -> Date'
        $relationship.FromColumn = $financialsDateColumn
        $relationship.ToColumn = $dateColumn
        $relationship.FromCardinality = [Microsoft.AnalysisServices.Tabular.RelationshipEndCardinality]::Many
        $relationship.ToCardinality = [Microsoft.AnalysisServices.Tabular.RelationshipEndCardinality]::One
        $relationship.CrossFilteringBehavior = [Microsoft.AnalysisServices.Tabular.CrossFilteringBehavior]::OneDirection
        $relationship.IsActive = $true
        $model.Relationships.Add($relationship)
    }

    $model.SaveChanges()

    [pscustomobject]@{
        Server = $ServerName
        Database = $database.Name
        Tables = $model.Tables.Count
        Measures = $measureTable.Measures.Count
        Relationships = $model.Relationships.Count
        MeasureColumnsHidden = ($measureTable.Columns | Where-Object { $_.IsHidden }).Count
    } | ConvertTo-Json -Depth 4
}
finally {
    $server.Disconnect()
}

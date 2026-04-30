Add-Type -Path 'C:\Program Files\DAX Studio\bin\Microsoft.AnalysisServices.Tabular.dll'

$serverName = 'localhost:57411'
$server = [Microsoft.AnalysisServices.Tabular.Server]::new()
$server.Connect($serverName)

try {
    $database = $server.Databases[0]
    $model = $database.Model

    $accessTableName = 'RLS_UserAccess'
    $accessTable = $model.Tables.Find($accessTableName)
    if (-not $accessTable) {
        $accessTable = [Microsoft.AnalysisServices.Tabular.Table]::new()
        $accessTable.Name = $accessTableName
        $accessTable.IsHidden = $true

        $partition = [Microsoft.AnalysisServices.Tabular.Partition]::new()
        $partition.Name = $accessTableName
        $partition.Source = [Microsoft.AnalysisServices.Tabular.CalculatedPartitionSource]@{
            Expression = @"
FILTER(
    DATATABLE(
        "UserPrincipalName", STRING,
        "SecLevel", INTEGER,
        "RoleName", STRING,
        "ScopeType", STRING,
        "ScopeKey", STRING,
        {
            { "example.user@company.com", 5, "Team Member", "Resource", "00000000-0000-0000-0000-000000000000" }
        }
    ),
    FALSE()
)
"@
        }
        $accessTable.Partitions.Add($partition)

        foreach ($columnName in @('UserPrincipalName', 'RoleName', 'ScopeType', 'ScopeKey')) {
            $column = [Microsoft.AnalysisServices.Tabular.CalculatedTableColumn]::new()
            $column.Name = $columnName
            $column.SourceColumn = "[$columnName]"
            $column.DataType = [Microsoft.AnalysisServices.Tabular.DataType]::String
            $accessTable.Columns.Add($column)
        }

        $secLevel = [Microsoft.AnalysisServices.Tabular.CalculatedTableColumn]::new()
        $secLevel.Name = 'SecLevel'
        $secLevel.SourceColumn = '[SecLevel]'
        $secLevel.DataType = [Microsoft.AnalysisServices.Tabular.DataType]::Int64
        $accessTable.Columns.Add($secLevel)

        $model.Tables.Add($accessTable)
    }

    function Ensure-Role {
        param(
            [Microsoft.AnalysisServices.Tabular.Model]$Model,
            [string]$Name
        )

        $role = $Model.Roles.Find($Name)
        if (-not $role) {
            $role = [Microsoft.AnalysisServices.Tabular.ModelRole]::new()
            $role.Name = $Name
            $role.ModelPermission = [Microsoft.AnalysisServices.Tabular.ModelPermission]::Read
            $Model.Roles.Add($role)
        }
        return $role
    }

    function Set-TableFilter {
        param(
            [Microsoft.AnalysisServices.Tabular.ModelRole]$Role,
            [Microsoft.AnalysisServices.Tabular.Table]$Table,
            [string]$Expression
        )

        $permission = $Role.TablePermissions.Find($Table.Name)
        if (-not $permission) {
            $permission = [Microsoft.AnalysisServices.Tabular.TablePermission]::new()
            $permission.Table = $Table
            $Role.TablePermissions.Add($permission)
        }
        $permission.FilterExpression = $Expression
    }

    $portfolioRole = Ensure-Role -Model $model -Name 'RLS_01_Portfolio_Manager'
    $buRole = Ensure-Role -Model $model -Name 'RLS_02_BU_Bereichsleiter'
    $leadRole = Ensure-Role -Model $model -Name 'RLS_03_Lead_Head'
    $pmRole = Ensure-Role -Model $model -Name 'RLS_04_Project_Manager'
    $teamRole = Ensure-Role -Model $model -Name 'RLS_05_Team_Member'

    $departments = $model.Tables.Find('Departments')
    $resources = $model.Tables.Find('Resources')

    Set-TableFilter -Role $buRole -Table $departments -Expression @"
'Departments'[DepartmentID] IN
SELECTCOLUMNS(
    FILTER(
        'RLS_UserAccess',
        LOWER('RLS_UserAccess'[UserPrincipalName]) = LOWER(USERPRINCIPALNAME())
            && 'RLS_UserAccess'[ScopeType] IN { "BU", "Department" }
    ),
    "ScopeKey", 'RLS_UserAccess'[ScopeKey]
)
"@

    Set-TableFilter -Role $leadRole -Table $departments -Expression @"
'Departments'[DepartmentID] IN
SELECTCOLUMNS(
    FILTER(
        'RLS_UserAccess',
        LOWER('RLS_UserAccess'[UserPrincipalName]) = LOWER(USERPRINCIPALNAME())
            && 'RLS_UserAccess'[ScopeType] IN { "Department", "Team", "CostCenter" }
    ),
    "ScopeKey", 'RLS_UserAccess'[ScopeKey]
)
"@

    Set-TableFilter -Role $pmRole -Table $resources -Expression @"
'Resources'[ResourceID] IN
SELECTCOLUMNS(
    FILTER(
        'Project Team',
        'Project Team'[ProjectID] IN
            SELECTCOLUMNS(
                FILTER(
                    'RLS_UserAccess',
                    LOWER('RLS_UserAccess'[UserPrincipalName]) = LOWER(USERPRINCIPALNAME())
                        && 'RLS_UserAccess'[ScopeType] = "Project"
                ),
                "ScopeKey", 'RLS_UserAccess'[ScopeKey]
            )
    ),
    "ResourceID", 'Project Team'[ResourceID]
)
"@

    Set-TableFilter -Role $teamRole -Table $resources -Expression @"
'Resources'[ResourceID] IN
SELECTCOLUMNS(
    FILTER(
        'RLS_UserAccess',
        LOWER('RLS_UserAccess'[UserPrincipalName]) = LOWER(USERPRINCIPALNAME())
            && 'RLS_UserAccess'[ScopeType] = "Resource"
    ),
    "ScopeKey", 'RLS_UserAccess'[ScopeKey]
)
"@

    $model.SaveChanges()

    [pscustomobject]@{
        Server = $serverName
        Database = $database.Name
        AccessTable = $accessTableName
        Roles = @(
            $portfolioRole.Name,
            $buRole.Name,
            $leadRole.Name,
            $pmRole.Name,
            $teamRole.Name
        )
    } | ConvertTo-Json -Depth 4
}
finally {
    $server.Disconnect()
}

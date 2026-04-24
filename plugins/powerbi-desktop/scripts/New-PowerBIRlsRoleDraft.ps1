param([string]$RoleName = 'Sales Region Access', [string]$TableName, [string]$FilterExpression, [string]$OutputPath, [switch]$Json)
$ErrorActionPreference = 'Stop'
$tmdl = "role $RoleName`n    tablePermission $TableName = ```$FilterExpression```"
$result = [pscustomobject]@{ schema = 'codex.powerbi.rlsRoleDraft.v1'; objectType = 'RLSRole'; roleName = $RoleName; tableName = $TableName; filterExpression = $FilterExpression; tmdl = $tmdl; validation = 'Validate with View As Role in Power BI Desktop and service workspace security settings.' }
if ($Json) { $text = $result | ConvertTo-Json -Depth 6; if ($OutputPath) { Set-Content -LiteralPath $OutputPath -Value $text -Encoding UTF8 }; $text; return }
$result


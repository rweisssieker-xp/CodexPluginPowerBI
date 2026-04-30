# PBIP Apply Engine

The PBIP Apply Engine is the write path for text-based Power BI project changes. It intentionally avoids binary `.pbix` editing.

## Operating Model

1. Draft the desired artifact.
2. Review the generated TMDL, M, JSON, or report-page output.
3. Apply only to the intended PBIP folder with `-Apply`.
4. Generate an apply plan.
5. Open Power BI Desktop, refresh metadata, and validate.
6. Run tests and release gates.

## Draft Commands

```powershell
.\plugins\powerbi-desktop\scripts\New-PowerBIMeasureDraft.ps1 `
  -TableName Sales `
  -MeasureName "Average Sales" `
  -Expression "DIVIDE([Total Sales], COUNTROWS('Sales'))"

.\plugins\powerbi-desktop\scripts\New-PowerBICalculatedColumnDraft.ps1 `
  -TableName Sales `
  -ColumnName "Sales Band" `
  -Expression "IF('Sales'[Amount] > 1000, `"High`", `"Standard`")"

.\plugins\powerbi-desktop\scripts\New-PowerBIPowerQueryDraft.ps1 `
  -QueryName DimDate `
  -SourceKind DateTable
```

## Apply Commands

Apply scripts require `-Apply` before writing files:

```powershell
.\plugins\powerbi-desktop\scripts\Apply-PowerBIPBIPMeasureDraft.ps1 `
  -PbipPath .\MyReport `
  -TableName Sales `
  -MeasureName "Average Sales" `
  -Expression "DIVIDE([Total Sales], COUNTROWS('Sales'))" `
  -Apply
```

Other apply scripts:

- `Apply-PowerBIPBIPCalculatedColumnDraft.ps1`
- `Apply-PowerBIPBIPPowerQueryDraft.ps1`
- `Apply-PowerBIPBIPTmdlDraft.ps1`
- `Add-PowerBIPBIPReportPage.ps1`

## Apply Plan

```powershell
.\plugins\powerbi-desktop\scripts\Invoke-PowerBIPBIPApplyPlan.ps1 `
  -PbipPath .\MyReport `
  -OutputPath .\powerbi-apply-plan\apply-plan.json
```

The apply plan lists generated artifacts and gives review context for PRs.

## Rollback Guidance

The plugin expects source control to be the rollback mechanism for PBIP projects. Before applying to a real project:

- Commit or stash unrelated work.
- Apply one logical change set at a time.
- Review generated TMDL/M/JSON before opening Desktop.
- Run model checks after Desktop reloads the project.

## PBIX Compile Workflow

Use this to document the handoff from PBIP source to PBIX output:

```powershell
.\plugins\powerbi-desktop\scripts\New-PowerBIPBIXCompileWorkflow.ps1 `
  -PbipPath .\MyReport `
  -OutputPbix .\MyReport.pbix
```

The plugin does not silently compile or publish reports.

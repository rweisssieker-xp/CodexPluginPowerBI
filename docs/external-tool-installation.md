# External Tool Installation

Generate the registration file:

```powershell
.\plugins\powerbi-desktop\scripts\New-PowerBIExternalToolRegistration.ps1 -OutputPath .\CodexPowerBIWorkbench.pbitool.json
```

Install it into the machine-wide Power BI Desktop External Tools folder:

```powershell
.\plugins\powerbi-desktop\scripts\Install-PowerBIExternalTool.ps1
```

Remove it again:

```powershell
.\plugins\powerbi-desktop\scripts\Uninstall-PowerBIExternalTool.ps1
```

Restart Power BI Desktop after install or uninstall. The External Tools menu is loaded during Desktop startup.

The registration launches `Invoke-PowerBIUnifiedReview.ps1` through `powershell.exe` and writes output to `%TEMP%\CodexPowerBIUnifiedReview`.

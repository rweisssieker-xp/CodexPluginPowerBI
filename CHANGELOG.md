# Changelog

## 2026-04-27

### Power BI Live Model Review

- Live-Verbindung zum aktuell geöffneten Power-BI-Desktop-Modell geprüft.
  - Server: `localhost:57411`
  - Modellumfang: 151 Tabellen, 2013 Spalten, 41 initiale Measures, 146 Beziehungen
- Modellzusammenfassung erzeugt:
  - `powerbi-live-model-summary.md`
  - `powerbi-live-auto-review/live-model-summary.md`
  - `powerbi-live-auto-review/live-insight-scan.md`
- Auffälligkeiten festgehalten:
  - sehr viele versteckte `LocalDateTable_*` Tabellen
  - fehlende Measure-Beschreibungen
  - volatile Datumslogik bei `Days Last Report`
  - komplexes Measure `_Period Total Hours (Dept aware incl blank)`

### RLS / Rollenkonzept

- Im offenen Power-BI-Modell fünf Rollen angelegt:
  - `RLS_01_Portfolio_Manager`
  - `RLS_02_BU_Bereichsleiter`
  - `RLS_03_Lead_Head`
  - `RLS_04_Project_Manager`
  - `RLS_05_Team_Member`
- Versteckte Hilfstabelle `RLS_UserAccess` angelegt.
- Dynamische RLS-Filter vorbereitet:
  - BU-/Bereichsleiter und Lead/Head filtern über `Departments[DepartmentID]`.
  - Project Manager filtern über `Resources[ResourceID]` anhand der Projektteam-Zuordnung in `Project Team`.
  - Team Member filtern über `Resources[ResourceID]`.
- Hinweis: `RLS_04_Project_Manager` wurde nicht direkt auf `Projects` gesetzt, weil Power BI wegen einer Beziehung mit Security-Filterverhalten `Both` das Speichern blockiert hat.
- Lokales Hilfsskript erstellt:
  - `apply-rls-roles.ps1`

### Status-Report Text Measures

- DAX-Pattern für textuelle Statusfelder zum jeweils neuesten `Report Date` erarbeitet.
- Folgende Measures wurden im Modell vorgefunden bzw. genutzt:
  - `Latest Status Summary`
  - `Latest Accomplished Activities`
  - `Latest Accomplished Activities Simple`
  - `Latest Planned Activities`
- Ziel: Textfelder wie `Status Summary`, `Accomplished Activities` und `Planned Activities` nicht alphabetisch aggregieren, sondern passend zum neuesten Statusbericht anzeigen.

### TimesheetLines Power Query

- Ursache für fehlende Umlaute analysiert:
  - `TimesheetLines` nutzt `owneridname` / `tpg_submittername`.
  - `Resources[ResourceName]` enthält korrekte Umlaute.
  - `Resources[tpg_resourcename]` und `Resources[tpg_username]` enthalten normalisierte Schreibweisen.
- Power-Query-Definition von `TimesheetLines` direkt aus dem Live-Modell ausgelesen.
- Lösung erarbeitet:
  - Resource-Name mit Umlauten direkt in der SQL Native Query über `[dbo].[tpg_resourcepool]` ermitteln.
  - Kein Power-Query-Merge auf separate `Resources`-Abfrage, da das zu einem Datenkombinationsfehler geführt hat.
  - Join auf `tpg_resourcepool` aggregiert, damit keine Timesheet-Zeilen vervielfacht werden:
    - `GROUP BY tpg_user`
    - `MAX(tpg_name) AS tpg_name`
- Lokales Hilfsskript erstellt:
  - `inspect-powerquery.ps1`
- Lokaler Dump erstellt:
  - `powerquery-source-dump.txt`

### Project Business KPIs

- In Tabelle `Projects` neue Measures unter `Business KPIs` angelegt:
  - `_Projects Without Recent Status`
  - `_Status Report Compliance %`
  - `_Overdue Projects`
  - `_Projects Ending Next 30 Days`
  - `_Average Project Duration Days`
  - `_Project Progress %`
  - `_Projects At Risk by Progress`
  - `_Project Cost Variance %`
  - `_Forecast Budget Overrun`
  - `_Forecast Budget Overrun %`
  - `_Effort Variance`
  - `_Effort Burn Rate %`
- Measures per DAX-Abfrage validiert.
- Lokales Hilfsskript erstellt:
  - `add-project-business-measures.ps1`

### Resource Business KPIs

- In Tabelle `Resources` neue Measures unter `Business KPIs` angelegt:
  - `_Resource Demand Hours`
  - `_Resource Demand Hours excl. ATOSS`
  - `_Resource Capacity Gap Hours`
  - `_Resource Capacity Gap %`
  - `_Resources Overallocated`
  - `_Resources Critically Overallocated`
  - `_Resources Underutilized`
  - `_Resources Without Demand`
  - `_Resources Without Capacity`
  - `_Resources With Demand No Capacity`
  - `_Timesheet Coverage %`
  - `_Timesheet vs Demand Gap Hours`
  - `_Planned vs Actual Utilization Gap %`
  - `_Avg Demand per Resource`
  - `_Avg Capacity per Resource`
  - `_Avg Timesheet Hours per Resource`
  - `_Available Capacity Hours`
  - `_Overallocated Hours`
  - `_Overallocated Hours %`
  - `_Resources Missing Department`
  - `_Resource Master Data Completeness %`
- Measures per DAX-Abfrage validiert.
- Lokales Hilfsskript erstellt:
  - `add-resource-business-measures.ps1`

### Control Tower KPIs

- Neue Tabelle `KPI Thresholds` als Schwellenwert-Dokumentation angelegt.
- Hinweis: Die produktiven Control-Tower-Measures nutzen feste Defaultwerte direkt im DAX, weil die neu angelegte berechnete Tabelle im Live-Desktop-Modell erst nach Refresh materialisiert wird.
- In Tabelle `Projects` neue Measures unter `Business KPIs\Control Tower` angelegt:
  - `_Project Schedule Risk Score`
  - `_Project Cost Risk Score`
  - `_Project Status Quality Score`
  - `_Project Overall Risk Score`
  - `_Project Delivery Confidence %`
  - `_Project Risk Category`
  - `_Project Risk Color`
  - `_Project Attention Reason`
  - `_Projects Requiring Attention`
  - `_Projects Due Soon And Low Progress`
  - `_Projects Over Forecast Budget`
  - `_Portfolio Investment at Risk`
  - `_High Value Projects at Risk`
  - `_Projects With Stale Status`
- In Tabelle `Resources` neue Measures unter `Business KPIs\Control Tower` angelegt:
  - `_Resource Overload Score`
  - `_Resource Availability Score`
  - `_Resource Forecast Quality Score`
  - `_Resource Bottleneck Score`
  - `_Department Capacity Risk Score`
  - `_Resource Load Category`
  - `_Resource Load Color`
  - `_Resource Attention Reason`
  - `_Resources Overallocated Next 30 Days`
  - `_Resources Overallocated Next 90 Days`
  - `_Resources Underutilized Next 30 Days`
  - `_Demand Without Capacity Hours`
  - `_Missing Timesheet Hours`
  - `_Forecast Accuracy %`
  - `_Demand vs Actual Variance Hours`
  - `_Resources With Missing Master Data`
- Measures per DAX-Abfrage validiert.
- Lokale Hilfsskripte erstellt:
  - `add-control-tower-measures.ps1`
  - `patch-control-tower-hardcoded-thresholds.ps1`

### Lokale Analyse-/Exportdateien

- Folgende lokale Dateien wurden im Workspace erzeugt:
  - `live-levels.json`
  - `live-partitions.json`
  - `live-tables.json`
  - `live-expressions.json`
  - `live-measures.json`
  - `live-measures-before-resource-kpis.json`
  - `live-measures-after-project-kpis.json`
  - `live-measures-after-resource-kpis.json`
  - `live-measures-after-control-tower.json`
  - `live-measures-visibility.json`
  - `powerquery-source-dump.txt`

### Wichtige Hinweise

- Alle Modelländerungen wurden über die Live-Verbindung in das aktuell geöffnete Power-BI-Desktop-Modell geschrieben.
- Power BI Desktop muss gespeichert werden, damit die Änderungen im PBIX erhalten bleiben.
- Falls Measures im Feldbereich nicht sofort sichtbar sind:
  - Modell speichern
  - Power BI Desktop schließen und erneut öffnen
  - in den Tabellen `Projects` und `Resources` nach `_` oder nach dem Ordner `Business KPIs` suchen
- Die RLS-Hilfstabelle `RLS_UserAccess` muss mit echten Benutzer-/Scope-Zuordnungen befüllt werden, bevor die restriktiven Rollen produktiv nutzbar sind.

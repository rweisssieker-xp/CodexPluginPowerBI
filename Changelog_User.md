# Changelog fuer Anwender

## 2026-04-27

### Neue Projekt-Kennzahlen

Im Bereich `Projects` wurden neue Business-KPIs ergaenzt. Diese helfen dabei, Projekte schneller nach Aktualitaet, Terminrisiko, Fortschritt, Budget und Aufwand zu bewerten.

Neue Kennzahlen:

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

Nutzen fuer Anwender:

- Projekte ohne aktuellen Statusbericht schneller erkennen
- ueberfaellige Projekte identifizieren
- Projekte mit Terminrisiko erkennen
- Budgetueberschreitungen sichtbar machen
- Aufwand und Forecast besser vergleichen

### Neuer Projekt-Control-Tower

Im Bereich `Projects` wurde der Ordner `Business KPIs\Control Tower` ergaenzt.

Neue Kennzahlen:

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

Nutzen fuer Anwender:

- Projekte nach Risiko sortieren
- kritische Projekte schneller erkennen
- sehen, warum ein Projekt Aufmerksamkeit braucht
- Portfolio-Investitionen mit Risiko auswerten
- Management- und PMO-Sichten gezielter aufbauen

### Neue Ressourcen-Kennzahlen

Im Bereich `Resources` wurden neue Business-KPIs ergaenzt. Diese helfen bei Kapazitaetsplanung, Auslastung, Timesheet-Abgleich und Datenqualitaet.

Neue Kennzahlen:

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

Nutzen fuer Anwender:

- Ueberlastete Ressourcen erkennen
- freie Kapazitaeten sichtbar machen
- Ressourcen ohne Demand oder ohne Kapazitaet finden
- Forecast und gebuchte Zeiten vergleichen
- Stammdatenqualitaet bewerten

### Neuer Ressourcen-Control-Tower

Im Bereich `Resources` wurde der Ordner `Business KPIs\Control Tower` ergaenzt.

Neue Kennzahlen:

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

Nutzen fuer Anwender:

- Ressourcen-Engpaesse priorisieren
- Bereichs- und Abteilungsrisiken erkennen
- Forecast-Qualitaet bewerten
- Auslastungskategorien wie `Healthy`, `Watch` und `Critical` verwenden
- konkrete Gruende fuer Aufmerksamkeit anzeigen

### Rollen und Berechtigungen

Es wurden Rollen fuer das vorgesehene Berechtigungskonzept vorbereitet:

- `RLS_01_Portfolio_Manager`
- `RLS_02_BU_Bereichsleiter`
- `RLS_03_Lead_Head`
- `RLS_04_Project_Manager`
- `RLS_05_Team_Member`

Nutzen fuer Anwender:

- Portfolio Manager koennen eine breite Portfolio-Sicht erhalten
- Bereichsleiter koennen auf eigene Bereiche eingeschraenkt werden
- Leads koennen auf Teams oder Kostenstellen eingeschraenkt werden
- Project Manager koennen auf eigene Projektteam-Ressourcen eingeschraenkt werden
- Team Member koennen auf eigene Daten eingeschraenkt werden

Hinweis:

Die Benutzerzuordnung muss noch in der Tabelle `RLS_UserAccess` gepflegt werden.

### TimesheetLines: Ressourcennamen mit Umlauten

Die Logik fuer `TimesheetLines` wurde so angepasst, dass Ressourcennamen mit Umlauten aus dem Ressourcenstamm verwendet werden koennen.

Nutzen fuer Anwender:

- Namen wie `Mueller`, `Poertner`, `Struessmann` koennen wieder korrekt als `Mueller/Mueller`-Quelle ersetzt werden, sofern der Ressourcenstamm den Namen mit Umlaut enthaelt.
- Die Anzeige von Ressourcennamen wird fachlich sauberer und konsistenter.

### Statusbericht-Texte

Fuer Statusbericht-Texte wurde eine Logik erarbeitet, damit Textfelder nicht alphabetisch, sondern passend zum neuesten `Report Date` angezeigt werden.

Betroffene Inhalte:

- Status Summary
- Accomplished Activities
- Planned Activities

Nutzen fuer Anwender:

- Karten und Detailanzeigen zeigen den Text des neuesten Statusberichts
- keine falsche Anzeige durch alphabetische First-/Last-Textaggregation

### Hinweise zur Nutzung

- Neue Kennzahlen beginnen mit `_`.
- Projektkennzahlen befinden sich in `Projects`.
- Ressourcenkennzahlen befinden sich in `Resources`.
- Viele neue Kennzahlen liegen im Ordner `Business KPIs`.
- Control-Tower-Kennzahlen liegen im Ordner `Business KPIs\Control Tower`.
- Falls neue Kennzahlen nicht sofort sichtbar sind:
  - Bericht speichern
  - Power BI Desktop neu oeffnen
  - im Feldbereich nach `_Project`, `_Resource`, `_Forecast`, `_Risk` oder `_Timesheet` suchen

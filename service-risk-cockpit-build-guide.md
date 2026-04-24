# Service Risk Cockpit

## Page setup

- Page name: `Service Risk Cockpit`
- Page size: 16:9
- Purpose: one executive row, one action queue, one owner/customer risk section.

## Top KPI row

Use cards:

- `_SRA_Service Health Score`
- `_SRA_Service Health Status`
- `_SRA_Action Queue Size`
- `_SRA_Open Critical Tickets`
- `_SRA_SLA Exposure Share`
- `_SRA_Next Best Action Summary`

## Action queue table

Use a table visual with these fields:

- `IncidentsAllFields[incidentid]`
- `IncidentsAllFields[SRA Risk Score]`
- `IncidentsAllFields[SRA Risk Band]`
- `IncidentsAllFields[SRA Recommended Action]`
- `IncidentsAllFields[statuscodename]`
- `IncidentsAllFields[pdw_priority_codename]`
- `IncidentsAllFields[owneridname]`
- `IncidentsAllFields[contactidname]`
- `IncidentsAllFields[resolveby]`

Sort:

- Primary: `IncidentsAllFields[SRA Risk Score]` descending
- Secondary: `IncidentsAllFields[resolveby]` ascending

Visual filters:

- `IncidentsAllFields[SRA Recommended Action]` is not `Monitor`
- `IncidentsAllFields[SRA Recommended Action]` is not `No action - closed`

Conditional formatting:

- `SRA Risk Score`: color scale from green to red
- `SRA Risk Band`: Critical red, Action Required orange, Watch amber, Low Risk green

## Risk distribution

Use a stacked bar or donut:

- Legend: `IncidentsAllFields[SRA Risk Band]`
- Values: `_CountIncidents`
- Sort helper: `IncidentsAllFields[SRA Risk Band Sort]`

## Owner risk

Use a bar chart:

- Axis: `IncidentsAllFields[owneridname]`
- Values: `_SRA_Owner Load Risk Score`
- Tooltip: `_SRA_Action Required Tickets`, `_SRA_Open Critical Tickets`, `_Open_Incidents`
- Filter: top 10 by `_SRA_Owner Load Risk Score`

## Customer risk

Use a bar chart:

- Axis: `IncidentsAllFields[contactidname]`
- Values: `_SRA_Average Risk Score`
- Tooltip: `_SRA_Action Required Tickets`, `_SRA_Open Critical Tickets`, `_CountIncidents`
- Filter: top 10 by `_SRA_Average Risk Score`

## Drillthrough recommendation

Create a ticket detail drillthrough page with:

- `incidentid`
- `description`
- `pdw_resolution`
- `createdon`
- `resolveby`
- `responseby`
- `pdw_resolutiondate`
- `SRA Risk Score`
- `SRA Recommended Action`

## Current model additions

Measures:

- `_SRA_Service Health Score`
- `_SRA_Service Health Status`
- `_SRA_Next Best Action Summary`
- `_SRA_Action Queue Size`
- `_SRA_Ticket Risk Score`
- `_SRA_Ticket Risk Band`
- `_SRA_Ticket Recommended Action`

Calculated columns:

- `IncidentsAllFields[SRA Risk Score]`
- `IncidentsAllFields[SRA Risk Band]`
- `IncidentsAllFields[SRA Risk Band Sort]`
- `IncidentsAllFields[SRA Recommended Action]`

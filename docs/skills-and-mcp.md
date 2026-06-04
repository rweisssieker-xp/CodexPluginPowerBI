# Skills And MCP Surface

The Power BI Desktop plugin currently exposes Codex skills and local PowerShell scripts. It does not bundle an MCP server.

## Skill Surface

The plugin manifest points Codex to `plugins/powerbi-desktop/skills`. The current skill set is:

- `powerbi-desktop`: primary Power BI Desktop, PBIP, DAX, Power Query, Fabric read-only, release QA, governance, and safety workflow.
- `powerbi-autonomous-planning-loop`: closed-loop actuals, forecast, gap, scenario, action, tracking, and learning cycle.
- `powerbi-goal-seeking-planning`: target-back planning for budget, roll forecast, margin, and cash goals.
- `powerbi-constraint-aware-planning`: delivery, capacity, inventory, margin, cash, customer, and sales-resource feasibility checks.
- `powerbi-revenue-digital-twin`: scenario model for revenue target gaps and rescue levers.
- `powerbi-autonomous-forecast-agents`: multi-agent forecast council with dissent and arbitration.
- `powerbi-autonomous-exception-management`: planning exception detection, ownership hints, status, and closure evidence.
- `powerbi-revenue-rescue-mode`: action board for forecast gaps and revenue rescue.
- `powerbi-forecast-trust-market`: forecast trust, override quality, model-vs-human accuracy, and bias tracking.
- `powerbi-causal-counterfactual-forecasting`: causal and counterfactual forecast scenario framing.
- `powerbi-self-healing-forecast-governance`: model demotion, unsafe recommendation blocking, and safer baseline routing.
- `powerbi-planning-memory`: append-only planning memory for assumptions, actions, overrides, actuals, and learning signals.
- `powerbi-planning-readiness-score`: readiness scoring for autonomous planning.
- `powerbi-forecast-war-room`: executive gap review, ownership, action status, and confidence monitoring.

## MCP Surface

There is no MCP server packaged with this plugin in v3.0.0. The plugin is intentionally local-first and script-driven:

- Skills guide Codex behavior.
- `plugin.json` exposes Marketplace capabilities and default prompts.
- PowerShell scripts under `plugins/powerbi-desktop/scripts` are the command surface.
- Fabric live v1 is read-only and token-file based; it produces local snapshots and does not expose a remote MCP dashboard or remote connector.

If an MCP server is added later, it should be documented here with its transport, commands, authentication model, safety boundaries, and generated artifacts before Marketplace submission.

## Safety Expectations

- Skills must preserve local-first behavior unless a user explicitly supplies live read-only evidence.
- Fabric live workflows must remain GET-only and token-file based.
- No skill should imply publish, promote, refresh trigger, rebind, delete, endorsement, or hidden login behavior.
- Secrets and tokens must not be written into generated findings, docs, or review artifacts.

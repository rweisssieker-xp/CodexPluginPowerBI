# Evaluate a Power BI visual with one known business case

This checklist complements the Power BI Desktop Codex plugin. It does not install a commercial visual or require source data to be uploaded to Aivana.

## Project and capacity review

1. Select a small, non-confidential project sample with unique task IDs, start/end dates, progress, dependency links and named resource assignments.
2. Supply workload and daily capacity in comparable units and periods. Two overlapping assignments are not enough to establish overload without capacity.
3. Pick one known dependency or capacity conflict and verify that the displayed task dates and resource totals match the source.
4. Compare against a supplied baseline. Agree the planning change in your source planning system; the visual does not directly write to the backend.

**Aivana's optional visual:** [Project Intelligence capabilities](https://aivana-gmbh.ai/en/powerbi-visuals/project-intelligence?utm_source=github&utm_medium=guide&utm_campaign=visual_trials_20261029) · [Request its trial](https://aivana-gmbh.ai/en/powerbi-visuals?product=project-intelligence&utm_source=github&utm_medium=guide&utm_campaign=visual_trials_20261029#trial).

## Financial variance and comment-context review

1. Choose a known actual/budget variance with explicit period, organisation and account/business keys.
2. Verify the actual, budget and variance arithmetic, including the intended handling of percentage denominators.
3. Add an explanation, change period or organisation, and verify that the explanation follows the intended context rather than appearing against unrelated data.
4. If persistent comments are required, separately configure and validate Fabric SQL storage, permissions and business-key mapping. Importing a visual alone does not create this integration.

**Aivana's optional visual:** [Financial Reporting capabilities](https://aivana-gmbh.ai/en/powerbi-visuals/financial-reporting?utm_source=github&utm_medium=guide&utm_campaign=visual_trials_20261029) · [Request its trial](https://aivana-gmbh.ai/en/powerbi-visuals?product=financial-reporting&utm_source=github&utm_medium=guide&utm_campaign=visual_trials_20261029#trial).

## Trial and deployment boundaries

Aivana develops these commercial visuals separately from the Codex plugin. Trial requests require name, company and confirmed email. Package availability, trial duration, licence terms and intended-host acceptance need confirmation. Source code is not included in a compiled visual trial. Microsoft DemoReport links require sign-in and existing report access.

Use synthetic or approved sample data for evaluation. Do not assume Microsoft certification, anonymous demo access, automated forecasts or backend writeback from a product link.

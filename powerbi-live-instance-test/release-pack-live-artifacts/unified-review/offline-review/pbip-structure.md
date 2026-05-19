# Power BI PBIP Structure

Readiness: **Limited** (0/100)
Roundtrip status: **Incomplete**
PBIP files: 0
Semantic model directories: 0
Report directories: 0
TMDL files: 0
Report metadata files: 0
Model metadata files: 0
Platform metadata files: 0

## Checks

- [Fail] PBIP entry point: A .pbip file is required as the source-controlled Desktop project entry point.
- [Fail] Semantic model folder: A *.SemanticModel folder is expected for realistic PBIP round-trip validation.
- [Fail] Semantic model definition: TMDL files, model.bim, or definition.pbism should be present for model round-tripping.
- [Warn] Report folder: A *.Report folder is expected when validating report layout round-tripping.
- [Warn] Report definition: Report metadata such as definition.pbir or report.json should be present.
- [Warn] Platform metadata: .platform files are usually present in complete PBIP artifacts.

## Roundtrip plan

- Validate PBIP entry point, *.SemanticModel, semantic definition files, and *.Report metadata.
- Run the trust release gate and resolve No-Go checks before producing a PBIX candidate.
- Compile with pbi-tools when available, otherwise open the PBIP in Power BI Desktop and Save As PBIX.
- Reopen the produced PBIX and rerun semantic tests plus live validation before any publishing step.

## Recommendations

- Create or export a PBIP entry point for source-controlled Desktop round-tripping.
- Export the semantic model to TMDL or model.bim before requesting structural changes.
- Export report metadata if layout or visual analysis is required.
- Include .platform metadata from Desktop/Git export to improve PBIP completeness checks.


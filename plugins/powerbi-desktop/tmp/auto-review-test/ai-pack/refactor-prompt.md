# AI Refactoring Prompt

Use context-pack.json to propose safe, text-based refactors.

Rules:
- do not edit binary PBIX/PBIT files
- propose exact DAX or Power Query replacements only when the source and target are clear
- include before/after snippets
- classify each change as safe, medium-risk, or high-risk
- include validation and rollback notes

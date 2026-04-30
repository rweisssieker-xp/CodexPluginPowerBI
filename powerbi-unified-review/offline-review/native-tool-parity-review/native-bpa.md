# Power BI Native Best Practice Analyzer

Rules: 8
Findings: 12

- [High] All Customer Sales: FILTER over ALL pattern - This pattern can be expensive on large models. Review whether KEEPFILTERS, REMOVEFILTERS, or a narrower table expression is possible.
- [Medium] All Customer Sales: Missing metric owner - Assign an accountable owner.
- [Medium] All Customer Sales: Missing business definition - Document meaning, grain, filters, and caveats.
- [Medium] Refresh Sensitive Sales: Volatile date/time function - TODAY/NOW can make refresh and testing behavior time-dependent. Consider a governed date table or refresh parameter.
- [Medium] Refresh Sensitive Sales: Missing metric owner - Assign an accountable owner.
- [Medium] Refresh Sensitive Sales: Missing business definition - Document meaning, grain, filters, and caveats.
- [Medium] Total Sales: Missing metric owner - Assign an accountable owner.
- [Medium] Total Sales: Missing business definition - Document meaning, grain, filters, and caveats.
- [Medium] Sales YoY %: Missing metric owner - Assign an accountable owner.
- [Medium] Sales YoY %: Missing business definition - Document meaning, grain, filters, and caveats.
- [Medium] Total Sales Prior Year: Missing metric owner - Assign an accountable owner.
- [Medium] Total Sales Prior Year: Missing business definition - Document meaning, grain, filters, and caveats.


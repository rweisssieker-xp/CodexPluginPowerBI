import importlib.util
import json
import unittest
from pathlib import Path


PLUGIN_ROOT = Path(__file__).parents[1]
MODULE_PATH = PLUGIN_ROOT / "scripts" / "support" / "powerbi_ai_forecast.py"
SPEC = importlib.util.spec_from_file_location("powerbi_ai_forecast", MODULE_PATH)
FORECAST = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(FORECAST)
FIXTURE_PATH = PLUGIN_ROOT / "examples" / "ai-forecast" / "segment-monthly.json"


class ForecastWorkerTests(unittest.TestCase):
    def setUp(self):
        self.rows = json.loads(FIXTURE_PATH.read_text(encoding="utf-8"))["rows"]

    def test_conversion_probability_is_bounded(self):
        self.assertEqual(FORECAST.conversion_probability(0, 200, 0.5), 0.0)
        self.assertEqual(FORECAST.conversion_probability(100, 500, 0.5), 0.95)

    def test_forecast_returns_reconciled_rows(self):
        rows = FORECAST.calculate_forecast(
            self.rows, 2026, 5, 6, "2026-05-31", 2, "HierarchyProductLine"
        )
        self.assertGreater(len(rows), 0)
        self.assertTrue(all(row["final_ai_forecast"] >= 0 for row in rows))
        self.assertTrue(all(row["forecast_low"] <= row["final_ai_forecast"] for row in rows))
        self.assertTrue(all(row["final_ai_forecast"] <= row["forecast_high"] for row in rows))


if __name__ == "__main__":
    unittest.main()

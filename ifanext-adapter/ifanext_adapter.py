#!/usr/bin/env python3
"""
ifanext file adapter for ophthalmology billing AI workflows.

The adapter normalizes exported practice-system records (CSV, JSON, BDT/GDT-like
line records) into a stable JSON structure that can be consumed by the
augenarzt-abrechnung skill or downstream BI/QA tooling.
"""

from __future__ import annotations

import argparse
import csv
import json
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterable


DEFAULT_MAPPING = {
    "case_id": ["fallnummer", "fall_id", "case_id", "aktenzeichen"],
    "patient_id": ["patient_id", "patnr", "patientennummer", "pid"],
    "insurance": ["versicherung", "kostentraeger", "insurance"],
    "date": ["datum", "leistungsdatum", "date"],
    "diagnoses": ["diagnose", "diagnosen", "icd", "icd10"],
    "services": ["leistung", "leistungen", "gop", "goae", "ziffer", "ziffern"],
    "provider": ["arzt", "behandler", "provider"],
    "eye": ["auge", "seite", "laterality"],
    "indication": ["indikation", "anlass", "begruendung"],
    "notes": ["notiz", "notizen", "befund", "text"],
}

GDT_FIELDS = {
    "3000": "patient_id",
    "3101": "last_name",
    "3102": "first_name",
    "3103": "birth_date",
    "6200": "notes",
    "6220": "notes",
    "8402": "device_context",
    "8410": "test_id",
}


@dataclass(frozen=True)
class AdapterConfig:
    mapping: dict[str, list[str]]


def load_config(path: Path | None) -> AdapterConfig:
    if not path:
        return AdapterConfig(DEFAULT_MAPPING)
    with path.open("r", encoding="utf-8-sig") as handle:
        raw = json.load(handle)
    mapping = raw.get("mapping", raw)
    return AdapterConfig({k: list(v) for k, v in mapping.items()})


def normalize_key(key: str) -> str:
    return (
        key.strip()
        .lower()
        .replace("ä", "ae")
        .replace("ö", "oe")
        .replace("ü", "ue")
        .replace("ß", "ss")
        .replace("-", "_")
        .replace(" ", "_")
    )


def first_value(row: dict[str, Any], aliases: Iterable[str]) -> Any:
    normalized = {normalize_key(k): v for k, v in row.items()}
    for alias in aliases:
        value = normalized.get(normalize_key(alias))
        if value not in (None, ""):
            return value
    return ""


def split_multi(value: Any) -> list[str]:
    if value in (None, ""):
        return []
    if isinstance(value, list):
        return [str(item).strip() for item in value if str(item).strip()]
    text = str(value)
    for separator in ["|", ";", "\n"]:
        if separator in text:
            return [part.strip() for part in text.split(separator) if part.strip()]
    return [text.strip()] if text.strip() else []


def classify_billing_area(insurance: str, services: list[str]) -> str:
    text = f"{insurance} {' '.join(services)}".lower()
    if any(token in text for token in ["pkv", "privat", "beihilfe", "goä", "goae"]):
        return "GOAE/PKV"
    if any(token in text for token in ["igel", "selbstzahler", "wunschleistung"]):
        return "IGeL/Selbstzahler"
    if any(token in text for token in ["bema"]):
        return "BEMA prüfen: im Augenarztkontext meist EBM gemeint"
    if any(token in text for token in ["gkv", "gesetzlich", "ebm", "gop"]):
        return "EBM/GKV"
    return "unbekannt"


def triage_record(record: dict[str, Any]) -> tuple[str, list[str], list[str]]:
    gaps: list[str] = []
    risks: list[str] = []

    if not record["medizin"]["diagnosen"]:
        gaps.append("Diagnose/ICD fehlt")
    if not record["medizin"]["leistungen"]:
        gaps.append("Leistung/Ziffer fehlt")
    if not record["medizin"]["indikation"]:
        gaps.append("Indikation fehlt")
    if not record["patient_context"]["versicherung"]:
        gaps.append("Versicherungsart/Kostenträger fehlt")

    billing_area = record["abrechnung"]["bereich"]
    if "BEMA" in billing_area:
        risks.append("BEMA im Augenarztkontext ist wahrscheinlich eine Begriffsverwechslung mit EBM")
    if billing_area == "GOAE/PKV" and not record["abrechnung"]["ziffer_kandidaten"]:
        risks.append("GOÄ-Kandidaten fehlen oder wurden nicht erkannt")
    if "analog" in " ".join(record["medizin"]["leistungen"]).lower():
        risks.append("Analogbewertung benötigt Quellen- und Begründungsprüfung")

    if risks and len(gaps) >= 2:
        triage = "D"
    elif risks or gaps:
        triage = "C"
    else:
        triage = "B"
    return triage, gaps, risks


def normalize_row(row: dict[str, Any], config: AdapterConfig) -> dict[str, Any]:
    services = split_multi(first_value(row, config.mapping["services"]))
    diagnoses = split_multi(first_value(row, config.mapping["diagnoses"]))
    insurance = str(first_value(row, config.mapping["insurance"]))
    billing_area = classify_billing_area(insurance, services)

    record = {
        "patient_context": {
            "case_id": first_value(row, config.mapping["case_id"]),
            "patient_id": first_value(row, config.mapping["patient_id"]),
            "versicherung": insurance,
            "datum": first_value(row, config.mapping["date"]),
            "behandler": first_value(row, config.mapping["provider"]),
        },
        "medizin": {
            "diagnosen": diagnoses,
            "leistungen": services,
            "auge": first_value(row, config.mapping["eye"]),
            "indikation": first_value(row, config.mapping["indication"]),
            "befunde": split_multi(first_value(row, config.mapping["notes"])),
        },
        "abrechnung": {
            "bereich": billing_area,
            "ziffer_kandidaten": services,
            "angesetzte_ziffern": services,
            "steigerung": "",
            "analog": any("analog" in item.lower() for item in services),
        },
        "pruefung": {
            "triage": "",
            "dokumentationsluecken": [],
            "ausschlussrisiken": [],
            "ablehnungsrisiken": [],
            "unterabrechnungsrisiken": [],
        },
        "aktion": {
            "naechste_schritte": [],
            "rueckfrage": "",
            "textentwurf": "",
        },
        "source": row,
    }

    triage, gaps, risks = triage_record(record)
    record["pruefung"]["triage"] = triage
    record["pruefung"]["dokumentationsluecken"] = gaps
    record["pruefung"]["ablehnungsrisiken"] = risks
    if gaps:
        record["aktion"]["naechste_schritte"].append("Dokumentationslücken vor Abrechnung klären")
    if risks:
        record["aktion"]["naechste_schritte"].append("Gebührenrechtliche Quelle und Ausschlüsse prüfen")
    return record


def read_csv(path: Path) -> list[dict[str, Any]]:
    with path.open("r", encoding="utf-8-sig", newline="") as handle:
        sample = handle.read(4096)
        handle.seek(0)
        dialect = csv.Sniffer().sniff(sample, delimiters=",;\t")
        return list(csv.DictReader(handle, dialect=dialect))


def read_json(path: Path) -> list[dict[str, Any]]:
    with path.open("r", encoding="utf-8-sig") as handle:
        payload = json.load(handle)
    if isinstance(payload, list):
        return payload
    if isinstance(payload, dict) and isinstance(payload.get("records"), list):
        return payload["records"]
    if isinstance(payload, dict):
        return [payload]
    raise ValueError("JSON input must be an object, an array, or contain a records array")


def parse_gdt_line(line: str) -> tuple[str, str] | None:
    line = line.rstrip("\r\n")
    if len(line) < 7:
        return None
    field_id = line[3:7]
    value = line[7:].strip()
    return field_id, value


def read_gdt(path: Path) -> list[dict[str, Any]]:
    row: dict[str, Any] = {}
    notes: list[str] = []
    with path.open("r", encoding="cp1252", errors="replace") as handle:
        for line in handle:
            parsed = parse_gdt_line(line)
            if not parsed:
                continue
            field_id, value = parsed
            key = GDT_FIELDS.get(field_id)
            if not key:
                continue
            if key == "notes":
                notes.append(value)
            else:
                row[key] = value
    if notes:
        row["notes"] = "\n".join(notes)
    return [row] if row else []


def read_input(path: Path, input_format: str) -> list[dict[str, Any]]:
    suffix = path.suffix.lower()
    fmt = input_format.lower()
    if fmt == "auto":
        if suffix in [".csv", ".tsv"]:
            fmt = "csv"
        elif suffix == ".json":
            fmt = "json"
        elif suffix in [".gdt", ".bdt"]:
            fmt = "gdt"
        else:
            raise ValueError(f"Cannot detect input format for {path}")

    if fmt == "csv":
        return read_csv(path)
    if fmt == "json":
        return read_json(path)
    if fmt in ["gdt", "bdt"]:
        return read_gdt(path)
    raise ValueError(f"Unsupported input format: {input_format}")


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description="Normalize ifanext/PVS exports for AI billing workflows.")
    parser.add_argument("input", type=Path, help="Input file: CSV, JSON, GDT, or BDT-like export")
    parser.add_argument("-o", "--output", type=Path, help="Output JSON file. Defaults to stdout.")
    parser.add_argument("-f", "--format", default="auto", choices=["auto", "csv", "json", "gdt", "bdt"])
    parser.add_argument("-c", "--config", type=Path, help="Optional JSON mapping configuration")
    parser.add_argument("--pretty", action="store_true", help="Pretty-print JSON output")
    args = parser.parse_args(argv)

    config = load_config(args.config)
    rows = read_input(args.input, args.format)
    records = [normalize_row(row, config) for row in rows]
    output = {
        "adapter": "ifanext-file-adapter",
        "record_count": len(records),
        "records": records,
    }
    text = json.dumps(output, ensure_ascii=False, indent=2 if args.pretty else None)

    if args.output:
        args.output.write_text(text + "\n", encoding="utf-8")
    else:
        print(text)
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))

# ifanext Adapter

Kleiner Datei-Adapter für ifanext-/PVS-nahe Exporte. Er normalisiert CSV, JSON und einfache BDT/GDT-Dateien in ein stabiles JSON-Schema für KI-gestützte augenärztliche Abrechnungsprüfung.

## Warum Datei-Adapter?

Öffentlich ist keine belastbare ifanext-API-Spezifikation auffindbar. Der Adapter ist deshalb als sichere Integrationsschicht für Exporte gebaut. Sobald ein echter ifanext-Export oder eine Hersteller-Schnittstellendoku vorliegt, muss nur `config/mapping.example.json` angepasst werden.

## Nutzung

```powershell
python .\ifanext_adapter.py .\examples\sample-export.csv --pretty
```

Mit Mapping und Ausgabe:

```powershell
python .\ifanext_adapter.py .\examples\sample-export.csv `
  --config .\config\mapping.example.json `
  --output .\normalized-billing.json `
  --pretty
```

BDT/GDT-ähnliche Dateien:

```powershell
python .\ifanext_adapter.py .\export.gdt --format gdt --pretty
```

## Output

Der Output orientiert sich an der `augenarzt-abrechnung`-Skill:

- `patient_context`: Fall, Patient, Versicherung, Datum, Behandler
- `medizin`: Diagnosen, Leistungen, Auge, Indikation, Befunde
- `abrechnung`: Bereich, Ziffer-Kandidaten, Analog-Hinweis
- `pruefung`: Triage, Dokumentationslücken, Ablehnungsrisiken
- `aktion`: nächste Prüfschritte

## Triage

- `B`: grundsätzlich plausibel, aber fachlich noch zu prüfen
- `C`: Dokumentations- oder Gebührenprüfung nötig
- `D`: hohes Risiko durch mehrere Lücken oder erkennbare Abrechnungsrisiken

## Wichtige Grenzen

Der Adapter ersetzt keine GOÄ-/EBM-Prüfung. Er erkennt Datenlücken und strukturiert Fälle für Abrechnung, KI-Prüfung, Power BI oder QM. Konkrete Ziffern, Ausschlüsse und regionale KV-Vorgaben müssen anhand aktueller Primärquellen geprüft werden.

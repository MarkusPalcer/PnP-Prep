# pnpprep – Index

← [Index](../index.md)

`pnpprep` ist die bestehende, fertige LaTeX-Klasse im Projekt.
pnpcards ist eine separate neue Klasse und hängt nicht von pnpprep ab.

## Dateien

| Datei | Zweck |
|---|---|
| `pnpprep.cls` | Hauptklasse |
| `pnp-blueprint.sty` | Blueprint-System (Blueprints = typisierte Datensätze) |
| `pnp-decision.sty` | Entscheidungsbäume |
| `pnp-panel.sty` | Panel-Layout |
| `pnp-speech.sty` | Sprechblasen |
| `pnp-music.sty` | Musiknotizen |
| `pnp-todo.sty` | ToDo-Marker |
| `pnp-gm.sty` | Spielleiter-Notizen |
| `pnp-structuredbox.sty` | Strukturierte Boxen |
| `pnp-dsa.sty` | DSA-spezifische Elemente |

## Blueprint-System

Das Blueprint-System (`pnp-blueprint.sty`) ist das komplexeste Paket.
Es ermöglicht typisierte, wiederverwendbare Datensätze in LaTeX.
Tests dafür: `test/unit/pnpprep/pnp-blueprint/` und `test/integration/pnpprep/blueprint-panel/`

## Architektur-Prinzip (aus `doc/implementation/`)

Alle pnpprep-Pakete folgen einem **Collect → Validate → Render**-Muster:
1. Kind-Environments sammeln Daten in internen Sequenzen/Token-Listen
2. Validierung prüft Kardinalitäten und Strukturregeln (hart, kein stilles Fallback)
3. Rendering ist ein deterministischer Post-Parse-Pass

Gemeinsame Hilfsfunktionen in `pnp-structuredbox.sty`:
- `\pnp_struct_require_exactly_one:nnnn`
- `\pnp_struct_require_at_least_one:nnn`
- `\pnp_struct_render_thin_separator:`

Implementierungssprache: `expl3` + `xparse`

**Relevanz für pnpcards:** pnpcards ist eine eigene Klasse (nicht Paket) und nutzt diese Infrastruktur nicht direkt — aber das Muster (sammeln, validieren, ausgeben) gilt auch dort.

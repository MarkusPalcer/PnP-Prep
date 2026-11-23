# PnP-Prep – Knowledge Base

Meine Wissensdatenbank für das Projekt. Wurzel des Indexbaums.

## Inhaltsverzeichnis

| Bereich | Datei | Inhalt |
|---|---|---|
| Projekt-Überblick | [project.md](project.md) | Ziel, Struktur, Tools |
| pnpcards | [pnpcards/index.md](pnpcards/index.md) | Klasse, Design, Tickets |
| pnpprep | [pnpprep/index.md](pnpprep/index.md) | Bestehende Klasse und Pakete |
| Development practices | [semantic-anchors.md](semantic-anchors.md) | TDD and Red-Green-Refactor |
| Testing | [testing.md](testing.md) | Framework overview and repository testing practices |
| Offene Fragen | [open-questions.md](open-questions.md) | Unsicherheiten und TODOs |

## Schnellreferenz

- Repo-Root: `/workspaces/PnP-Prep`
- Klasse in Entwicklung: `tex/latex/pnpcards/pnpcards.cls`
- Tests: `test/unit/pnpprep/pnpcards/`
- Build-Tool: Rake (`rake test`, `rake doc`)
- LaTeX-Compiler: `pdflatex -interaction=nonstopmode -halt-on-error`

## Konfiguration

GitHub Copilot verwendet [`.github/copilot-instructions.md`](../.github/copilot-instructions.md),
das auf diesen Index verweist und die Regeln zur Wissensbasis-Pflege enthält.
Junie CLI liest die Projektanweisungen aus [`AGENTS.md`](../AGENTS.md). Diese Datei
verlangt den Einstieg über diesen Index und verweist für Entwicklungs- und
Testaufgaben auf die TDD-Anker. Eine vorhandene `.junie/AGENTS.md` hat laut
Junie-Dokumentation Vorrang vor der Root-Anweisung.
Projektanweisungen verbessern die Auffindbarkeit und Verbindlichkeit, können
die tatsächliche Befolgung durch einen KI-Agenten aber nicht technisch garantieren.
Siehe [../tex/latex/pnpcards/Planung.md](../tex/latex/pnpcards/Planung.md) für die Originalplanung.

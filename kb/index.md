# PnP-Prep – Knowledge Base

Meine Wissensdatenbank für das Projekt. Wurzel des Indexbaums.

## Inhaltsverzeichnis

| Bereich | Datei | Inhalt |
|---|---|---|
| Projekt-Überblick | [project.md](project.md) | Ziel, Struktur, Tools |
| pnpcards | [pnpcards/index.md](pnpcards/index.md) | Klasse, Design, Tickets |
| pnpprep | [pnpprep/index.md](pnpprep/index.md) | Bestehende Klasse und Pakete |
| Testing | [testing.md](testing.md) | Framework overview and repository testing practices |
| Offene Fragen | [open-questions.md](open-questions.md) | Unsicherheiten und TODOs |

## Schnellreferenz

- Repo-Root: `/workspaces/PnP-Prep`
- Klasse in Entwicklung: `tex/latex/pnpcards/pnpcards.cls`
- Tests: `test/unit/pnpprep/pnpcards/`
- Build-Tool: Rake (`rake test`, `rake doc`)
- LaTeX-Compiler: `pdflatex -interaction=nonstopmode -halt-on-error`

## Konfiguration

Diese Datei ist in `.github/copilot-instructions.md` als Kontextquelle für GitHub Copilot referenziert.
Siehe [../tex/latex/pnpcards/Planung.md](../tex/latex/pnpcards/Planung.md) für die Originalplanung.

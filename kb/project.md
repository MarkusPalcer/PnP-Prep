# Projekt-Überblick

← [Index](index.md)

## Ziel

PnP-Prep ist eine LaTeX-Toolbox für Pen-&-Paper-Spielleiter.
Aktuell in Entwicklung: `pnpcards.cls` – eine Klasse für Karteikarten im A6-Querformat.

## Repo-Struktur

```
PnP-Prep/
├── tex/latex/
│   ├── pnpprep/          # bestehende Klasse + Pakete (fertig)
│   └── pnpcards/         # Karteikarten-Klasse (in Entwicklung)
│       ├── pnpcards.cls
│       ├── Planung.md
│       └── Tickets/      # Tickets 05–11
├── gems/latextesting/    # lokales Ruby-Testframework
├── test/
│   ├── unit/pnpprep/pnpcards/   # Unit-Tests für pnpcards
│   └── integration/pnpprep/     # Integrationstests für pnpprep
├── doc/                  # LaTeX-Dokumentation
├── out/                  # Build-Ausgaben (ignorieren)
├── rakelib/              # Rake-Tasks
└── Rakefile
```

## Build-System

- **Rake**: `rake test` führt alle Tests aus, `rake doc` baut die Doku
- `gems/latextesting`: Framework für die Testdefinitionen und LaTeX-Fixtures
- `rakelib/test.rake`: bindet das Test-Framework für Rake ein
- Testausgaben landen in `out/test/`
- Compiler: `pdflatex -interaction=nonstopmode -halt-on-error`

## Devcontainer

- `.devcontainer/Dockerfile` builds on TeX Live and installs Ruby, Bundler,
  and native build tools.
- Check out the LatexTesting repository under `gems/latextesting/` before
  starting the container; the root `Gemfile` discovers Gemfiles in `gems/*/`.
- In VS Code, use **Dev Containers: Reopen in Container**. The configured
  `postCreateCommand` runs `sudo bundle install` from the root Gemfile.
- The `Gemfile` includes `ruby-lsp` as a development dependency so the VS Code
  Ruby LSP extension can start its server from the project bundle.
- The Dockerfile gives the `texlive` user write access to RubyGems' global
  home, allowing it to install gems and write to the global gem cache.
- Konfiguration in `.devcontainer/`
- KiroCrew wird beim Start automatisch via `start-kirocrew` gestartet
- Die Host-Konfiguration von GitHub Copilot CLI (`~/.copilot`) wird nach `/home/texlive/.copilot` eingebunden, damit Copilot im Devcontainer die Host-Einstellungen laden und Änderungen persistent speichern kann.

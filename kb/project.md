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
- `rakelib/test.rake`: scannt `test/` nach `*tests.rb`-Dateien, kompiliert `.tex`-Fixtures
- Testausgaben landen in `out/test/`
- Compiler: `pdflatex -interaction=nonstopmode -halt-on-error`

## Devcontainer

- `.devcontainer/Dockerfile` installs the Ruby dependencies from the repository
  `Gemfile` with `bundle install`.
- The `Gemfile` includes `ruby-lsp` as a development dependency so the VS Code
  Ruby LSP extension can start its server from the project bundle.
- The Docker image transfers ownership of RubyGems' global home to `texlive`
  after installing the bundle, allowing that user to install gems and write to
  the global gem cache.
- Konfiguration in `.devcontainer/`
- KiroCrew wird beim Start automatisch via `start-kirocrew` gestartet
- Die Host-Konfiguration von GitHub Copilot CLI (`~/.copilot`) wird nach `/home/texlive/.copilot` eingebunden, damit Copilot im Devcontainer die Host-Einstellungen laden und Änderungen persistent speichern kann.

# Projekt-Überblick

← [Index](index.md)

## Ziel

PnP-Prep ist eine LaTeX-Toolbox für Pen-&-Paper-Spielleiter.
Aktuell in Entwicklung: `pnpcards.cls` – eine Klasse für Karteikarten im A6-Querformat.

## Repo-Struktur

```plaintext
PnP-Prep/
├── tex/latex/
│   ├── pnpprep/          # bestehende Klasse + Pakete (fertig)
│   └── pnpcards/         # Karteikarten-Klasse (in Entwicklung)
│       ├── pnpcards.cls
│       ├── Planung.md
│       └── Tickets/      # Tickets 05–11
├── gems/latextesting/    # Git-Submodul mit Ruby-Testframework
├── test/
│   ├── unit/pnpprep/pnpcards/   # Unit-Tests für pnpcards
│   └── integration/pnpprep/     # Integrationstests für pnpprep
├── doc/                  # LaTeX-Dokumentation
├── out/                  # Build-Ausgaben (ignorieren)
├── rakelib/              # Rake-Tasks
└── Rakefile
```

## Build-System

- **Rake**: `rake test` führt alle Tests aus; `rake test:<fixture>` und
  `rake test:<fixture>:<test>` führen einzelne Fixture- bzw. Faktentests aus;
  `rake doc` baut die Doku.
- `gems/latextesting`: Framework für Fixture- und Testdefinitionen sowie
  LaTeX-Fixtures.
- Definition-Dateien sind Loader; Fixtures benennen je eine `.tex`-Datei und
  werden einmal kompiliert. Benannte Tests prüfen einzelne Fakten unabhängig.
- `Rakefile`: lädt LatexTesting und erzeugt Tasks für Fixtures und einzelne
  Tests.
- Testausgaben landen in `out/test/`
- Compiler: `pdflatex -interaction=nonstopmode -halt-on-error`

## Devcontainer

- `.devcontainer/Dockerfile` builds on TeX Live and installs Ruby, Bundler,
  GitHub CLI (`gh`), and native build tools.
- Initialize the LatexTesting submodule before starting the container with
  `git submodule update --init --recursive`; the root `Gemfile` discovers
  Gemfiles in `gems/*/`.
- In VS Code, use **Dev Containers: Reopen in Container**. The configured
  `postCreateCommand` runs `sudo bundle install` from the root Gemfile.
- The `Gemfile` includes `ruby-lsp` as a development dependency so the VS Code
  Ruby LSP extension can start its server from the project bundle.
- The Dockerfile gives the `texlive` user write access to RubyGems' global
  home, allowing it to install gems and write to the global gem cache.
- Konfiguration in `.devcontainer/`
- KiroCrew wird beim Start automatisch via `start-kirocrew` gestartet
- Die Host-Konfiguration von GitHub Copilot CLI (`~/.copilot`) wird nach `/home/texlive/.copilot` eingebunden, damit Copilot im Devcontainer die Host-Einstellungen laden und Änderungen persistent speichern kann.

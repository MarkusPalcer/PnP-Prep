# Ticket 12: Druckreihenfolge für A6-Duplex (und optional A5-Duplex)

## Ziel

Ein optionales Build-Skript erzeugt aus einem normalen `pnpcards`-PDF ein zweites PDF in der richtigen Reihenfolge für den Duplexdruck.

## Hintergrund

Das normale `pnpcards`-PDF hat Karten in logischer Reihenfolge: K1V, K1R, K2V, K2R, …

### A6-Querformat (4 Karten pro A4-Bogen, „Flip on short edge")

```
Eingabe (logisch):  K1V K1R K2V K2R K3V K3R K4V K4R
Ausgabe (Druck):    K1V K2V K3V K4V K2R K1R K4R K3R
```

### A5-Hochformat (4 Karten pro A4-Bogen, „Flip on long edge")

```
Eingabe (logisch):  K1V K1R K2V K2R K3V K3R K4V K4R
Ausgabe (Druck):    K1V K2V K4V K3V K3R K4R K2R K1R
```

Gruppen à 4 Seiten; Reihenfolge innerhalb jeder Gruppe: 1, 2, 4, 3.

**Hinweis:** Die A5-Option (Klassenoption oder eigene Klasse) ist eine spätere Erweiterung. Ticket 12 implementiert zunächst nur A6. A5-Unterstützung kommt als eigenes Ticket oder als Erweiterung von Ticket 12.

## Beobachtbares Verhalten

- `print_cards.sh input.pdf` erzeugt `input_print.pdf` im selben Verzeichnis.
- `print_cards.ps1 input.pdf` tut dasselbe auf Windows.
- Das erzeugte PDF hat dieselben Seiteninhalte in der Druckreihenfolge.
- Das Original-PDF wird nicht verändert.
- Die Seitenzahl des Eingabe-PDFs muss ein Vielfaches von 8 sein; sonst Fehlermeldung.
- Beide Skripte benötigen nur LaTeX (`pdflatex` oder `latexmk`) als externe Abhängigkeit.

## Implementierung

### Kern-Mechanismus

Die Skripte generieren ein temporäres `.tex`-Dokument:

```latex
\documentclass{article}
\usepackage{pdfpages}
\begin{document}
\includepdf[pages={1,3,5,7,4,2,8,6, 9,11,13,15,12,10,16,14, ...}]{input.pdf}
\end{document}
```

Die Seitenindizes werden vom Skript anhand der Seitenanzahl des Eingabe-PDFs berechnet.

### Dateien

- `tex/latex/pnpcards/print_cards.sh` — Shell-Skript (Linux/macOS)
- `tex/latex/pnpcards/print_cards.ps1` — PowerShell-Skript (Windows)
- `rakelib/print_cards.rake` — optionale Rake-Integration für dieses Repo

### Rake-Integration

`print_cards.rake` stellt eine Hilfsmethode bereit:

```ruby
# In einem Rakefile:
require_relative 'rakelib/print_cards'
print_cards_task output: 'out/cards_print.pdf', input: 'out/cards.pdf'
```

## Nicht Bestandteil

- Unterstützung für 4-Seiten-Karten (andere Umordnungslogik, eigenes Ticket).
- Automatische Ausführung — das Skript ist immer opt-in.

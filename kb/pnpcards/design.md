# pnpcards – Design & Layout

← [pnpcards Index](index.md)

## Seitenmaße

| Größe | Wert | LaTeX-Variable |
|---|---|---|
| Seitenformat | A6, Querformat | `geometry`: `a6paper,landscape` |
| Rand | max. 5 mm | `margin=5mm` |
| Titelbereich | 15 mm | `\pnpcards@titleheight` |
| Titelbreite | 138 mm ohne bzw. 121 mm mit Referenz | `\pnpcards@contentwidth`, `\pnpcards@titlewithreferencewidth` |
| Referenzbereich | 15 × 15 mm oben rechts innerhalb des Randes | `\pnpcards@referencewidth` |
| Abstand Titel→Referenz | 2 mm, nur bei vorhandener Referenz | `\pnpcards@frontgap` |
| Abstand Titel→Inhalt | 2 mm | `\pnpcards@frontgap` |
| Vorderseite Body-Höhe | `\textheight - 15mm - 2mm` | `\pnpcards@frontbodyheight` |
| Rückseite Body-Höhe | `\textheight` | `\pnpcards@backbodyheight` |

## Seitenstruktur

**Vorderseite (Seite 1 jeder Karte):**
```
┌─────────────────────────────────────┐
│  Titel (bold)         [Referenz]    │  ← 15 mm
├─────────────────────────────────────┤  ← 2 mm Abstand
│                                     │
│           Karteninhalt              │  ← Rest der Höhe
│                                     │
└─────────────────────────────────────┘
```

**Rückseite (Seite 2):**
```
┌─────────────────────────────────────┐
│                                     │
│      Überlaufinhalt / leer          │  ← volle Höhe
│                                     │
└─────────────────────────────────────┘
```

Der Referenzbereich erscheint nur für eine nicht leere Referenz auf der eigenen Vorderseite und hat im Debug-Modus einen eigenen Rahmen. Die Referenz wird mit 9 pt und 11 pt Zeilenabstand auf höchstens zwei Zeilen gesetzt; explizites `\linebreak` und automatischer Umbruch sind möglich. Nicht passende Referenzen werden abgewiesen. Titel werden vorläufig einzeilig und unverkleinert gesetzt und bei Überlauf abgewiesen; automatische Anpassung ist in Ticket 11 offen.

Der Body des `card`-Environments wird beim Einlesen direkt in eine offene `\vbox` gesetzt und erst nach vollständigem Einlesen geteilt und ausgegeben. Text, Absätze, Formatierung, Listen, `tabular` und direkt eingebundene Grafiken sind automatisiert geprüft. Inline-`\verb` ist im Environment getestet; die Kurzform `\Card` tokenisiert ihr Inhaltsargument vorher und verspricht dafür kein rohes `\verb`. `fancyvrb`-gespeicherter Verbatim-Inhalt ist als Workaround geprüft. Floats, Fußnoten und Randnotizen erhalten keine Unterstützungsgarantie.

## Entscheidung: Implementierungsvariante

Drei Varianten wurden verglichen (→ `Planung.md`):

| Variante | Beschreibung | Gewählt? |
|---|---|---|
| 1 | Inhalt sammeln, automatisch aufteilen | ✓ **Ja** |
| 2 | Vorder-/Rückseite explizit auszeichnen | Nein |
| 3 | Seitenweise setzen mit `\newpage` | Nein |

**Begründung:** Nur Variante 1 ermöglicht automatischen Überlauf und entspricht der Wunschsyntax.

## Spätere Erweiterungen (nicht jetzt)

- A5-Hochformat-Karten als Option (`pnpcardsA5` oder Klassenoption)
- PDF-Seitenumordnung für A5-Duplexdruck

### Entschiedenes Design: A5-Option statt `doublecard`

**Entscheidung (2026-10-21):** Keine `doublecard`-Umgebung. Stattdessen eine Geometrie-Option, die A6-Querformat auf A5-Hochformat umschaltet.

**Begründung:** A5-Hochformat hat dieselbe Breite wie A6-Querformat (148 mm). Die gesamte Klassen-Logik (Titelbereich, `\vsplit`, Fehlerbehandlung) bleibt identisch — nur `geometry` ändert sich. Kein neuer Code.

**Syntax (geplant):**
```latex
\documentclass[a5portrait]{pnpcards}
% oder: eigene Klasse pnpcardsA5.cls die pnpcards lädt
```

**Druckumordnung für A5-Duplex** (4 A5-Seiten pro A4-Bogen, „Flip on long edge"):
```
Eingabe (logisch):  K1V K1R K2V K2R K3V K3R K4V K4R
Ausgabe (Druck):    K1V K2V K4V K3V K3R K4R K2R K1R
```
Gruppen à 4 Seiten: Reihenfolge innerhalb jeder Gruppe ist 1, 2, 4, 3.

## Druck-Workflow (Ticket 12)

Das fertige PDF hat Karten in logischer Reihenfolge: K1V, K1R, K2V, K2R, …

Für Duplexdruck (4 A6-Karten pro A4-Bogen, „Flip on short edge") ist eine Umordnung nötig:

```
Eingabe:  K1V K1R K2V K2R K3V K3R K4V K4R
Ausgabe:  K1V K2V K3V K4V K2R K1R K4R K3R
```

**Implementierung:** Shell-Skript + PowerShell-Skript generieren ein temporäres `pdfpages`-Dokument und kompilieren es.
- Einzige Abhängigkeit: LaTeX (ohnehin vorhanden)
- Opt-in — Standardausgabe bleibt in logischer Reihenfolge
- Rake-Integration als `rakelib/print_cards.rake`

Dateien: `tex/latex/pnpcards/print_cards.sh`, `print_cards.ps1`
(Vorläufer: `print_cards.rb` mit `hexapdf` — ersetzt durch Shell/pdfpages-Ansatz)

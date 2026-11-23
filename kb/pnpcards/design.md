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

Eine Karte ohne Überlauf erzeugt genau zwei PDF-Seiten im A6-Querformat. Die Rückseite ist vollständig unbedruckt — auch vor der nächsten Karte und im Debug-Modus; weder Text noch Grafiken oder Rahmen dürfen darauf erscheinen.

Der Referenzbereich erscheint nur für eine nicht leere Referenz auf der eigenen Vorderseite und hat im Debug-Modus einen eigenen Rahmen. Fehlende, leere, reine Leerraum- und `\relax`-Referenzen gelten als nicht gesetzt. Die Referenz wird unskaliert mit 9 pt und 11 pt Zeilenabstand auf höchstens zwei Zeilen gesetzt; `WdZ. 567` passt einzeilig und `WdZ. 567 \linebreak Wdz. 567` zweizeilig. Expliziter und automatischer Umbruch sind möglich; nicht passende oder zu lange Referenzen werden abgewiesen.

Titel bleiben einzeilig und werden pro Karte proportional bis zur verfügbaren Breite oder Höhe vergrößert oder verkleinert. Die feste Basisgröße beträgt 10 pt, die effektive Mindestgröße 7 pt; eine Obergrenze von 10 pt gibt es nicht. Ohne Referenz sind 138 mm, mit Referenz 121 mm verfügbar. Ein Titel, der selbst bei 7 pt nicht passt, verursacht einen gezielten Fehler. Ein leerer Titel bleibt leer; Referenz, Rahmen und Body werden nicht mitskaliert.

Der Body des `card`-Environments wird beim Einlesen direkt in eine offene `\vbox` gesetzt und erst nach vollständigem Einlesen geteilt und ausgegeben. Text, Absätze, Formatierung, Listen, `tabular` und direkt eingebundene Grafiken sind automatisiert geprüft. Inline-`\verb` ist im Environment getestet; die Kurzform `\Card` tokenisiert ihr Inhaltsargument vorher und verspricht dafür kein rohes `\verb`. `fancyvrb`-gespeicherter Verbatim-Inhalt ist als Workaround geprüft. Floats, Fußnoten und Randnotizen erhalten keine Unterstützungsgarantie.

## Spätere Erweiterungen (nicht jetzt)

- GitHub-Ticket #9
  - Automatische Imposition und Ausgabe druckfertiger A4-Seiten (2 verschiedene Druckmodi)
  - Manuelle A5-Karten
  - Automatisches Umschalten auf A5-Karten, wenn Text zu lang

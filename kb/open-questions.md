# Offene Fragen & TODOs

← [Index](index.md)

## ~~Ghostscript aus dem Geometrie-Test entfernen~~ → HexaPDF-Vektorprüfung

Der `A6 Geometry`-Test prüft die farbigen Debug-Rahmen jetzt ohne Rasterizer:
`HexaPDF::Content::Parser` liest die PDF-Content-Streams, ein eigener
`HexaPDF::Content::Processor` erfasst Pfade, Farbe, Transformation und
Strichbreite. Die Testassertions vergleichen einzelne Ränder, Abstände und
Abmessungen in Millimetern.

Der Prüfer unterstützt absichtlich die vom Fixture erzeugten achsenparallelen
Linienstrokes mit Butt-Caps und nicht skalierten bzw. rotierten Transformationen.
Nicht unterstützte Pfadformen oder fehlende Farbstrokes schlagen mit einer
klaren Fehlermeldung fehl. PDF-Content-Streams enthalten weiterhin keine
semantischen Objekte namens „Rahmen“.

## Offene technische Fragen

### ~~pnpcards – Expliziter Seitenwechsel (Ticket 08)~~ → Geklärt

- `\splitbotmark == "EXPLICIT-CARD-BREAK"` nach dem ersten `\vsplit` ist zuverlässig für den Einzelfall (ein `\newpage`).
- `\vsplit` schneidet bereits an `\penalty-10000` — der Break wird schon richtig gesetzt.
- Mehrfach-`\newpage` → `\PackageError` in Ticket 09, kein Problem hier.
- Offen war nur: `\pnpcards@breakstatus` für Logik nutzen statt nur Debug-Text drucken → wird in Ticket 08 umgesetzt.

### ~~pnpcards – LaTeX-Konstrukte im gesammelten Inhalt~~ → Geklärt (Ticket 05)

Der `environ`-Paket-Body wird als Token-Liste gesammelt, dann in eine `\vbox` gesteckt. Daraus folgen diese Einschränkungen:

| Konstrukt | Status | Hinweis |
|---|---|---|
| Text, Absätze, `\textbf`, Listen | ✓ | Kein Problem |
| `tabular`, `\includegraphics` | ✓ | Als Box direkt gesetzt |
| `\verb\|...\|` (inline) | ✓ | Funktioniert |
| `\begin{figure}` / `\begin{table}` | ✗ | Floats werden ignoriert |
| `\begin{verbatim}` | ✗ | Kategorie-Code-Problem beim Tokenisieren |
| `\footnote`, `\marginpar` | ✗ | Globale Seiteneffekte, falsche Position |

Alternative für mehrzeiligen Verbatim-Inhalt: `fancyvrb`'s `\SaveVerbatim`/`\UseVerbatim`.

Ticket 05 soll diese Tabelle als Dokumentation enthalten.

### ~~pnpcards – Vier-Seiten-Karten (Ticket 10)~~ → Entschieden

**Entscheidung:** Keine `doublecard`-Umgebung. Stattdessen A5-Hochformat als Geometrie-Option.

- A5-Hoch hat dieselbe Breite wie A6-Quer (148 mm) → gesamte Klassen-Logik bleibt identisch.
- Spätere Erweiterung: Klassenoption oder eigene Klasse `pnpcardsA5`.
- Druckumordnung für A5: Gruppen à 4 Seiten in Reihenfolge 1, 2, 4, 3 (→ Ticket 12 Erweiterung).
- Ticket 10 selbst: nur Integrationsfixture + Seitenlimit-Konfigurierbarkeit, kein A5-Code.

### ~~pnpcards – Titel-Schriftgröße (Ticket 11)~~ → Geklärt

**Mechanismus:** `\scalebox` aus `graphicx`. Titel in `\hbox` messen, Breite gegen `\pnpcards@maxtitlewidth` prüfen, bei Überlauf gleichmäßig skalieren (keine Verzerrung).

```
Skalierungsfaktor f = maxtitlewidth / \wd0
f < 1  → \scalebox{f}{\textbf{Titel}}
f ≥ 1  → \textbf{Titel} in Normalschrift
f < 0.7 → \PackageError (Titel zu lang)
```

**Mehrzeilige Titel:** Nicht unterstützt. Titel ist immer einzeilig. Explizites `\\` im Titel führt zu undefiniertem Verhalten. Ticket 11 soll das dokumentieren.

**Schriftgrößen:**
- Obergrenze: `\normalsize` (10pt)
- Untergrenze: 7pt (entspricht Skalierungsfaktor 0.7)
- Darunter: `\PackageError{pnpcards}{Title does not fit}`

**Referenz-Kollision:** `\pnpcards@maxtitlewidth` = `\textwidth - Referenzbreite - Mindestabstand`. Bei fehlendem Referenztext = `\textwidth`.

## KB-Zugriff durch Kiro

Die KB liegt als Markdown-Dateien in `/workspaces/PnP-Prep/kb/`.
- Über das Dashboard (Settings → Knowledge) wurde die KB manuell als Wissensquelle hinzugefügt und ist indexiert.
- `local_knowledge_search` steht damit zur Verfügung.
- Zusätzlich ist die Steering-Datei `.kiro/steering/pnpcards-kb.md` aktiv (Kurzübersicht immer im Kontext).

## Wissenslücken der KB

- Ticket-Nummern 01–04 fehlen (existieren nicht im Tickets-Ordner; vermutlich frühere Planungstickets). → Klärung ausstehend (siehe unten).
- `doc/implementation/simplify.md` → **gelesen, Wissen eingearbeitet** in `kb/pnpprep/index.md`
- `doc/implementation/decision.md` → **gelesen, Wissen eingearbeitet** in `kb/pnpprep/index.md`
- `rakelib/basic.rake` → **gelesen, Wissen eingearbeitet** in `kb/testing.md` (Compiler ist `latexmk`, nicht `pdflatex` direkt)

## ~~Tickets 01–04~~ → Abgeschlossen und gelöscht

## Chat-Kontext

- Erstellt am 2026-10-21 in KiroCrew Dashboard-Session.
- Nutzer arbeitet aktiv an `pnpcards.cls`, nächster Schritt: Tickets 05–11 implementieren.
- KB soll selbstständig von mir (Kiro) gepflegt werden.

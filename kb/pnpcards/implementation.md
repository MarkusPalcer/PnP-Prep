# pnpcards – Implementierungsstand

← [pnpcards Index](index.md)

## Datei: `tex/latex/pnpcards/pnpcards.cls`

### Öffentliche API

| Befehl / Umgebung | Beschreibung |
|---|---|
| `\begin{card}[Referenz]{Titel} ... \end{card}` | Öffentlich – setzt den Body beim Einlesen direkt in eine Box und rendert nach `\end{card}`; Referenz optional |
| `\Card[Referenz]{Titel}{Inhalt}` | Öffentliche Kurzform, die an die `card`-Umgebung delegiert; das Inhaltsargument wird vorher tokenisiert |
| `\EnableCardDebugFrames` | Zeigt farbige Rahmen: Titel rot, Referenz magenta, Vorderseiteninhalt blau, Rückseiteninhalt grün |

### Interne Helfer

| Befehl | Beschreibung |
|---|---|
| `\pnpcards@Area{w}{h}{align}{rahmenfarbe}{inhalt}` | Setzt einen fixen Box-Bereich (mit/ohne farbigen Debug-Rahmen) |
| `\pnpcards@PrintFront{titel}{frontbox}` | Gibt Vorderseite aus |
| `\pnpcards@PrintBack{backbox}` | Gibt Rückseite aus |
| `\pnpcards@CardExplicitBreak` | Zählt und markiert `\newpage` innerhalb einer Karte |
| `\pnpcards@PageLimitError` | Meldet das Zwei-Seiten-Limit mit Kartenindex und nicht expandiertem Titeltext |
| `\pnpcards@CheckSplitHeight` | Prüft die gesplitteten Inhalte einschließlich schrumpfbarer Abstände auf Überhöhe |
| `\pnpcards@PrepareReference` | Setzt und validiert Referenztext und Zeilenzahl |
| `\pnpcards@PrepareTitle{titel}` | Setzt den Titel einmal fett mit 10 pt und wählt die verfügbare Breite |
| `\pnpcards@ScaleTitleBox` | Skaliert die gesetzte Titelbox gleichmäßig und kontrolliert abschließend ihre Abmessungen |
| `\pnpcards@CheckTitleMinimum` | Prüft die 7-pt-Untergrenze und meldet horizontale oder vertikale Ursachen |

### Interne Boxen

| Box | Zweck |
|---|---|
| `\pnpcards@cardcontent` | Gesamter gesammelter Karteninhalt |
| `\pnpcards@frontcontent` | Per `\vsplit` abgespaltener Vorderseiten-Teil |
| `\pnpcards@backcontent` | Per `\vsplit` abgespaltener Rückseiten-Teil |
| `\pnpcards@referencebox` | Referenzabsatz, maximal zwei Zeilen in 15 × 15 mm |
| `\pnpcards@titlebox` | Einmalig gesetzter und proportional eingepasster Titel |
| `\pnpcards@minimumtitlebox` | Temporäre Kopie für Mindestgrößen- und Skalierungsprüfung |

### Kernmechanismus (`card`-Umgebung)

1. `card` erhält einen dokumentweit fortlaufenden Index ab 1, sichert Titel und Referenz lokal und liest den Body direkt in eine offene `\vbox` (`\pnpcards@cardcontent`); erst nach dem vollständigen Body beginnt die Kartenausgabe. `\Card` delegiert und zählt genau einmal; sein Inhaltsargument wird davor normal tokenisiert.
2. Explizite Umbrüche werden beim Einsammeln gezählt; bereits zwei `\newpage` erzeugen einen Seitenlimitfehler, auch wenn Bereiche leer sind oder der letzte Umbruch am Ende steht.
3. `\vsplit` teilt bei `\pnpcards@frontbodyheight` → `\pnpcards@frontcontent`; `\splitbotmark` erkennt einen expliziten Break (`EXPLICIT-CARD-BREAK`). Die tatsächliche Packbarkeit der Splitbox wird unter Berücksichtigung schrumpfbarer Abstände geprüft.
4. Die Vorderseite wird gedruckt. Bei leerem Rest folgt eine tatsächlich leere Rückseite; sonst wird der Rest bei `\pnpcards@backbodyheight` gesplittet und ausgegeben.
5. Überhöhe oder Rest nach dem Rückseiten-Split sowie ein expliziter Break im Rückseiten-Split nach natürlichem Überlauf erzeugen einen `\PackageError`. Die Meldung nennt den Kartenindex und den nicht zusätzlich ausgeführten Titel als Text. Ein Fehler-PDF ist ungültig; weder sein Inhalt noch sein Vorhandensein sind zugesagt.

### Bekannte Einschränkungen

- Referenzen verwenden 9 pt mit 11 pt Zeilenabstand; mehr als zwei Zeilen oder Überlauf sind Fehler.
- Titelboxen werden einzeilig ausgehend von 10 pt proportional auf Breite und Höhe eingepasst, auch oberhalb von 10 pt. Unter 7 pt folgt ein Fehler; exakt 7 pt sind zulässig. Formatierungen und feste Boxen werden mitskaliert, Titelmakros nur einmal ausgeführt. Eine Nulldimension begrenzt den Faktor nicht.
- Text, Absätze, Formatierung, Listen, Tabellen und direkt eingebundene Grafiken sind automatisiert geprüft. Inline-`\verb` ist im Environment geprüft, nicht allgemein im `\Card`-Inhaltsargument.
- `fancyvrb` mit `\SaveVerbatim`/`\UseVerbatim` ist als Verbatim-Workaround positiv geprüft. Floats, Fußnoten und Randnotizen erhalten keine Unterstützungsgarantie.



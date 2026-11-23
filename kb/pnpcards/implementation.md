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
| `\pnpcards@PrepareTitle{titel}` | Misst den einzeiligen Titel und meldet Überlauf |

### Interne Boxen

| Box | Zweck |
|---|---|
| `\pnpcards@cardcontent` | Gesamter gesammelter Karteninhalt |
| `\pnpcards@frontcontent` | Per `\vsplit` abgespaltener Vorderseiten-Teil |
| `\pnpcards@backcontent` | Per `\vsplit` abgespaltener Rückseiten-Teil |
| `\pnpcards@referencebox` | Referenzabsatz, maximal zwei Zeilen in 15 × 15 mm |
| `\pnpcards@titlebox` | Unverkleinerter, fett gesetzter Titel |

### Kernmechanismus (`card`-Umgebung)

1. `card` erhält einen dokumentweit fortlaufenden Index ab 1, sichert Titel und Referenz lokal und liest den Body direkt in eine offene `\vbox` (`\pnpcards@cardcontent`); erst nach dem vollständigen Body beginnt die Kartenausgabe. `\Card` delegiert und zählt genau einmal; sein Inhaltsargument wird davor normal tokenisiert.
2. Explizite Umbrüche werden beim Einsammeln gezählt; bereits zwei `\newpage` erzeugen einen Seitenlimitfehler, auch wenn Bereiche leer sind oder der letzte Umbruch am Ende steht.
3. `\vsplit` teilt bei `\pnpcards@frontbodyheight` → `\pnpcards@frontcontent`; `\splitbotmark` erkennt einen expliziten Break (`EXPLICIT-CARD-BREAK`). Die tatsächliche Packbarkeit der Splitbox wird unter Berücksichtigung schrumpfbarer Abstände geprüft.
4. Die Vorderseite wird gedruckt. Bei leerem Rest folgt eine tatsächlich leere Rückseite; sonst wird der Rest bei `\pnpcards@backbodyheight` gesplittet und ausgegeben.
5. Überhöhe oder Rest nach dem Rückseiten-Split sowie ein expliziter Break im Rückseiten-Split nach natürlichem Überlauf erzeugen einen `\PackageError`. Die Meldung nennt den Kartenindex und den nicht zusätzlich ausgeführten Titel als Text. Ein Fehler-PDF ist ungültig; weder sein Inhalt noch sein Vorhandensein sind zugesagt.

### Bekannte Einschränkungen

- Referenzen verwenden 9 pt mit 11 pt Zeilenabstand; mehr als zwei Zeilen oder Überlauf sind Fehler.
- Titel werden derzeit nicht automatisch verkleinert: Überlauf verursacht einen Fehler. Die Anpassung auf 10 bis 7 pt bleibt in Ticket 11 offen.
- Text, Absätze, Formatierung, Listen, Tabellen und direkt eingebundene Grafiken sind automatisiert geprüft. Inline-`\verb` ist im Environment geprüft, nicht allgemein im `\Card`-Inhaltsargument.
- `fancyvrb` mit `\SaveVerbatim`/`\UseVerbatim` ist als Verbatim-Workaround positiv geprüft. Floats, Fußnoten und Randnotizen erhalten keine Unterstützungsgarantie.

### Ticket-Status

| Ticket | Thema | Status |
|---|---|---|
| 05 | Karteninhalt sammeln | **Fertig** |
| 06 | Titel, Referenz, leere Rückseite | **Fertig** |
| 07 | Natürlicher Überlauf | **Fertig** |
| 08 | Expliziter Seitenwechsel | **Fertig** |
| 09 | Seitenlimit + Fehlermeldungen | **Fertig** |
| 10 | Integration + Vier-Seiten-Vorbereitung | Offen |
| 11 | Titeltext-Schriftgröße anpassen | Offen |

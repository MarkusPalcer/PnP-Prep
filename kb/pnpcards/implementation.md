# pnpcards – Implementierungsstand

← [pnpcards Index](index.md)

## Datei: `tex/latex/pnpcards/pnpcards.cls`

### Öffentliche API

| Befehl / Umgebung | Beschreibung |
|---|---|
| `\begin{card}[Referenz]{Titel} ... \end{card}` | Öffentlich – sammelt den Inhalt und rendert eine Karte; Referenz optional |
| `\Card[Referenz]{Titel}{Inhalt}` | Öffentliche Kurzform, die an die `card`-Umgebung delegiert; Referenz optional |
| `\EnableCardDebugFrames` | Zeigt farbige Rahmen: Titel rot, Referenz magenta, Vorderseiteninhalt blau, Rückseiteninhalt grün |

### Interne Helfer

| Befehl | Beschreibung |
|---|---|
| `\pnpcards@Area{w}{h}{align}{rahmenfarbe}{inhalt}` | Setzt einen fixen Box-Bereich (mit/ohne farbigen Debug-Rahmen) |
| `\pnpcards@PrintFront{titel}{frontbox}` | Gibt Vorderseite aus |
| `\pnpcards@PrintBack{backbox}` | Gibt Rückseite aus |
| `\pnpcards@CardExplicitBreak` | Marker für `\newpage` innerhalb einer Karte |
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

1. Argumente und Inhalt werden gesammelt, Referenzzustand wird lokal bestimmt; Inhalt wird in `\pnpcards@cardcontent` als `\vbox` gesetzt
2. `\vsplit` teilt bei `\pnpcards@frontbodyheight` → `\pnpcards@frontcontent`
3. `\splitbotmark` prüft ob ein expliziter Break (`EXPLICIT-CARD-BREAK`) vorlag
4. Vorderseite wird gedruckt
5. Rest in Box → leer: leere Rückseite; nicht leer: Rückseite drucken
6. Noch Rest übrig → `\PackageError`: "Card content exceeds two pages"

### Bekannte Einschränkungen

- Referenzen verwenden 9 pt mit 11 pt Zeilenabstand; mehr als zwei Zeilen oder Überlauf sind Fehler.
- Titel werden derzeit nicht automatisch verkleinert: Überlauf verursacht einen Fehler. Die Anpassung auf 10 bis 7 pt bleibt in Ticket 11 offen.

### Ticket-Status

| Ticket | Thema | Status |
|---|---|---|
| 05 | Karteninhalt sammeln | Offen |
| 06 | Titel, Referenz, leere Rückseite | Offen |
| 07 | Natürlicher Überlauf | Offen |
| 08 | Expliziter Seitenwechsel | **Fertig** |
| 09 | Seitenlimit + Fehlermeldungen | Offen |
| 10 | Integration + Vier-Seiten-Vorbereitung | Offen |
| 11 | Titeltext-Schriftgröße anpassen | Offen |

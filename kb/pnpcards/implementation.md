# pnpcards – Implementierungsstand

← [pnpcards Index](index.md)

## Datei: `tex/latex/pnpcards/pnpcards.cls`

### Öffentliche API

| Befehl / Umgebung | Beschreibung |
|---|---|
| `\begin{card}{Titel} ... \end{card}` | Öffentlich – sammelt den Inhalt und rendert eine Karte |
| `\Card{Titel}{Inhalt}` | Öffentliche Kurzform, die an die `card`-Umgebung delegiert |
| `\EnableCardDebugFrames` | Zeigt farbige Rahmen um alle Bereiche: Titel rot, Vorderseiteninhalt blau, Rückseiteninhalt grün |

### Interne Helfer

| Befehl | Beschreibung |
|---|---|
| `\pnpcards@Area{w}{h}{align}{rahmenfarbe}{inhalt}` | Setzt einen fixen Box-Bereich (mit/ohne farbigen Debug-Rahmen) |
| `\pnpcards@PrintFront{titel}{frontbox}{breakstatus}` | Gibt Vorderseite aus |
| `\pnpcards@PrintBack{backbox}` | Gibt Rückseite aus |
| `\pnpcards@CardExplicitBreak` | Marker für `\newpage` innerhalb einer Karte |

### Interne Boxen

| Box | Zweck |
|---|---|
| `\pnpcards@cardcontent` | Gesamter gesammelter Karteninhalt |
| `\pnpcards@frontcontent` | Per `\vsplit` abgespaltener Vorderseiten-Teil |
| `\pnpcards@backcontent` | Per `\vsplit` abgespaltener Rückseiten-Teil |

### Kernmechanismus (`card`-Umgebung)

1. Inhalt wird in `\pnpcards@cardcontent` als `\vbox` gesammelt
2. `\vsplit` teilt bei `\pnpcards@frontbodyheight` → `\pnpcards@frontcontent`
3. `\splitbotmark` prüft ob ein expliziter Break (`EXPLICIT-CARD-BREAK`) vorlag
4. Vorderseite wird gedruckt
5. Rest in Box → leer: leere Rückseite; nicht leer: Rückseite drucken
6. Noch Rest übrig → `\PackageError`: "Card content exceeds two pages"

### Bekannte Einschränkungen

- Referenz wird noch nicht gedruckt (Ticket 06)

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

# pnpcards – Tickets

← [pnpcards Index](index.md)

Die Ticketdateien liegen in `tex/latex/pnpcards/Tickets/`.

## Übersicht

| Nr | Datei | Ziel | Abhängigkeit |
|---|---|---|---|
| 05 | — (abgeschlossen) | `card`-Environment, Inhalt sammeln, Vorderseite rendern | — |
| 06 | `06-titel-referenz-und-leere-rueckseite.md` | Titel- und Referenzbereich, leere Rückseite | 05 (abgeschlossen) |
| 07 | `07-natuerlicher-ueberlauf.md` | Automatischer Überlauf Vorderseite → Rückseite | 06 |
| 08 | `08-expliziter-seitenwechsel.md` | `\newpage` innerhalb einer Karte | 07 |
| 09 | `09-seitenlimit-und-fehlermeldungen.md` | Fehler bei >2 Seiten | 08 |
| 10 | `10-integration-und-erweiterungspunkt.md` | Integrationstest, Erweiterbarkeit für A5-Option sicherstellen | 09 |
| 11 | `11-titeltext-maximal-einpassen.md` | Titel-Schriftgröße automatisch anpassen (offen) | 06 |
| 12 | `12-druckreihenfolge.md` | Shell/PS-Skript für 4×A6-Duplex-Druck | 10 |

**Hinweis:** Die Tickets wurden am 2026-10-21 neu geschrieben. Sie enthalten nur beobachtbares Verhalten — keine Implementierungsvorschläge.

## Ticket-Details

### Ticket 05 – Karteninhalt sammeln (abgeschlossen)
- `card`-Environment mit `[Referenz]` (optional) vor `{Titel}`
- Body direkt in einer offenen `\vbox` sammeln und erst nach vollständigem Einlesen ausgeben
- beide Syntaxformen und die zugesagten Inhaltsarten sind automatisiert geprüft
- Inline-`\verb` ist im Environment geprüft; rohes Verbatim im tokenisierten `\Card`-Argument ist nicht zugesagt
- die alte Aussage, die Referenz werde noch nicht gedruckt, ist überholt; siehe Ticket 06

### Ticket 06 – Titel, Referenz, leere Rückseite (offen)
- Titel in Titelbereich
- Karte ohne Überlauf → 2 PDF-Seiten (Vorderseite + leere Rückseite)
- Fixtures prüfen beide APIs, Referenzzuordnung und -geometrie, aufeinanderfolgende Karten sowie leere Rückseiten
- Optionaler Referenzbereich 15 × 15 mm mit 2 mm Abstand, nur auf der eigenen Vorderseite; ein bis zwei Zeilen mit 9 pt/11 pt und eigenem Debug-Rahmen

### Ticket 07 – Natürlicher Überlauf
- `\vsplit` bei `\pnpcards@frontbodyheight`
- Rest auf Rückseite; kein Rest → leere Rückseite
- Fixture mit kurzer Karte + Überlaufkarte

### Ticket 08 – Expliziter Seitenwechsel
- `\newpage` im Inhalt → Rückseite beginnen, auch wenn Vorderseite noch Platz hat
- Erkennungsmechanismus: `\mark{EXPLICIT-CARD-BREAK}` + `\splitbotmark`
- Leerer Bereich vor/nach `\newpage` darf keine Geistseiten erzeugen

### Ticket 09 – Seitenlimit + Fehlermeldungen
- Inhalt für >2 Seiten → `\PackageError`
- Gilt für natürlichen Überlauf UND explizites `\newpage`
- Negativfixtures (erwarteter Fehler) + positives Grenzfall-Fixture

### Ticket 10 – Integration + Erweiterbarkeit
- Integrationsfixture mit mehreren Karten hintereinander
- Seitenlimit an einer Stelle konfigurierbar halten
- Trennung logische Reihenfolge ↔ physische Druckreihenfolge dokumentieren
- Kein `doublecard`, keine A5-Option und keine Seitenumordnung in diesem Ticket

### Ticket 11 – Titeltext-Schriftgröße
- Offen: kurze Titel → 10 pt (Obergrenze), Mindestgröße 7 pt
- Lange Titel → kleiner skalieren (kein Verzerren!)
- Titel bleiben einzeilig; Gesamthöhe muss in 15 mm passen
- Referenz und Titel dürfen sich nicht überschneiden
- Die derzeitige Fehlermeldung für Überlauf wird durch Einpassen ersetzt; passt der Titel auch bei 7 pt nicht, folgt `\PackageError`

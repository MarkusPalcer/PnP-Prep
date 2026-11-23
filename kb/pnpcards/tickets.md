# pnpcards – Tickets

← [pnpcards Index](index.md)

Die offenen Ticketdateien liegen in `tex/latex/pnpcards/Tickets/`.

## Übersicht

| Nr | Datei | Ziel | Abhängigkeit |
|---|---|---|---|
| 05 | — (abgeschlossen) | `card`-Environment, Inhalt sammeln, Vorderseite rendern | — |
| 06 | — (abgeschlossen) | Titel- und Referenzbereich, leere Rückseite | 05 (abgeschlossen) |
| 07 | — (abgeschlossen) | Automatischer Überlauf Vorderseite → Rückseite | 06 (abgeschlossen) |
| 08 | — (abgeschlossen) | `\newpage` innerhalb einer Karte | 07 (abgeschlossen) |
| 09 | — (abgeschlossen) | Fehler bei >2 Seiten mit Kartenkennung | 08 (abgeschlossen) |
| 10 | `10-integration-und-erweiterungspunkt.md` | Integrationstest, Erweiterbarkeit für A5-Option sicherstellen | 09 (abgeschlossen) |
| 11 | `11-titeltext-maximal-einpassen.md` | Titel-Schriftgröße automatisch anpassen (offen) | 06 (abgeschlossen) |
| 12 | `12-druckreihenfolge.md` | Shell/PS-Skript für 4×A6-Duplex-Druck | 10 |

**Hinweis:** Die Tickets wurden am 2026-10-21 neu geschrieben. Sie enthalten nur beobachtbares Verhalten — keine Implementierungsvorschläge.

## Ticket-Details

### Ticket 05 – Karteninhalt sammeln (abgeschlossen)
- `card`-Environment mit `[Referenz]` (optional) vor `{Titel}`
- Body direkt in einer offenen `\vbox` sammeln und erst nach vollständigem Einlesen ausgeben
- beide Syntaxformen und die zugesagten Inhaltsarten sind automatisiert geprüft
- Inline-`\verb` ist im Environment geprüft; rohes Verbatim im tokenisierten `\Card`-Argument ist nicht zugesagt
- die alte Aussage, die Referenz werde noch nicht gedruckt, ist überholt; aktuelle Syntax und Layoutvorgaben stehen in `syntax.md` und `design.md`

### Ticket 06 – Titel, Referenz, leere Rückseite (abgeschlossen)
- Beide APIs, Kartenisolation und exakt zwei A6-Seiten pro Karte ohne Überlauf sind automatisiert geprüft.
- Die Rückseite bleibt vollständig unbedruckt, auch in aufeinanderfolgenden Karten und mit Debug-Modus.
- Optionaler Referenzbereich 15 × 15 mm innerhalb des 5-mm-Rands, 2 mm Abstand zum 121-mm-Titelbereich, nur auf der eigenen Vorderseite; ohne Referenz ist der Titelbereich 138 mm breit
- Referenzen bleiben unskaliert, verwenden 9 pt/11 pt und dürfen höchstens zwei Zeilen umfassen; Überläufe sind gezielte Fehler. Der Debug-Rahmen ist nur bei vorhandener Referenz sichtbar.
- Titel bleiben einzeilig; Überbreite und Überhöhe werden bis Ticket 11 mit einem Fehler abgewiesen.
- Die geprüften Layout- und Referenzvorgaben sind dauerhaft in `design.md` und `syntax.md` festgehalten; die abgeschlossene Ticketdatei wurde entfernt.

### Ticket 07 – Natürlicher Überlauf (abgeschlossen)
- `\vsplit` bei `\pnpcards@frontbodyheight`
- Rest auf Rückseite; kein Rest → leere Rückseite
- Fixture mit kurzer Karte + Überlaufkarte

### Ticket 08 – Expliziter Seitenwechsel (abgeschlossen)
- `\newpage` im Inhalt → Rückseite beginnen, auch wenn Vorderseite noch Platz hat
- Erkennungsmechanismus: `\mark{EXPLICIT-CARD-BREAK}` + `\splitbotmark`
- Leerer Bereich vor/nach `\newpage` darf keine Geistseiten erzeugen

### Ticket 09 – Seitenlimit + Fehlermeldungen (abgeschlossen)
- Natürlicher, expliziter und gemischter Überlauf über zwei Seiten erzeugen einen `\PackageError` mit Kartenindex und nicht expandiertem Titeltext; auch leere Bereiche und abschließende Umbrüche zählen.
- Ein potenziell erzeugtes Fehler-PDF ist ungültig; sein Inhalt und Vorhandensein werden nicht geprüft.
- Automatisierte Negativfixtures prüfen beide APIs, Debug-Modus, Kartenkennung und unteilbare Inhalte; positive PDF-Prüfungen decken den exakten Grenzfall, einzelne Umbrüche und Kartenfolgen ohne manuelle Abnahme ab.

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

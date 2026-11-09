# pnpcards – Tickets

← [pnpcards Index](index.md)

Alle Tickets liegen in `tex/latex/pnpcards/Tickets/`.

## Übersicht

| Nr | Datei | Ziel | Abhängigkeit |
|---|---|---|---|
| 05 | `05-karteninhalt-sammeln.md` | `card`-Environment, Inhalt sammeln, Vorderseite rendern | — |
| 06 | `06-titel-referenz-und-leere-rueckseite.md` | Titelbereich, Referenz, leere Rückseite | 05 |
| 07 | `07-natuerlicher-ueberlauf.md` | Automatischer Überlauf Vorderseite → Rückseite | 06 |
| 08 | `08-expliziter-seitenwechsel.md` | `\newpage` innerhalb einer Karte | 07 |
| 09 | `09-seitenlimit-und-fehlermeldungen.md` | Fehler bei >2 Seiten | 08 |
| 10 | `10-integration-und-erweiterungspunkt.md` | Integrationstest, Erweiterbarkeit für A5-Option sicherstellen | 09 |
| 11 | `11-titeltext-maximal-einpassen.md` | Titel-Schriftgröße automatisch anpassen | 06 |
| 12 | `12-druckreihenfolge.md` | Shell/PS-Skript für 4×A6-Duplex-Druck | 10 |

**Hinweis:** Die Tickets wurden am 2026-10-21 neu geschrieben. Sie enthalten nur beobachtbares Verhalten — keine Implementierungsvorschläge.

## Ticket-Details

### Ticket 05 – Karteninhalt sammeln
- `card`-Environment mit `{Titel}` und `[Referenz]` (optional)
- Inhalt sammeln, erst am Ende ausgeben
- Fixture mit beiden Syntaxformen
- Referenz wird erfasst aber noch nicht gedruckt

### Ticket 06 – Titel, Referenz, leere Rückseite
- Titel in Titelbereich, Referenz oben rechts
- Karte ohne Überlauf → 2 PDF-Seiten (Vorderseite + leere Rückseite)
- Fixture mit 2 aufeinanderfolgenden Karten

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
- Kurze Titel → Normalschrift (Obergrenze)
- Lange Titel → kleiner skalieren (kein Verzerren!)
- Mehrzeilige Titel: Gesamthöhe muss in 15 mm passen
- Referenz und Titel dürfen sich nicht überschneiden
- Passt gar nicht → `\PackageError`

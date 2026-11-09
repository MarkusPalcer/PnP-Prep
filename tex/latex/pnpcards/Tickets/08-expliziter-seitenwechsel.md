# Ticket 08: Expliziter Seitenwechsel mit \newpage

## Ziel

Ein `\newpage` innerhalb einer Karte erzwingt den Beginn der Rückseite, unabhängig davon ob die Vorderseite noch Platz hätte.

## Beobachtbares Verhalten

- `\newpage` im Inhalt: alles vor `\newpage` erscheint auf der Vorderseite, alles danach auf der Rückseite.
- Vorderseite muss nicht voll sein — `\newpage` wirkt trotzdem.
- Der `\newpage`-Befehl selbst erscheint nicht als sichtbarer Inhalt.
- Eine Karte ohne `\newpage` verhält sich weiterhin wie in Ticket 07 (natürlicher Überlauf).
- Leerer Inhalt vor oder nach `\newpage` erzeugt keine ungewollten Geistseiten.
- Das Fixture kompiliert mit `latexmk -pdf -interaction=nonstopmode -halt-on-error`.

## Fixture

Ein `.tex`-Fixture mit:
1. Einer Karte mit `\newpage` (Vorderseite nicht voll).
2. Einer Kontrollkarte ohne `\newpage` mit natürlichem Überlauf.

`% Expected Output` für beide Karten getrennt. Manuelle Abnahme.

## Nicht Bestandteil

- Verhalten bei mehr als einem `\newpage` (→ Ticket 09).

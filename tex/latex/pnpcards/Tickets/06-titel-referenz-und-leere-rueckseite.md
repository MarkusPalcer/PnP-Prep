# Ticket 06: Titelbereich, Referenz und leere Rückseite ausgeben

## Ziel

Eine kurze Karte ohne Überlauf soll als vollständige doppelseitige Karte mit korrekter Vorderseite und leerer Rückseite ausgegeben werden.

## Umsetzung

1. Setze den Titel ausschließlich in den Titelbereich der ersten Kartenseite.
2. Setze den optionalen Referenztext in die obere rechte Ecke des Titelbereichs.
3. Sorge dafür, dass der Karteninhalt auf der Vorderseite unterhalb des Titelbereichs beginnt.
4. Gib für eine Karte ohne Rückseiteninhalt eine echte leere A6-PDF-Seite aus.
5. Stelle sicher, dass die Leerseite weder Titel noch Referenz noch Inhalt der nächsten Karte übernimmt.
6. Erstelle ein Fixture mit zwei aufeinanderfolgenden Karten, damit ein versehentliches Vermischen von Seitenzustand sichtbar wird.
7. Ergänze im Fixture einen `% Expected Output`-Abschnitt, der die erwarteten vier Seiten einzeln beschreibt: erste Vorderseite mit Referenz, leere Rückseite, zweite Vorderseite ohne Referenz und deren leere Rückseite.

## Abnahmekriterien

- Eine Karte ohne Rückseiteninhalt erzeugt genau zwei PDF-Seiten.
- Die erste Seite zeigt Titel, optionalen Referenztext und Karteninhalt.
- Die zweite Seite ist leer und besitzt dennoch die korrekte A6-Seitengröße.
- Bei zwei aufeinanderfolgenden Karten erscheinen Titel und Referenz jeweils nur auf der zugehörigen Vorderseite.
- Das Fixture kompiliert mit `pdflatex -interaction=nonstopmode -halt-on-error`; der Benutzer vergleicht die vier PDF-Seiten manuell mit `% Expected Output`.

## Nicht Bestandteil

- Rückseiteninhalt oder automatischer Überlauf.
- Umordnung von Kartenseiten für den Druck.

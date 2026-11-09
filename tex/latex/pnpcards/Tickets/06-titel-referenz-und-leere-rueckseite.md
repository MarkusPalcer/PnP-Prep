# Ticket 06: Titelbereich, Referenz und leere Rückseite

## Ziel

Eine Karte ohne Überlauf gibt genau zwei PDF-Seiten aus: Vorderseite mit Titelbereich und leere Rückseite.

## Beobachtbares Verhalten

- Jede Karte erzeugt genau 2 PDF-Seiten.
- Seite 1: Titelbereich oben (15 mm), darunter Karteninhalt.
- Seite 1 mit Referenz: Referenztext erscheint oben rechts im Titelbereich.
- Seite 1 ohne Referenz: nur Titel im Titelbereich.
- Seite 2: leer, korrekte A6-Größe, kein Inhalt der nächsten Karte.
- Mehrere Karten hintereinander: Titelbereich und Referenz jeweils nur auf der eigenen Vorderseite.
- Das Fixture kompiliert mit `latexmk -pdf -interaction=nonstopmode -halt-on-error`.

## Fixture

Ein `.tex`-Fixture mit zwei aufeinanderfolgenden Karten (eine mit, eine ohne Referenz). `% Expected Output` beschreibt alle vier Seiten. Manuelle Abnahme.

## Nicht Bestandteil

- Automatischer Überlauf oder expliziter Seitenwechsel.
- Schriftgrößenanpassung des Titels (Ticket 11).

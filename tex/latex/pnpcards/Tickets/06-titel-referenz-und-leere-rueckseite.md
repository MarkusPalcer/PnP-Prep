# Ticket 06: Titelbereich und leere Rückseite

## Ziel

Eine Karte ohne Überlauf gibt genau zwei PDF-Seiten aus: Vorderseite mit Titelbereich und leere Rückseite.

## Beobachtbares Verhalten

- Jede Karte erzeugt genau 2 PDF-Seiten.
- Seite 1: Titelbereich oben (15 mm), darunter Karteninhalt.
- Seite 2: leer, korrekte A6-Größe, kein Inhalt der nächsten Karte.
- Mehrere Karten hintereinander: Titel und Karteninhalt gehören jeweils nur zur eigenen Karte.
- Das Fixture kompiliert mit `latexmk -pdf -interaction=nonstopmode -halt-on-error`.

## Referenz

Die frühere Vorgabe, die Referenz im Titelbereich auszugeben, wird ausdrücklich durch [Ticket 13](13-referenzbereich.md) ersetzt. Die Referenz soll künftig einen eigenen Layoutbereich erhalten; ihr Verhalten und ihre Geometrie werden dort festgelegt.

## Fixture

Ein `.tex`-Fixture mit zwei aufeinanderfolgenden Karten ohne Referenz. `% Expected Output` beschreibt alle vier Seiten. Manuelle Abnahme.

## Nicht Bestandteil

- Automatischer Überlauf oder expliziter Seitenwechsel.
- Schriftgrößenanpassung des Titels (Ticket 11).
- Referenzbereich und Referenzausgabe (Ticket 13).

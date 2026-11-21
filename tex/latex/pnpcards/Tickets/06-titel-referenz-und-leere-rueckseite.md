# Ticket 06: Titel, Referenzbereich und leere Rückseite

## Ziel

Eine Karte ohne Überlauf gibt genau zwei PDF-Seiten aus: Vorderseite mit Titelbereich und leere Rückseite.

## Beobachtbares Verhalten

- Jede Karte erzeugt genau 2 PDF-Seiten.
- Seite 1: Titelbereich oben (15 mm), darunter Karteninhalt.
- Seite 2: leer, korrekte A6-Größe, kein Inhalt der nächsten Karte.
- Mehrere Karten hintereinander: Titel und Karteninhalt gehören jeweils nur zur eigenen Karte.
- Das Fixture kompiliert mit `latexmk -pdf -interaction=nonstopmode -halt-on-error`.

## Referenz

Die optionale Referenz steht vor dem Titel: `\begin{card}[Referenz]{Titel} … \end{card}` beziehungsweise `\Card[Referenz]{Titel}{Inhalt}`. Fehlende, leere und nur aus Leerraum oder `\relax` bestehende Referenzen gelten als nicht gesetzt.

- Nur auf der eigenen Vorderseite erscheint ein separater Referenzbereich von 15 × 15 mm oben rechts innerhalb des 5-mm-Rands; andere Karten und Rückseiten erhalten die Referenz nicht.
- Ohne Referenz ist der Titelbereich 138 mm breit. Mit Referenz ist er 121 mm breit; zwischen beiden Bereichen liegen 2 mm. Im Debug-Modus erhält der Referenzbereich eine eigene Rahmenfarbe.
- Referenzen werden mit 9 pt und 11 pt Zeilenabstand ein- oder zweizeilig gesetzt. `WdZ. 567` passt auf eine Zeile; `WdZ. 567 \linebreak Wdz. 567` passt vollständig auf zwei Zeilen. Automatischer Zeilenumbruch ist ebenfalls möglich.
- Mehr als zwei Zeilen sowie horizontaler oder vertikaler Überlauf führen zu einem verständlichen Kompilierungsfehler. Referenzen werden nicht skaliert.
- Titel bleiben einzeilig und dürfen die Referenz nicht überlappen. Bis zur Umsetzung von Ticket 11 werden zu breite oder zu hohe Titel mit einem Fehler abgewiesen.

## Fixture

Ein `.tex`-Fixture mit zwei aufeinanderfolgenden Karten ohne Referenz. `% Expected Output` beschreibt alle vier Seiten. Manuelle Abnahme.

## Nicht Bestandteil

- Automatischer Überlauf oder expliziter Seitenwechsel.
- Schriftgrößenanpassung des Titels (Ticket 11).

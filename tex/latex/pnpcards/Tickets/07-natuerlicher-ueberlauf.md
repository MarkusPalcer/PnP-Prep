# Ticket 07: Natürlichen Textüberlauf auf die Rückseite teilen

## Ziel

Wenn der Inhalt die Vorderseitenfläche überschreitet, soll sein überlaufender Teil automatisch auf der Rückseite weiterlaufen. Die Rückseite nutzt die volle Kartenfläche ohne Titelbereich.

## Umsetzung

1. Teile den gesammelten Inhalt anhand der in Ticket 04 festgelegten Vorderseitenhöhe.
2. Bewahre die Reihenfolge des Inhalts und die normalen Absatz-/Umbruchmöglichkeiten.
3. Setze den verbleibenden Inhalt in die Rückseitenfläche, ohne dort Titel oder Referenz auszugeben.
4. Stelle sicher, dass Inhalt, der vollständig auf die Vorderseite passt, nicht zusätzlich auf die Rückseite kopiert wird; in diesem Fall bleibt die Rückseite leer.
5. Lege ein eigenes Fixture mit einer kurzen Karte und einer Karte mit natürlichem Überlauf an. Verwende sichtbare Kennzeichnungen, damit Reihenfolge und Zuordnung der Textteile im PDF überprüfbar sind.
6. Ergänze am Ende des Fixtures einen `% Expected Output`-Abschnitt, der für jede Karte die Seitenzahl, die sichtbaren Kennzeichnungen auf Vorder- und Rückseite sowie die erwartete leere Rückseite im kurzen Fall beschreibt. Der Überlauffall soll knapp über die Vorderseitenhöhe hinausgehen.

## Abnahmekriterien

- Der kurze Fall erzeugt die in Ticket 06 definierte leere Rückseite.
- Der Überlauffall zeigt den Anfang des Inhalts auf der Vorderseite und den fortlaufenden Rest auf der Rückseite.
- Der Inhalt erscheint weder doppelt noch in veränderter Reihenfolge.
- Titelbereich und Rückseitenfläche werden mit ihren unterschiedlichen Höhen berücksichtigt.
- Das Fixture kompiliert mit `pdflatex -interaction=nonstopmode -halt-on-error` und wird vom Benutzer manuell mit `% Expected Output` verglichen.

## Nicht Bestandteil

- Inhalt, der mehr als zwei Seiten benötigt; dieser wird in Ticket 09 behandelt.
- Explizite `\newpage`-Semantik; diese wird in Ticket 08 behandelt.

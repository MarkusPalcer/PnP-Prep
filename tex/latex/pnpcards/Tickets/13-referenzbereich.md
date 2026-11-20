# Ticket 13: Referenz im eigenen Layoutbereich

## Ist-Zustand

Das optionale Referenzargument wird von der `card`-Umgebung akzeptiert, aber aktuell weder für das Rendering verwendet noch ausgegeben. Die Referenz ist kein Bestandteil des Karteninhalts.

## Ziel

Eine angegebene Referenz erscheint auf der Vorderseite ihrer Karte in einem eigenen Layoutbereich, getrennt vom Titel und vom Karteninhalt.

## Beobachtbares Verhalten

- Der Referenzbereich ist 15x15mm groß in der oberen rechten Ecke der Karte
- Er ist nur vorhanden, wenn die Referenz in LaTeX gesetzt wurde
- Ist die Referenz ein leerer String oder nur nichtdruckbare Zeichen, gilt keine Referenz als nicht gesetzt
- Wenn und nur wenn der Referenzbereich vorhanden ist, ist der Titelbereich entsprechend weniger breit
- Zwischen Referenz- und Titelbereich gelten die 2mm Abstand zwischen Bereichen auf der Karte
- Im Debug-Modus wird der Referenzbereich mit einer eigenen Farbe gerendert
- Die Referenz erscheint auf der Vorderseite der zugehörigen Karte und im Referenzbereich.
- Ohne Referenz erscheint keine Referenz.
- Bei mehreren aufeinanderfolgenden Karten beeinflusst eine Referenz keine benachbarte Karte.
- Referenz und Titel überschneiden sich nicht; das Zusammenspiel mit der Titelanpassung aus Ticket 11 wird berücksichtigt.
- Die Layout- und Geometrietests prüfen den Referenzbereich sowie das Verhalten mit und ohne Referenz.

## Tests

Automatisierte Fixtures mit und ohne Referenz prüfen Ausgabe, Zuordnung zur eigenen Karte und Layoutgrenzen.
Bestehende Layout- und Geometrietests werden an den neuen Bereich angepasst, bzw. erweitert.
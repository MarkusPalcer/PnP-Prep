# Ticket 10: Kartenverhalten integrieren und Vier-Seiten-Erweiterung vorbereiten

## Ziel

Die Zwei-Seiten-Karte als zusammenhängende Funktion absichern und die interne Seitenerzeugung so strukturieren, dass eine spätere Vier-Seiten-Karte nicht eine zweite, unabhängige Aufteilungslogik benötigt. Die Vier-Seiten-Funktion selbst wird noch nicht implementiert.

## Umsetzung

1. Kompiliere das Integration-Fixture dieses Tickets; die visuellen Einzelfälle und deren manuelle Abnahme verbleiben in den jeweils zuständigen Funktionstickets.
2. Ergänze einen Integrationstest mit mehreren Karten hintereinander, darunter eine Karte mit leerer Rückseite und eine mit automatischem Überlauf.
3. Prüfe, dass jede Karte genau zwei physische PDF-Seiten belegt und keine Seite Inhalt oder Metadaten einer Nachbarkarte enthält.
4. Fasse die interne Ausgabe über logische Kartenseiten zusammen: erste Seite mit Titelbereich, nachfolgende Seiten ohne Titelbereich.
5. Halte die Zahl erlaubter logischer Seiten an einer klar abgegrenzten Stelle fest, statt das Limit in mehreren Teilroutinen fest zu verdrahten. Für diese Ticketserie bleibt der öffentliche und getestete Wert zwei.
6. Dokumentiere die Trennung zwischen logischer Inhaltsreihenfolge und späterer physischer Druckreihenfolge. Die Umordnung 1, 3, 2, 4 ist ausdrücklich nicht Teil dieses Tickets.
7. Lege ein separates Integration-Fixture mit mehreren aufeinanderfolgenden Karten an: mindestens eine kurze Karte mit leerer Rückseite, eine Karte mit natürlichem Überlauf und eine Karte mit explizitem Seitenwechsel. Beschreibe jede resultierende Seite in einem `% Expected Output`-Abschnitt.

## Abnahmekriterien

- Das Integration-Fixture kompiliert mit `pdflatex -interaction=nonstopmode -halt-on-error` und wird vom Benutzer manuell anhand von `% Expected Output` geprüft.
- Die Einzelfixtures der vorangehenden Funktionstickets behalten ihre jeweilige Abnahme in diesen Tickets; dieses Ticket ersetzt sie nicht.
- Mehrere aufeinanderfolgende Karten erzeugen je zwei korrekt zugeordnete Seiten.
- Die erste logische Seite ist von allen Folgeseiten über dieselbe zentrale Layoutentscheidung unterscheidbar.
- Eine spätere Erhöhung des Seitenlimits ist konzeptionell an einer Stelle möglich, ohne die Vorder-/Folgeseiten-Aufteilung neu zu implementieren.
- Es existiert weiterhin keine öffentliche Vier-Seiten-Syntax und keine physische Seitenumordnung.

## Nicht Bestandteil

- `doublecard` oder eine andere Vier-Seiten-Syntax.
- Umordnung der Druckseiten 1, 3, 2, 4.

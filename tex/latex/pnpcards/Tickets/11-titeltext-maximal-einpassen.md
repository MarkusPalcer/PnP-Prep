# Ticket 11: Titeltext mit maximal passender Schriftgröße setzen

## Ziel

Die Schriftgröße des Kartentitels soll sich an den verfügbaren Platz in der 1,5 cm hohen Titelzeile anpassen. Für jeden Titel wird die größtmögliche Schriftgröße verwendet, bei der der vollständige Titel in den für ihn verfügbaren Bereich passt.

## Umsetzung

1. Ermittle die tatsächlich verfügbare Titeltextfläche innerhalb der Titelzeile. Berücksichtige dabei Innenabstände und Rahmen sowie den Platz, der bei einer Karte mit Referenztext oben rechts für die Referenz freigehalten werden muss.
2. Lege eine normale Titel-Schriftgröße als Obergrenze fest. Kurze Titel sollen diese Größe behalten und nicht unnötig vergrößert werden.
3. Passe die Schriftgröße für längere Titel so an, dass der gesamte Titel in die verfügbare Fläche passt. Berücksichtige sowohl die Breite als auch die Höhe der Titelzeile.
4. Verzerre die Schrift nicht horizontal oder vertikal. Wenn ein Titel mehrzeilig gesetzt wird, muss seine gesamte Höhe weiterhin in der Titelzeile Platz finden.
5. Falls der Titel auch bei der kleinsten technisch unterstützten Schriftgröße nicht in die verfügbare Fläche passt, gib eine verständliche LaTeX-Fehlermeldung aus, statt Text abzuschneiden oder in den Referenzbereich laufen zu lassen.
6. Erstelle visuelle Test-Fixtures im bestehenden Format unter `test/unit/pnpprep/pnpcards/`. Ergänze in jedem Fixture einen `% Expected Output`-Abschnitt. Die manuelle Abnahme erfolgt durch Vergleich des erzeugten PDFs mit diesem Abschnitt.
7. Decke mindestens kurze und lange Titel sowie Titel mit und ohne Referenztext ab. Füge einen Titel hinzu, der mehrzeilig gesetzt werden muss, sofern die gewählte Umbruchregel mehrzeilige Titel unterstützt.

## Abnahmekriterien

- Ein kurzer Titel verwendet die festgelegte normale Titel-Schriftgröße.
- Ein längerer Titel wird sichtbar kleiner gesetzt, sodass der vollständige Titel innerhalb der Titelzeile bleibt.
- Die Schriftproportionen bleiben unverändert.
- Titel und Referenztext überschneiden sich nicht; der Referenztext bleibt oben rechts.
- Kein Titeltext ragt aus dem 1,5 cm hohen Titelbereich heraus oder wird abgeschnitten.
- Falls ein Titel nicht mehr in den Titelbereich eingepasst werden kann, schlägt die Kompilierung mit einer aussagekräftigen Fehlermeldung fehl.
- Die Test-PDFs lassen sich mit `pdflatex -interaction=nonstopmode -halt-on-error` erzeugen und werden manuell anhand der `% Expected Output`-Abschnitte abgenommen.
- Die Titel-Testfixtures liegen bei diesem Ticket und nicht im zentralen Testfall-Ticket.

## Nicht Bestandteil

- Änderung der Höhe des Titelbereichs.
- Automatische Anpassung der Referenztext-Schriftgröße.
- Anpassung der Schriftgröße des Karteninhalts.

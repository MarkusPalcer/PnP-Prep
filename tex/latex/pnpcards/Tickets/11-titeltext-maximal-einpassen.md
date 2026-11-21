# Ticket 11: Titeltext mit passender Schriftgröße setzen

## Ziel

**Offen:** Die automatische Titelanpassung ist noch nicht implementiert. Der einzeilige Kartentitel wird vollständig im 15 mm hohen Titelbereich angezeigt. Bei längeren Titeln wird die Schrift proportional so weit verkleinert wie nötig, bis zur Mindestgröße 7 pt; für kurze Titel gilt 10 pt als Obergrenze.

Ohne Referenz stehen 138 mm Titelbreite zur Verfügung. Mit Referenz werden feste 15 mm für deren Bereich und 2 mm Abstand abgezogen, sodass 121 mm bleiben; die Breite hängt nicht vom gemessenen Referenztext ab. Die derzeitige Fehlermeldung bei überbreiten oder überhohen Titeln wird durch das Einpassen ersetzt; erst wenn das Einpassen bis zur Mindestgröße nicht ausreicht, wird ein Fehler gemeldet.

## Beobachtbares Verhalten

- Kurzer Titel → erscheint in der Standardschriftgröße 10 pt (Obergrenze).
- Langer Titel → erscheint kleiner, aber vollständig innerhalb des Titelbereichs.
- Titel und Referenztext überschneiden sich nicht.
- Die Schriftproportionen bleiben unverändert (kein Strecken oder Stauchen).
- Kein Titeltext ragt aus dem Titelbereich heraus oder wird abgeschnitten.
- Ist ein Titel auch bei 7 pt zu breit oder zu hoch → Kompilierungsfehler mit klarer Meldung.
- Die Fixtures kompilieren mit `latexmk -pdf -interaction=nonstopmode -halt-on-error`.

## Fixtures

Fixtures unter `test/unit/pnpprep/pnpcards/`, jeweils mit automatisierten Tests testen unterschiedliche Titellängen mit und ohne Referenz:

- Titel kurz genug, dass er _mit_ Referenz die gleiche größe hat wie _ohne_
- Titel wird kleiner, wenn die Referenz eingeblendet wird
- Titel wird bereits ohne Referenz verkleinert
- Titel verletzt mit Referenz die Mindestgröße und verursacht einen Compilefehler, aber ohne Referenz nicht
- Titel verletzt mit und ohne Referenz die Mindestgröße und verursacht einen Compilefehler

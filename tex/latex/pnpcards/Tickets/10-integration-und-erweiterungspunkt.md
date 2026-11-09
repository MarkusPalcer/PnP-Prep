# Ticket 10: Integration und Erweiterbarkeit auf 4-Seiten-Karten vorbereiten

## Ziel

Alle bisherigen Verhaltensweisen (Tickets 05–09) funktionieren zusammen korrekt. Das interne Design erlaubt es, später 4-Seiten-Karten hinzuzufügen, ohne die bestehende Logik neu zu schreiben.

## Beobachtbares Verhalten

- Mehrere aufeinanderfolgende Karten erzeugen je genau 2 PDF-Seiten.
- Kein Inhalt oder Zustand einer Karte gelangt auf die Seiten einer anderen Karte.
- Eine Mischung aus kurzen Karten (leere Rückseite), Karten mit natürlichem Überlauf und Karten mit explizitem `\newpage` funktioniert korrekt in einem Dokument.
- Das Integrations-Fixture kompiliert mit `latexmk -pdf -interaction=nonstopmode -halt-on-error`.

## Internes Designziel (nicht testbar, aber dokumentiert)

Das Seitenlimit (aktuell: 2) ist an einer einzigen Stelle im Code konfigurierbar — nicht über mehrere Routinen verteilt. Eine spätere Erhöhung auf 4 für `doublecard` erfordert keine strukturelle Umgestaltung.

Die logische Reihenfolge der Seiten im Dokument entspricht der Ausgabereihenfolge des Inhalts. Die physische Umordnung für den Druck geschieht extern durch `print_cards.rb` und ist kein Teil der Klasse.

## Fixture

Ein Integrations-Fixture mit mindestens:
- einer kurzen Karte (leere Rückseite),
- einer Karte mit natürlichem Überlauf,
- einer Karte mit explizitem `\newpage`.

`% Expected Output` für alle Seiten. Manuelle Abnahme.

## Nicht Bestandteil

- `doublecard` oder eine 4-Seiten-Syntax.
- Implementierung der Seitenumordnung innerhalb der Klasse.

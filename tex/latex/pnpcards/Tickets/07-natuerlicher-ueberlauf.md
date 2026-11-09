# Ticket 07: Automatischer Überlauf auf die Rückseite

## Ziel

Übersteigt der Inhalt die Vorderseitenfläche, läuft er automatisch auf die Rückseite weiter. Die Rückseite hat keinen Titelbereich und nutzt die volle Kartenhöhe.

## Beobachtbares Verhalten

- Kurzer Inhalt (passt auf Vorderseite): Rückseite bleibt leer (wie in Ticket 06).
- Langer Inhalt (übersteigt Vorderseitenhöhe): Anfang auf Vorderseite, Rest fließt auf Rückseite.
- Kein Inhalt erscheint doppelt oder in falscher Reihenfolge.
- Rückseite hat keinen Titelbereich — die volle A6-Höhe steht für Inhalt zur Verfügung.
- Das Fixture kompiliert mit `latexmk -pdf -interaction=nonstopmode -halt-on-error`.

## Fixture

Ein `.tex`-Fixture mit einer kurzen Karte (leere Rückseite) und einer Karte mit natürlichem Überlauf. Sichtbare Kennzeichnungen im Inhalt (z. B. „START", „MITTE", „ENDE") ermöglichen manuelle Überprüfung der Reihenfolge. `% Expected Output` für beide Karten.

## Nicht Bestandteil

- Expliziter Seitenwechsel via `\newpage` (Ticket 08).
- Fehler bei zu viel Inhalt (Ticket 09).

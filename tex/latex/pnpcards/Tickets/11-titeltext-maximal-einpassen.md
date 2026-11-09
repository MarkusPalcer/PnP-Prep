# Ticket 11: Titeltext mit passender Schriftgröße setzen

## Ziel

Der Kartentitel wird immer vollständig im 15 mm hohen Titelbereich angezeigt. Bei kurzen Titeln gilt eine feste Obergrenze der Schriftgröße; bei längeren Titeln wird die Schrift so weit verkleinert wie nötig.

## Beobachtbares Verhalten

- Kurzer Titel → erscheint in der festgelegten Standardschriftgröße (Obergrenze).
- Langer Titel → erscheint kleiner, aber vollständig innerhalb des Titelbereichs.
- Titel und Referenztext überschneiden sich nicht.
- Die Schriftproportionen bleiben unverändert (kein Strecken oder Stauchen).
- Kein Titeltext ragt aus dem Titelbereich heraus oder wird abgeschnitten.
- Ist ein Titel auch bei kleinster sinnvoller Schriftgröße zu lang → Kompilierungsfehler mit klarer Meldung.
- Die Fixtures kompilieren mit `latexmk -pdf -interaction=nonstopmode -halt-on-error`.

## Fixtures

Fixtures unter `test/unit/pnpprep/pnpcards/`, jeweils mit `% Expected Output`:
- Kurzer Titel (ohne Referenz) → Standardgröße sichtbar.
- Kurzer Titel mit Referenz → keine Überschneidung.
- Langer Titel (ohne Referenz) → sichtbar kleiner.
- Langer Titel mit Referenz → passt, keine Überschneidung.
- Titel, der nicht passt → Negativ-Fixture, erwarteter Kompilierungsfehler.

Manuelle Abnahme durch PDF-Vergleich.

## Nicht Bestandteil

- Änderung der Titelbereichshöhe.
- Schriftgrößenanpassung für Referenztext oder Karteninhalt.
- Mehrzeilige Titel (nicht unterstützt — Titel ist immer einzeilig).

## Implementierungshinweise (geklärt 2026-10-21)

**Mechanismus:** `\scalebox` aus `graphicx`.

```latex
\setbox0=\hbox{\textbf{#1}}%
\ifdim\wd0>\pnpcards@maxtitlewidth
    % Zu breit: skalieren
    % Faktor = maxtitlewidth / \wd0 (via \dimratio oder \strip@pt)
    \scalebox{f}{\textbf{#1}}%
\else
    \textbf{#1}%
\fi
```

**Schriftgrößen:**
- Obergrenze: `\normalsize` (10 pt)
- Untergrenze: 7 pt (Faktor < 0.7 → `\PackageError`)

**Titelbreite:** `\pnpcards@maxtitlewidth` = `\textwidth` (kein Ref) oder `\textwidth - Referenzbreite - Abstand` (mit Ref). Referenzbreite wird beim Setzen der Karte gemessen.

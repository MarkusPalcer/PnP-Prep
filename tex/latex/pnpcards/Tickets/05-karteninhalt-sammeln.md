# Ticket 05: card-Environment – Inhalt sammeln und Vorderseite rendern

## Ziel

Das öffentliche `card`-Environment nimmt Titel, optionale Referenz und beliebigen Inhalt entgegen. Der Inhalt wird vollständig gesammelt, bevor er gesetzt wird. In diesem Schritt wird der Inhalt ausschließlich auf der Vorderseite gerendert.

## Beobachtbares Verhalten

- `\begin{card}[Ref]{Titel} … \end{card}` kompiliert.
- `\begin{card}{Titel} … \end{card}` (ohne Referenz) kompiliert.
- Titel erscheint im Titelbereich der Vorderseite.
- Karteninhalt erscheint unterhalb des Titelbereichs auf der Vorderseite.
- Der optionale Referenztext wird erfasst, aber in diesem Schritt noch nicht gedruckt.
- Kein Inhalt gelangt in den Dokumentfluss außerhalb der Karte.
- Das Fixture kompiliert mit `latexmk -pdf -interaction=nonstopmode -halt-on-error`.

## Fixture

Ein `.tex`-Fixture unter `test/unit/pnpprep/pnpcards/` mit beiden Syntaxvarianten und einem `% Expected Output`-Abschnitt. Manuelle Abnahme durch Vergleich mit dem PDF.

## Nicht Bestandteil

- Leere Rückseite oder Rückseiteninhalt.
- Automatischer Überlauf.
- Sichtbare Ausgabe der Referenz (in diesem historischen Sammelschritt noch nicht enthalten).

## Dokumentation: Einschränkungen im Sammelmodus

Der Body wird als Token-Liste gesammelt und dann in eine `\vbox` gesetzt.
Daraus ergeben sich folgende Einschränkungen:

| Konstrukt | Status | Hinweis |
|---|---|---|
| Text, Absätze, `\textbf`, Listen | ✓ ok | — |
| `tabular`, `\includegraphics` | ✓ ok | Als Box direkt gesetzt |
| `\verb\|...\|` (inline) | ✓ ok | — |
| `\begin{figure}` / `\begin{table}` | ✗ nicht | Floats benötigen Output-Routine, werden ignoriert |
| `\begin{verbatim}` | ✗ nicht | Kategorie-Codes werden beim Tokenisieren nicht gesetzt |
| `\footnote`, `\marginpar` | ✗ nicht | Globale Seiteneffekte, erscheinen an falscher Stelle |

Mehrzeiliger Verbatim-Inhalt: `fancyvrb`'s `\SaveVerbatim`/`\UseVerbatim` als Workaround.

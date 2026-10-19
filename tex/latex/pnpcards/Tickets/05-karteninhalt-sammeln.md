# Ticket 05: Karteninhalt und Metadaten erfassen

## Ziel

Die öffentliche Umgebung `card` soll Titel, optionalen Referenztext und den vollständigen Karteninhalt aufnehmen können, ohne den Inhalt direkt in den Dokumentfluss auszugeben. In diesem Schritt wird der Inhalt zunächst nur auf der Vorderseite gerendert.

## Umsetzung

1. Implementiere die gewünschte Grundsyntax:

   ```latex
   \begin{card}{Überschrift}[WdZ 102]
   Karteninhalt
   \end{card}
   ```

2. Unterstütze das Weglassen des optionalen Referenzarguments:

   ```latex
   \begin{card}{Überschrift}
   Karteninhalt
   \end{card}
   ```

3. Sammle den Environment-Inhalt vollständig, bevor die Kartenseite ausgegeben wird.
4. Rendere den gesammelten Inhalt in der in Ticket 04 definierten Vorderseitenfläche.
5. Verwende ein minimales Fixture mit normalen Absätzen und mathematischem Inhalt, sofern die in Ticket 03 überführte Klassenimplementierung dies unterstützt.
6. Dokumentiere klar, falls bestimmte LaTeX-Konstrukte im gesammelten Karteninhalt nicht unterstützt werden.
7. Lege ein eigenes visuelles Fixture an, das beide Syntaxformen verwendet: einmal mit optionaler Referenz und einmal ohne. Ergänze `% Expected Output`-Kommentare, die die beiden Vorderseiten und ihre Inhalte in der richtigen Reihenfolge beschreiben. In diesem Ticket muss die Referenz noch nicht sichtbar gedruckt werden; prüfe aber, dass sie nicht als Karteninhalt erscheint. Ihre sichtbare Position wird in Ticket 06 abgenommen.

## Abnahmekriterien

- Beide Syntaxvarianten kompilieren.
- Der Titel und der Karteninhalt erscheinen auf der Vorderseite; der optionale Referenztext wird erfasst, aber in diesem Schritt noch nicht gedruckt.
- Der Karteninhalt wird erst nach dem Ende des `card`-Environments ausgegeben.
- Der Test zeigt, dass der Karteninhalt nicht ungewollt in den normalen Dokumentfluss außerhalb der Karte gelangt.
- Das Fixture kompiliert mit `pdflatex -interaction=nonstopmode -halt-on-error` und wird vom Benutzer manuell anhand seines `% Expected Output`-Abschnitts abgenommen.

## Nicht Bestandteil

- Automatischer Überlauf auf die Rückseite.
- Endgültiges Titel-/Referenzlayout und Einfügen einer leeren Rückseite.

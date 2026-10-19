# Ticket 08: Expliziten Seitenwechsel innerhalb einer Karte unterstützen

## Ziel

Ein explizites `\newpage` in einer Karte soll die Rückseite beginnen lassen, auch wenn die Vorderseite noch nicht voll ist. Der Seitenwechsel darf nicht mit einem natürlichen Überlauf verwechselt werden.

## Umsetzung

1. Nutze die Erkenntnisse aus Ticket 01, um `\newpage` im gesammelten Inhalt zuverlässig als expliziten Seitenwechsel zu erkennen.
2. Beende am Marker die erste logische Seite und setze den folgenden Inhalt auf der Rückseite fort.
3. Gib den Marker selbst nicht als Inhalt aus.
4. Definiere und implementiere ein einheitliches Verhalten, wenn vor oder nach einem expliziten Seitenwechsel kein sichtbarer Inhalt steht; vermeide dabei unbeabsichtigte zusätzliche PDF-Seiten.
5. Ergänze Tests für einen Seitenwechsel nach Vorderseiteninhalt und für einen weiteren Seitenwechsel, der eine dritte Seite anfordern würde.
6. Stelle sicher, dass ein natürlicher Überlauf auch dann weiterhin funktioniert, wenn im selben Karteninhalt kein `\newpage` vorkommt.
7. Lege ein eigenes `.tex`-Fixture für eine Karte mit Inhalt vor und nach `\newpage` an. Beschreibe im `% Expected Output`-Abschnitt Vorder- und Rückseite getrennt und ergänze dort auch die erwartete Ausgabe eines natürlichen Überlaufs als Kontrollkarte.

## Abnahmekriterien

- Das Beispiel mit Vorderseitentext, `\newpage` und Rückseitentext erzeugt genau zwei Kartenseiten.
- Der Text nach `\newpage` erscheint auf der Rückseite und wird nicht auf die Vorderseite zurückgezogen.
- Ein Seitenwechsel zählt als explizite Seitengrenze und wird nicht gedruckt.
- Der natürliche Überlauf aus Ticket 07 bleibt unverändert funktionsfähig.
- Das Fixture kompiliert mit `pdflatex -interaction=nonstopmode -halt-on-error`; der Benutzer nimmt Seitenzuordnung und Inhaltsreihenfolge manuell anhand von `% Expected Output` ab.

## Nicht Bestandteil

- Mehr als zwei Kartenseiten; die Grenzverletzung wird in Ticket 09 abschließend behandelt.

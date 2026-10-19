# Planung für `pnpcards.cls`

## Anforderungen

- A card is sized A6 landscape
- There is max 0.5cm border on each card
- Each card has a front and a back
- The front and back are generated as 2 pages in the PDF
- If a card only needs its front, the back will be a blank page
- Each card has a title which is only printed on the front
- In the front (the title area) in the upper right corner can be a short reference (like "WdZ 123")
- In the back there is no title area, the text is over the whole card
- If the text on the front of the card is too long, it should be automatically span the back of the card
- If the text is too long for the front _and_ back, compilation fails with an error
- The solution should not block later features like:
  - Cards that span 4 A6 pages (again only the first page has the title)
    - Only 2 or 4 page cards will be supported
    - The pages will be reordered to 1, 3, 2, 4 when generating the PDF


## Wünsche

### Syntax

```latex
\begin{card}{Überschrift}[WdZ 102]
Dies ist Text in der Karte. Wenn der Text lang genug ist, wird er auf die andre Seite umbrochen
\end{card}

\begin{card}{Überschrift}
Dies ist Text auf der Vorderseite der Karte
\newpage
Dies ist Text auf der Rückseite der Karte
\end{card}

\begin{doublecard}{Überschrift}
Dies ist eine Karte, die über 4 Seiten geht
\newpage
Dieser Text steht auf der zweiten Seite
\newpage
Dieser Text sthet auf der dritten Seite
\newpage
Dieser Text steht auf der vierten Seite
\end{doublecard}

\begin{card}{Überschrift}
Diese Definition führt zu einem Compilefehler, weil sie sich über mehr als 2 Seiten erstreckt
\newpage
Seite 2
\newpage
Verboten: Seite 3
\end{card}

\begin{doublecard}{Überschrift}
Diese Definition führt zu einem Compilefehler, weil sie sich über mehr als 4 Seiten erstreckt
\newpage
Seite 2
\newpage
Seite 3
\newpage
Seite 4
\newpage
Verboten: Seite 5
\end{card}
```

## Lösungsmöglichkeiten

Für alle Varianten gelten dieselben festen Layoutregeln: A6-Seitenformat im Querformat, höchstens 0,5 cm Rand, ein Titelbereich nur auf der ersten Seite einer Karte und kein Titelbereich auf den Folgeseiten. Eine leere Rückseite muss als echte leere PDF-Seite ausgegeben werden. Der wesentliche Unterschied ist, **wann und wie der Karteninhalt in Seiten aufgeteilt wird**.

### 1. Inhalt sammeln und automatisch auf Seiten aufteilen

Das `card`-Environment sammelt den gesamten Inhalt zunächst ein, setzt ihn in einen Satzspiegel und teilt das Ergebnis anschließend an den verfügbaren Seitenhöhen auf. Für die erste Seite wird Platz für Titel und Referenz reserviert; die Folgeseite nutzt die ganze Kartenfläche. Bleibt nach der erlaubten Seitenzahl noch Inhalt übrig, wird ein Fehler gemeldet. Eine Karte ohne Überlauf erhält eine leere Rückseite.

```latex
\begin{card}{Überschrift}[WdZ 102]
Dies ist der Karteninhalt. Passt er nicht auf die Vorderseite,
wird der Rest automatisch auf der Rückseite ausgegeben.
\end{card}
```

**So sähe das Ergebnis aus:** PDF-Seite 1 zeigt Titel und Referenz oben sowie den Anfang des Textes. PDF-Seite 2 zeigt den übergelaufenen Rest über die ganze A6-Fläche; reicht der Text auf Seite 1, bleibt Seite 2 leer.

**Vorteile**

- Entspricht am ehesten der Wunschsyntax und dem automatischen Überlauf.
- Die Nutzenden müssen den Text nicht selbst auf Vorder- und Rückseite verteilen.
- Die erlaubte Seitenzahl lässt sich am Kartenende prüfen; zu viel Inhalt kann einen gezielten Fehler auslösen.
- Eine spätere Variante mit vier Seiten ist als Erweiterung desselben Aufteilungsprinzips denkbar.

**Nachteile**

- Die Implementierung ist anspruchsvoll: TeX muss den Inhalt vollständig sammeln, umbrechen, an passenden Stellen teilen und den Rest zuverlässig erkennen.
- Explizite Seitenwechsel wie `\newpage` innerhalb des gesammelten Inhalts müssen definiert und korrekt behandelt werden.
- Nicht jedes TeX-Konstrukt lässt sich problemlos sammeln oder aufteilen (beispielsweise Floats, verbatim-artiger Inhalt und manche globale Seiteneffekte).
- Titelbereich und nutzbare Seitenhöhen müssen beim Teilen genau berücksichtigt werden; die Rückseite hat absichtlich eine andere nutzbare Höhe als die Vorderseite.

### 2. Vorder- und Rückseite explizit auszeichnen

Die Karte enthält getrennte Bereiche für Vorder- und Rückseite. Das Environment kann jeden Bereich unabhängig setzen und prüfen. Der Inhalt wird nicht automatisch von einem Bereich in den anderen verschoben: Die Person, die das Dokument schreibt, entscheidet explizit, was auf welche Seite kommt.

```latex
\begin{card}{Überschrift}[WdZ 102]
\begin{front}
Dies steht auf der Vorderseite.
\end{front}
\begin{back}
Dies steht auf der Rückseite und nutzt die ganze Kartenfläche.
\end{back}
\end{card}
```

**So sähe das Ergebnis aus:** PDF-Seite 1 zeigt Titel, Referenz und den Inhalt von `front`; PDF-Seite 2 zeigt ausschließlich den Inhalt von `back`. Wird `back` weggelassen, wird eine leere Rückseite erzeugt.

**Vorteile**

- Die Seitenzuordnung ist im Quelltext sichtbar und vorhersehbar.
- Vorder- und Rückseite können unabhängig geprüft werden; zu viel Inhalt auf einer Seite lässt sich gezielt melden.
- Geringere technische Komplexität als beim automatischen Teilen eines einzigen Textstroms.
- Ein späterer `page`- oder `side`-Bereich für vier Seiten ist gut vorstellbar.

**Nachteile**

- Weicht deutlich von der Wunschsyntax ab und macht kurze Karten umständlicher.
- Der automatische Überlauf von der Vorder- auf die Rückseite ist damit nicht erfüllt; der Text muss manuell aufgeteilt werden.
- Eine Karte mit Inhalt nur auf der Vorderseite braucht weiterhin eine definierte, gegebenenfalls leere Rückseite.
- Falls später doch automatisches Verschieben gewünscht ist, braucht es zusätzlich eine Teilungslogik; die expliziten Bereiche lösen dieses Problem nicht von selbst.

### 3. Seitenweise setzen und Karten über Seitenwechsel begrenzen

Jede physische Kartenseite wird direkt als Seite im normalen Dokumentfluss gesetzt. Kartenbefehle konfigurieren das Seitenlayout; ein Seitenwechsel markiert den Wechsel zur Rückseite. Die Klasse zählt die tatsächlich ausgegebenen Seiten pro Karte und meldet einen Fehler, sobald die erlaubte Zahl überschritten wird.

```latex
\begin{card}{Überschrift}[WdZ 102]
Dies steht auf der Vorderseite.
\newpage
Dies steht auf der Rückseite.
\end{card}
```

**So sähe das Ergebnis aus:** PDF-Seite 1 zeigt den Titelbereich und den Vorderseitentext. Nach `\newpage` beginnt PDF-Seite 2 ohne Titelbereich und mit vollflächigem Text. Ohne Seitenwechsel kann die Klasse eine leere Rückseite ausgeben.

**Vorteile**

- Nutzt den gewöhnlichen LaTeX-Seitenumbruch und ist für explizit zugewiesene Seiten einfach zu verstehen.
- Der Wechsel zur Rückseite ist im Quelltext sichtbar.
- Die Anzahl ausgegebener Seiten kann überwacht werden; eine spätere Umstellung der Reihenfolge beim PDF-Ausgeben kann als eigener Schritt vorgesehen werden.
- Weniger Sammel- und Box-Logik als beim vollständigen Einfangen eines Karteninhalts.

**Nachteile**

- Ein langer Text kann vom normalen Seitenumbruch auf eine weitere Seite laufen; diese Seite muss noch zuverlässig der richtigen Karte zugeordnet werden, damit die Grenze von zwei Seiten eingehalten wird.
- Automatisches Fortsetzen auf der Rückseite ist nicht selbstverständlich: Titelbereich, Seitenstil und Kartenzähler müssen beim Übergang korrekt wechseln.
- Karteninhalt und umgebender Dokumentfluss sind enger gekoppelt. Ein nicht erwarteter Seitenumbruch kann die Zuordnung der Seiten erschweren.
- Spätere Seitenumordnung (insbesondere 1, 3, 2, 4) erfordert eine gesonderte Ausgabelogik und darf nicht nur auf der sichtbaren Seitenreihenfolge beruhen.

## Vergleich mit der Wunschsyntax

| Variante | Nähe zur Wunschsyntax | Automatischer Überlauf Vorderseite → Rückseite | Aufwand | Eignung für spätere 4-Seiten-Karten |
| --- | --- | --- | --- | --- |
| 1. Inhalt sammeln und teilen | Hoch: `\begin{card}{Titel}[Referenz] ... \end{card}` kann nahezu unverändert bleiben. | Ja, ist Kern dieser Variante. | Hoch | Gut, wenn die Aufteilung von Anfang an eine konfigurierbare Seitenzahl unterstützt. Die Ausgabe-Reihenfolge muss zusätzlich entworfen werden. |
| 2. Vorder- und Rückseite auszeichnen | Niedrig bis mittel: `card` bleibt, aber `front` und `back` kommen hinzu. | Nein, die Aufteilung erfolgt manuell. | Niedrig bis mittel | Gut für explizite Seitenbereiche; vier Bereiche oder eine allgemeine Seitenstruktur wären nötig. |
| 3. Seitenweise setzen | Mittel: `card` bleibt, `\newpage` wird zum sichtbaren Seitenwechsel wie im Wunschbeispiel. | Möglich, aber nicht automatisch durch die Syntax garantiert; muss durch die Seitenlogik implementiert werden. | Mittel bis hoch | Möglich, aber Seitenzählung und spätere Umordnung müssen ausdrücklich mitgeplant werden. |

Die Wunschsyntax legt nahe, dass ein `card`-Environment den Inhalt sammelt und die erste Seite vom Folgeteil unterscheiden kann. Besonders die Kombination aus automatischem Überlauf, explizitem `\newpage` und einem Fehler bei einer dritten Seite macht Variante 1 zum passendsten Ansatz. Das Environment muss dabei beide Arten von Seitenaufteilung eindeutig definieren: Ein natürlicher Überlauf soll auf die Rückseite führen; ein expliziter Seitenwechsel soll die Rückseite beginnen. Ein weiterer Seitenwechsel oder verbleibender Inhalt muss den geforderten Fehler auslösen.

Das ist **mittlerer bis hoher Implementierungsaufwand** und nicht bloß eine Änderung der Basisklasse: Entscheidend sind das Sammeln des Inhalts, die unterschiedlichen verfügbaren Höhen mit und ohne Titelbereich, die Erkennung von Überlauf und expliziten Seitenwechseln sowie eine aussagekräftige Fehlermeldung. Außerdem muss geprüft werden, welche LaTeX-Inhalte innerhalb einer Karte unterstützt werden. Ein Prototyp sollte deshalb früh die Grenzfälle „passt genau auf Seite 1“, „läuft knapp auf Seite 2 über“, „passt genau auf zwei Seiten“ und „benötigt eine dritte Seite“ abdecken.

Die Wunschsyntax kann mit Variante 1 weitgehend beibehalten werden. Für vier Seiten ist die konkrete Vier-Seiten-Syntax noch offen; sie sollte später dieselbe Karten- und Seitenlogik nutzen können, statt eine unabhängige zweite Implementierung zu erzwingen. Die spätere PDF-Reihenfolge 1, 3, 2, 4 ist dabei als eigene Ausgabestufe zu behandeln. Sie ändert nicht die logische Reihenfolge der Seiten im Karteninhalt, muss aber im Design der Seitenzuordnung vorgesehen sein.

## Lösungsempfehlung

Ich empfehle **Variante 1: den Karteninhalt sammeln und automatisch auf Seiten aufteilen**. Sie ist die einzige der drei Varianten, die den automatischen Überlauf als grundlegendes Verhalten bietet und zugleich die Wunschsyntax nahezu unverändert lässt. Die höhere Implementierungskomplexität ist durch die Anforderungen gerechtfertigt: Der automatische Umbruch, die unterschiedliche Fläche auf Vorder- und Rückseite sowie der Fehler bei einer überschrittenen Seitenzahl sind zentrale Funktionen und keine optionalen Details.

Für eine wartbare Umsetzung sollte die Karte intern nicht als „genau zwei Seiten“ modelliert werden, sondern als **Folge logischer Kartenseiten** mit einer gemeinsamen Layout- und Validierungslogik. Für die erste Seite werden Titel und optionale Referenz reserviert, Folgeseiten verwenden die volle Kartenfläche. Die Zwei-Seiten-Karte begrenzt diese Folge zunächst auf zwei Seiten; das Design sollte eine spätere Begrenzung auf vier Seiten erlauben. Eine leere Rückseite wird bei Bedarf ergänzt. Die PDF-Ausgabe sollte von dieser logischen Seitenerzeugung getrennt bleiben, damit die spätere physische Umordnung 1, 3, 2, 4 nicht die Inhaltsaufteilung komplizierter macht.

Vor der vollständigen Umsetzung sollte ein kleiner Prototyp die kritischen Fälle klären: natürlichen Textüberlauf, explizites `\newpage`, exakt passende Seiten und Inhalt, der eine zusätzliche Seite benötigt. Insbesondere muss festgelegt sein, ob ein expliziter Seitenwechsel eine neue logische Seite erzwingt und wie ein dadurch leerer Bereich behandelt wird. Falls sich herausstellt, dass beliebiger LaTeX-Inhalt nicht zuverlässig gesammelt und geteilt werden kann, wäre Variante 2 der robuste Rückfall: explizite Vorder- und Rückseiten auf Kosten des automatischen Überlaufs.

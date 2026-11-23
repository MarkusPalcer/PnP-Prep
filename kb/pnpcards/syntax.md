# pnpcards – Syntax

← [pnpcards Index](index.md)

## Karten

```latex
% Kurze Karte – passt auf Vorderseite, Rückseite bleibt leer
\begin{card}[WdZ. 567 \linebreak Wdz. 567]{Überschrift}
Karteninhalt – wenn lang, läuft er automatisch auf die Rückseite über.
\end{card}

% Karte mit explizitem Seitenwechsel
\begin{card}{Überschrift}
Vorderseite
\newpage
Rückseite
\end{card}

% Kurzform mit optionaler Referenz
\Card[WdZ. 567]{Überschrift}{Karteninhalt}
```

## Fehlerfall

- Mehr als 2 Seiten in `card` oder `\Card` → Kompilierungsfehler mit dokumentweit fortlaufendem Kartenindex ab 1 und Titel als nicht expandiertem Text. Zwei `\newpage` zählen auch bei leeren Bereichen oder am Kartenende; ein Umbruch nach natürlichem Überlauf auf die Rückseite verlangt ebenfalls eine dritte Seite.
- Ein bei einem solchen Fehler entstandenes PDF ist ungültig; sein Inhalt und sein Vorhandensein sind nicht zugesichert.
- Titel, die selbst bei effektiven 7 pt zu breit oder zu hoch sind → Kompilierungsfehler mit Kartenindex und Ursache
- Referenzen mit mehr als zwei Zeilen oder Überlauf → Kompilierungsfehler

## Aktuell implementiert

```latex
% Kurzform für eine einzeilige Karte
\Card{Titel}{Inhalt}

% Umgebung für mehrzeilige Karten
\begin{card}{Titel}
Karteninhalt
\end{card}
```

`\Card[Referenz]{Titel}{Inhalt}` ist die Kurzform der `card`-Umgebung. Das optionale Argument kann bei beiden Formen entfallen; fehlende, leere, reine Leerraum- und `\relax`-Referenzen gelten als nicht gesetzt. Beide Schreibweisen unterstützen natürliche und explizite Seitenumbrüche. Eine Karte ohne Überlauf erzeugt genau zwei A6-Querformat-PDF-Seiten; ihre Rückseite bleibt vollständig unbedruckt, auch vor der nächsten Karte und im Debug-Modus.

Referenzen erscheinen ausschließlich auf der eigenen Vorderseite im separaten, unskalierten 15 × 15 mm großen Bereich innerhalb des 5-mm-Rands. Sie verwenden 9 pt mit 11 pt Zeilenabstand und dürfen ein- oder zweizeilig sein: `WdZ. 567` sowie `WdZ. 567 \linebreak Wdz. 567` passen; automatischer Umbruch ist ebenfalls möglich. Mehr als zwei Zeilen oder horizontaler bzw. vertikaler Überlauf führen zu einem Kompilierungsfehler. Der Referenzbereich hat im Debug-Modus eine eigene Rahmenfarbe.

Der Titelbereich ist ohne Referenz 138 mm, mit Referenz 121 mm breit und 15 mm hoch; der Abstand zum Referenzbereich beträgt 2 mm. Titel bleiben einzeilig und werden pro Karte proportional so weit vergrößert oder verkleinert, wie es Breite und Höhe erlauben. Die Titelbasis ist unabhängig von der Dokumentgrundschrift 10 pt; die effektive Mindestgröße beträgt 7 pt, nach oben gibt es keine 10-pt-Grenze. Passt der Titel auch bei 7 pt nicht, folgt ein Kompilierungsfehler. Ein leerer Titel bleibt leer; Referenz und Body bleiben unskaliert.

Der Body der `card`-Umgebung wird beim Einlesen direkt in eine Box gesetzt; die Kartenausgabe beginnt nach `\end{card}`. Text, mehrere Absätze, Formatierungen wie `\textbf`, Listen, `tabular` und direkt eingebundene Grafiken sind automatisiert geprüft. Inline-`\verb` mit Sonderzeichen funktioniert in der `card`-Umgebung, nicht jedoch allgemein im bereits tokenisierten Inhaltsargument von `\Card`.

Mehrzeiliges `verbatim` wird nicht allgemein zugesagt. Als getesteter Workaround kann Inhalt mit `fancyvrb` per `\SaveVerbatim` außerhalb und `\UseVerbatim` innerhalb der Karte gespeichert werden. Floats (`figure`/`table`), `\footnote` und `\marginpar` werden nicht unterstützt; sie können verloren gehen oder mit `Float(s) lost` fehlschlagen. Beliebige LaTeX-Konstrukte und Seiteneffekte sind unter der automatischen Kartenaufteilung nicht garantiert.

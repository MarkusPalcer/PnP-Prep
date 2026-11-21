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

- Mehr als 2 Seiten in `card` → Kompilierungsfehler
- Überbreite oder überhohe Titel → vorläufig Kompilierungsfehler (automatisches Einpassen bleibt Ticket 11)
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

`\Card[Referenz]{Titel}{Inhalt}` ist die Kurzform der `card`-Umgebung. Das optionale Argument kann bei beiden Formen entfallen; Leerraum und `\relax` allein gelten als fehlende Referenz. Beide Schreibweisen unterstützen natürliche und explizite Seitenumbrüche. Referenzen erscheinen ausschließlich auf der eigenen Vorderseite im separaten 15 × 15 mm großen Bereich, gesetzt mit 9 pt und 11 pt Zeilenabstand über höchstens zwei Zeilen; `\linebreak` ist möglich.

Der Body der `card`-Umgebung wird beim Einlesen direkt in eine Box gesetzt; die Kartenausgabe beginnt nach `\end{card}`. Text, mehrere Absätze, Formatierungen wie `\textbf`, Listen, `tabular` und direkt eingebundene Grafiken sind automatisiert geprüft. Inline-`\verb` mit Sonderzeichen funktioniert in der `card`-Umgebung, nicht jedoch allgemein im bereits tokenisierten Inhaltsargument von `\Card`.

Mehrzeiliges `verbatim` wird nicht allgemein zugesagt. Als getesteter Workaround kann Inhalt mit `fancyvrb` per `\SaveVerbatim` außerhalb und `\UseVerbatim` innerhalb der Karte gespeichert werden. Floats (`figure`/`table`), `\footnote` und `\marginpar` werden nicht unterstützt; sie können verloren gehen oder mit `Float(s) lost` fehlschlagen. Beliebige LaTeX-Konstrukte und Seiteneffekte sind unter der automatischen Kartenaufteilung nicht garantiert.

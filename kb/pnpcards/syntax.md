# pnpcards – Gewünschte Syntax

← [pnpcards Index](index.md)

## Ziel-Syntax (aus Planung.md)

```latex
% Kurze Karte – passt auf Vorderseite, Rückseite bleibt leer
\begin{card}{Überschrift}[WdZ 102]
Karteninhalt – wenn lang, läuft er automatisch auf die Rückseite über.
\end{card}

% Karte mit explizitem Seitenwechsel
\begin{card}{Überschrift}
Vorderseite
\newpage
Rückseite
\end{card}

% 4-Seiten-Karte (für später)
\begin{doublecard}{Überschrift}
Seite 1
\newpage
Seite 2
\newpage
Seite 3
\newpage
Seite 4
\end{doublecard}
```

## Fehlerfall

- Mehr als 2 Seiten in `card` → Kompilierungsfehler
- Mehr als 4 Seiten in `doublecard` → Kompilierungsfehler

## Aktuell implementiert

```latex
% Kurzform für eine einzeilige Karte
\Card{Titel}{Inhalt}

% Umgebung für mehrzeilige Karten
\begin{card}{Titel}
Karteninhalt
\end{card}
```

`\Card{Titel}{Inhalt}` ist die Kurzform der `card`-Umgebung. Beide Schreibweisen unterstützen natürliche und explizite Seitenumbrüche.

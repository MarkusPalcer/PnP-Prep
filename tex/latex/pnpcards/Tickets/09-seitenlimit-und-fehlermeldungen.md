# Ticket 09: Seitenlimit durchsetzen

## Ziel

Benötigt eine Karte mehr als 2 Seiten — durch natürlichen Überlauf oder durch mehr als ein `\newpage` — schlägt die Kompilierung mit einer verständlichen Fehlermeldung fehl.

## Beobachtbares Verhalten

- Inhalt, der Vorder- und Rückseite vollständig füllt und noch mehr benötigt → Kompilierungsfehler.
- Zwei `\newpage` in einer Karte (= Versuch einer dritten Seite) → Kompilierungsfehler.
- Die Fehlermeldung benennt klar, dass das 2-Seiten-Limit überschritten wurde.
- Inhalt, der genau auf 2 Seiten passt → kompiliert erfolgreich.
- Kein teilweise gerendertes Ergebnis bei einem Fehler.
- Das positive Grenzfall-Fixture kompiliert mit `latexmk -pdf -interaction=nonstopmode -halt-on-error`.

## Fixtures

1. **Positiv**: Inhalt füllt genau Vorder- und Rückseite. `% Expected Output` für beide Seiten. Manuelle Abnahme.
2. **Negativ A**: Natürlicher Überlauf über 2 Seiten hinaus. Erwarteter Fehler im Compile-Log.
3. **Negativ B**: Zwei `\newpage` in einer Karte. Erwarteter Fehler im Compile-Log.

Negative Fixtures werden per `expect_failure` + `requires_log` in `tests.rb` deklariert.

## Nicht Bestandteil

- 4-Seiten-Karten.
- PDF-Seitenumordnung.

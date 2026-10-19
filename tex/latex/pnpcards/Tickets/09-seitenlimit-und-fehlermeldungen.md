# Ticket 09: Seitenlimit durchsetzen und Überlauf verständlich melden

## Ziel

Kompilierung soll mit einer verständlichen Fehlermeldung abbrechen, wenn Karteninhalt eine dritte logische Seite benötigt. Das Limit muss sowohl für natürlichen Überlauf als auch für explizite Seitenwechsel gelten.

## Umsetzung

1. Prüfe nach dem Aufteilen, ob nach der erlaubten Rückseitenfläche noch Inhalt übrig ist.
2. Behandle auch einen weiteren expliziten Seitenwechsel als Versuch, eine dritte Seite zu beginnen.
3. Löse einen LaTeX-Fehler mit einer eindeutigen Meldung aus, die erklärt, dass die Zwei-Seiten-Karte ihr Seitenlimit überschritten hat.
4. Gib bei der Fehlermeldung keine teilweise erfolgreich wirkende Karte aus.
5. Ergänze getrennte negative Fixtures für:
   - natürlichen Inhalt, der über Vorder- und Rückseite hinausgeht;
   - einen expliziten Seitenwechsel zu einer dritten Seite.
6. Stelle bei positiven Grenzfällen sicher, dass Inhalt, der genau in die zwei erlaubten Seiten passt, nicht fälschlich abgelehnt wird.
7. Lege ein positives Fixture für Inhalt an, der genau in die Vorder- und Rückseite passt, und dokumentiere beide Seiten in `% Expected Output`. Halte die zwei negativen Überlauffälle getrennt im selben Ticket fest; sie werden durch den erwarteten Fehler im Compile-Log und nicht durch einen PDF-Vergleich manuell geprüft.

## Abnahmekriterien

- Beide negativen Fälle scheitern mit der erwarteten Seitenlimit-Fehlermeldung; der Benutzer prüft den konkreten Fehler manuell anhand des Compile-Logs.
- Ein Inhalt, der genau auf Vorder- und Rückseite passt, kompiliert erfolgreich.
- Ein zu langer Inhalt wird nicht abgeschnitten oder stillschweigend ignoriert.
- Das positive Grenzfall-Fixture wird mit `pdflatex -interaction=nonstopmode -halt-on-error` gebaut und vom Benutzer manuell anhand von `% Expected Output` abgenommen.

## Nicht Bestandteil

- Implementierung der vierseitigen Karte.
- Druckbogen- oder PDF-Seitenumordnung.

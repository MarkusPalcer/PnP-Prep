# pnp-blueprint: Blueprint Loader Implementierung

## Ziel

Im Paket `pnp-blueprint` soll eine Funktion implementiert werden, die Blueprint-Instanzen aus verschiedenen Bibliotheksquellen lädt.

Die spätere Benutzer-API soll ungefähr so aussehen:

```latex
\begin{blueprint}{gegner}

% erzeugt im globalen Scope:
% \loadgegner{<name>}

\end{blueprint}
```

Beispiel:

```latex
\loadgegner{soldat}
```

soll intern einen Blueprint der Kategorie `gegner` mit dem Namen `soldat` laden.

Die bisher getesteten Suchziele sind:

1. Lokale Kampagne (relativ zur aktuellen `.tex`-Datei)
   - `soldat.gegner`
   - `gegner/soldat.tex`

Später kommen hinzu:

2. Bibliothek über Umgebungsvariable `PNP_LIBRARY`
   - `$PNP_LIBRARY/**/soldat.gegner`
   - `$PNP_LIBRARY/**/gegner/soldat.tex`

3. Installierte LaTeX-Bibliotheken über `kpsewhich`

---

# Aktuelle Namenskonventionen

Das Modul gehört zu `pnp-blueprint`.

Alle Funktionen:

```text
\pnp_blueprint_load_*
```

Beispiele:

```latex
\pnp_blueprint_load:nn
\pnp_blueprint_load_linux:nn
\pnp_blueprint_load_windows:nn
```

Alle Variablen:

```text
\l_pnp_blueprint_load_*
```

Beispiele:

```latex
\l_pnp_blueprint_load_found_file_tl
\l_pnp_blueprint_load_current_dir_tl
```

Argumente:

- `#1` = category (z.B. `gegner`)
- `#2` = name (z.B. `soldat`)

Der Begriff `type` wurde überall durch `category` ersetzt.

---

# Aktueller Implementierungsstand

Die Einstiegsmethode:

```latex
\cs_new_protected:Npn \pnp_blueprint_load:nn #1 #2
{
  \sys_if_platform_windows:TF
  {
    \pnp_blueprint_load_windows:nn {#1}{#2}
  }
  {
    \pnp_blueprint_load_linux:nn {#1}{#2}
  }
}
```

Windows:

```latex
\cs_new_protected:Npn \pnp_blueprint_load_windows:nn #1 #2
{
  \msg_fatal:nn
    { pnp-blueprint }
    { windows-not-supported }
}
```

Linux soll später suchen und laden.

---

# Messages

Aktuelle Messages:

```latex
\msg_new:nnn
  { pnp-blueprint }
  { windows-not-supported }
  {
    Blueprint~loading~is~not~supported~on~Windows~yet.
  }

\msg_new:nnn
  { pnp-blueprint }
  { blueprint-not-found }
  {
    Cannot~load~blueprint~'#2'~of~category~'#1'.
  }

\msg_new:nnn
  { pnp-blueprint }
  { blueprint-loaded }
  {
    Loaded~blueprint~'#2'~of~category~'#1'~from~'#3'.
  }
```

Die Info-Message `blueprint-loaded` soll dauerhaft im Log bleiben, nicht nur Debug sein.

---

# Aktueller Test

Testdatei:

```latex
\documentclass{article}

\usepackage{pnp-blueprint}

\begin{document}

\ExplSyntaxOn
\pnp_blueprint_load:nn {gegner}{soldat}
\ExplSyntaxOff

\end{document}
```

---

# Bisher erfolgreiche Tests

Ein `find` relativ zum aktuellen Verzeichnis hat funktioniert:

Gesucht wurde:

```text
soldat.gegner
gegner/soldat.tex
```

und die Datei wurde gefunden.

---

# Aktueller Status

Der Loader ermittelt das aktuelle Verzeichnis per `pwd` korrekt.
Die Suche verwendet nun `find` zusammen mit `-exec realpath {}` um ein absolutes Ergebnis zu erhalten:

```
find . -type f ( -name soldat.gegner -o -path */gegner/soldat.tex ) -exec realpath {} \; -quit
```

Damit liefert `\l_pnp_blueprint_load_found_file_tl` einen absoluten Pfad und `\input{...}` lädt die Datei. Der Build zeigt im Log:

```
(/workspaces/PnP-Prep/gegner/soldat.tex)
```

Die vorherige Zitierungsproblematik in der Shell-Zeile ist damit umgangen.

---

# Offene Punkte

- Erweiterung auf Suche in `$PNP_LIBRARY` und `kpsewhich` — PNP_LIBRARY fallback implemented (see below); kpsewhich remains open.

---

# PNP_LIBRARY Fallback (neu)

Wenn lokal nichts gefunden wird, versucht der Loader jetzt, in der Umgebungsvariable $PNP_LIBRARY zu suchen:

- Führt: find $PNP_LIBRARY -type f ( -name <name>.<category> -o -path */<category>/<name>.tex ) -exec realpath {} \; -quit
- Liefert absolute Pfade (realpath). Beispiel-Log: (/root/soldat.gegner)

Hinweis: Der aktuelle Aufruf verwendet $PNP_LIBRARY unquoted; Pfade mit Leerzeichen können Probleme verursachen. kpsewhich-Integration folgt später.

---

---

# Erwartetes Verhalten

Bei:

```latex
\pnp_blueprint_load:nn {gegner}{soldat}
```

soll im Log erscheinen:

```
Current directory: /workspaces/PnP-Prep

Loaded blueprint 'soldat' of category 'gegner' from '/workspaces/PnP-Prep/gegner/soldat.tex'.
```

oder:

```
Cannot load blueprint 'soldat' of category 'gegner'.
```

---

# Technische Hinweise

- Das Paket verwendet `expl3`.
- Shell-Kommandos werden über `\sys_get_shell:nnN` ausgeführt.
- Shell-Escape ist aktiviert.
- Die Umgebung ist Linux im Devcontainer.
- Ziel ist zunächst nur der lokale Suchpfad.
- Die Erweiterung auf `PNP_LIBRARY` und `kpsewhich` kommt später.
#!/bin/sh
# findlib.sh
# Search order:
# 1) current working directory: ./name.category or ./category/name.tex
# 2) paths in $PNP_LIBRARY (colon-separated entries allowed)
# 3) kpsewhich (search TeX trees)
# Prints the absolute path of the first match to stdout, nothing otherwise.

category="$1"
name="$2"

# helper: print and exit
print_and_exit() {
  # print path to stdout
  printf '%s\n' "$1"
  exit 0
}

# 1) check in current directory explicitly
if [ -f "./${name}.${category}" ]; then
  print_and_exit "$(realpath "./${name}.${category}")"
fi
if [ -f "./${category}/${name}.tex" ]; then
  print_and_exit "$(realpath "./${category}/${name}.tex")"
fi

# 2) search PNP_LIBRARY if set (allow colon-separated list)
if [ -n "$PNP_LIBRARY" ]; then
  # iterate entries split by ':' without losing spaces
  OLDIFS="$IFS"
  IFS=:
  for entry in $PNP_LIBRARY; do
    IFS="$OLDIFS"
    # skip empty
    [ -z "$entry" ] && continue
    # use find to locate first match under this entry
    found=$(find "$entry" -type f \( -name "${name}.${category}" -o -path "*/${category}/${name}.tex" \) -exec realpath {} \; -quit 2>/dev/null)
    if [ -n "$found" ]; then
      # copy to no-space temp and print that path
      ext="${found##*.}"
      tmp="$(mktemp /tmp/pnpprep.XXXXXX).$ext"
      cp -- "$found" "$tmp"
      print_and_exit "$tmp"
    fi
    IFS=:
  done
  IFS="$OLDIFS"
fi

# 3) fallback to kpsewhich. Try the two candidate filenames.
# Respect TEXMFHOME/TEXINPUTS set by caller; kpsewhich will use env vars.
kpsewhich_path=""
# try name.category
kpsewhich_path=$(kpsewhich "${name}.${category}" 2>/dev/null || true)
if [ -n "$kpsewhich_path" ]; then
  ext="${kpsewhich_path##*.}"
  tmp="$(mktemp /tmp/pnpprep.XXXXXX).$ext"
  cp -- "$kpsewhich_path" "$tmp" 2>/dev/null || true
  print_and_exit "$tmp"
fi
# try category/name.tex
kpsewhich_path=$(kpsewhich "${category}/${name}.tex" 2>/dev/null || true)
if [ -n "$kpsewhich_path" ]; then
  ext="${kpsewhich_path##*.}"
  tmp="$(mktemp /tmp/pnpprep.XXXXXX).$ext"
  cp -- "$kpsewhich_path" "$tmp" 2>/dev/null || true
  print_and_exit "$tmp"
fi

# nothing found -> exit silently
exit 0

#!/usr/bin/env bash
set -euo pipefail

[[ $# -eq 1 ]] || { echo "Usage: $0 path/to/file.d2"; exit 1; }
file="$1"

# Prefer xdg-open on Linux; open on macOS; otherwise disable auto-open.
if command -v xdg-open >/dev/null 2>&1; then
  BROWSER=xdg-open d2 --watch "$file"
elif command -v open >/dev/null 2>&1; then
  BROWSER=open d2 --watch "$file"
else
  BROWSER=0 d2 --watch "$file"
  echo "Browser auto-open disabled; use the printed URL" >&2
fi

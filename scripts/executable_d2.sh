#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 [-p PORT] [-o OUT.svg] path/to/file.d2" >&2
  exit 1
}

port=""
out=""
while getopts ":p:o:h" opt; do
  case "$opt" in
    p) port="$OPTARG" ;;
    o) out="$OPTARG"  ;;
    h) usage          ;;
    \?) usage         ;;
  esac
done
shift $((OPTIND-1))
[[ $# -eq 1 ]] || usage

in="$1"
[[ -f "$in" ]] || { echo "No such file: $in" >&2; exit 1; }

# Derive output path if not given
if [[ -z "$out" ]]; then
  base="${in%.*}"
  out="${base}.svg"
fi

host="127.0.0.1"
: "${port:=8080}"  # default preferred port

# Clean up D2 on exit
kill_d2() {
  if [[ -n "${d2_pid:-}" ]] && kill -0 "$d2_pid" 2>/dev/null; then
    kill "$d2_pid" 2>/dev/null || true
    wait "$d2_pid" 2>/dev/null || true
  fi
}
trap kill_d2 EXIT

# Try to start D2 watch on an available port
max_tries=10
try=1
while (( try <= max_tries )); do
  # Prevent D2 from auto-opening a browser; the script will open it
  set +e
  BROWSER=none d2 --watch --host "$host" --port "$port" "$in" "$out" --browser=false > "/tmp/d2watch_$$.log" 2>&1 &
  d2_pid=$!
  set -e

  # If it died immediately (likely port in use), try next port
  sleep 0.3
  if ! kill -0 "$d2_pid" 2>/dev/null; then
    port=$((port + 1))
    try=$((try + 1))
    continue
  fi
  break
done

if ! kill -0 "$d2_pid" 2>/dev/null; then
  echo "Failed to start d2 watch after $max_tries attempts" >&2
  exit 1
fi

# Wait for server readiness
url="http://${host}:${port}/"
for _ in {1..50}; do
  if curl -fsS "$url" >/dev/null 2>&1; then
    break
  fi
  sleep 0.1
done

echo "D2 watch running at: $url (serving $out)"

# Open in a browser (Linux/macOS/WSL)
if command -v xdg-open >/dev/null 2>&1; then
  xdg-open "$url" >/dev/null 2>&1
elif command -v wslview >/dev/null 2>&1; then
  wslview "$url" >/dev/null 2>&1
elif command -v open >/dev/null 2>&1; then
  open "$url" >/dev/null 2>&1
else
  echo "Please open $url manually"
fi

# Keep the script attached until D2 exits (Ctrl-C to stop)
wait "$d2_pid"

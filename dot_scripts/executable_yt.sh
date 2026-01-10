#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=true

usage() {
  cat <<EOF
Usage: $(basename "$0") [-n] file1.mp4 [file2.mp4 ...]

Options:
  -n    Execute (no dry-run). Without this flag, commands are only printed.
EOF
}

# Parse options
while getopts ":n" opt; do
  case "$opt" in
    n) DRY_RUN=false ;;
    *) usage; exit 1 ;;
  esac
done
shift $((OPTIND - 1))

# Require at least one file
if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

run() {
  if [[ "$DRY_RUN" == true ]]; then
    echo "[DRY-RUN] $*"
  else
    "$@"
  fi
}

for input in "$@"; do
  if [[ ! -f "$input" ]]; then
    echo "Skipping '$input' (not a file)"
    continue
  fi

  output="${input%.*}_f.mp4"
  tmp="$(mktemp --suffix=.mp4)"

  echo "Processing: $input → $output"

  run ffmpeg -i "$input" -c copy -movflags +faststart "$tmp"

  if [[ "$DRY_RUN" == false ]]; then
    mv -f "$tmp" "$output"
    rm "$input"
  else
    rm -f "$tmp"
  fi

done

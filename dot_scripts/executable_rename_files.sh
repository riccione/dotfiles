#!/usr/bin/env bash

set -euo pipefail
shopt -s nullglob

# ==========================
# Configuration
# ==========================
MAX_LEN=50   # Default: 50
DRY_RUN=true # true = preview only, false = actually rename

# ==========================
# Help
# ==========================
usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Rename files in the current directory:
  - Replace spaces with underscores (_)
  - Truncate filenames to a maximum length
  - Preserve file extensions
  - Avoid overwriting by adding random suffix
  - Skip directories

OPTIONS:
  -l, --length N     Maximum filename length (default: 80)
  -n, --no-dry-run   Actually rename files (default is preview only)
  -h, --help         Show this help message and exit

EXAMPLES:
  Preview changes (default):
    ./rename_files.sh

  Rename files, max 50 characters:
    ./rename_files.sh --length 50 --no-dry-run

  Short form:
    ./rename_files.sh -l 60 -n
EOF
}

# ==========================
# Argument parsing
# ==========================
while [[ $# -gt 0 ]]; do
  case "$1" in
    -l|--length)
      MAX_LEN="$2"
      shift 2
      ;;
    -n|--no-dry-run)
      DRY_RUN=false
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo
      usage
      exit 1
      ;;
  esac
done

# ==========================
# Script
# ==========================
for f in *; do
  [[ -d "$f" ]] && continue

  # Split name and extension
  base="${f%.*}"
  ext="${f##*.}"

  if [[ "$base" == "$ext" ]]; then
    ext=""
  else
    ext=".$ext"
  fi

  # Normalize name
  base_clean="${base// /_}"

  # Truncate base so full name <= MAX_LEN
  max_base_len=$((MAX_LEN - ${#ext}))
  base_trunc="${base_clean:0:max_base_len}"

  new="${base_trunc}${ext}"

  # Handle collisions
  while [[ -e "$new" && "$new" != "$f" ]]; do
    rand=$RANDOM
    suffix="_$rand"
    base_trunc="${base_clean:0:$((max_base_len - ${#suffix}))}"
    new="${base_trunc}${suffix}${ext}"
  done

  [[ "$f" == "$new" ]] && continue

  if $DRY_RUN; then
    echo "PREVIEW: $f  ->  $new"
  else
    mv -- "$f" "$new"
  fi
done

echo "Done."

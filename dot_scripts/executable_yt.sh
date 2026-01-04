#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: ffstart input.mp4 [output.mp4]"
  exit 1
fi

input="$1"
output="${2:-${input%.*}_f.mp4}"

ffmpeg -i "$input" -c copy -movflags +faststart "$output"

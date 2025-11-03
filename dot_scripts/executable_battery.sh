#!/usr/bin/env bash
# Show battery info using upower for all detected batteries

# List all battery devices
batteries=$(upower -e | grep battery)

if [[ -z "$batteries" ]]; then
    echo "No battery devices found."
    exit 1
fi

for bat in $batteries; do
    name=$(basename "$bat")
    echo "=== $name ==="
    upower -i "$bat" | awk -F: '/state|to full|to empty|percentage/ {gsub(/^[ \t]+/, "", $2); print $1 ": " $2}'
    echo
done

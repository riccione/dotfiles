#!/bin/bash

# Check if interval was provided
if [ -z "$1" ]; then
    echo "Error: Please provide time interval in minutes"
    echo "Usage: $0 <minutes>"
    echo "Example: $0 20"
    exit 1
fi

# Validate interval is a number
if ! [[ "$1" =~ ^[0-9]+$ ]]; then
    echo "Error: '$1' is not a valid number"
    exit 1
fi

INTERVAL=$1
SECONDS=$((INTERVAL * 60))

# Function to play audio
play_audio() {
    echo -e "\a" 2>/dev/null
    if command -v speaker-test &>/dev/null; then
        speaker-test -t sine -f 1000 -l 1 &>/dev/null &
    fi
}

echo "Timer started - Alert every ${INTERVAL} minutes"
echo "Press Ctrl+C to stop"
echo ""

COUNT=1

while true; do
    # Countdown from INTERVAL to 1 minute
    for (( mins_left = INTERVAL; mins_left > 0; mins_left-- )); do
        printf "\rNext alert in: %d minute(s)" $mins_left
        sleep 60
    done
    
    # Clear the line
    printf "\r%*s\r" 50 ""
    
    # Plain text output
    echo "[$(date '+%H:%M:%S')] Alert #${COUNT}: ${INTERVAL} minutes have passed"
    
    # Desktop notification
    notify-send -u critical "Timer" "Alert #${COUNT}: ${INTERVAL} minutes have passed"
    
    # Audio alert
    play_audio
    
    ((COUNT++))
done

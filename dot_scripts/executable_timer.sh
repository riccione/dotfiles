#!/bin/bash

# Check if interval was provided
if [ -z "$1" ]; then
    echo "Error: Please provide time interval in minutes"
    echo "Usage: $0 <minutes> [mp3-file]"
    echo "Example: $0 20"
    echo "Example with MP3: $0 20 /path/to/alert.mp3"
    exit 1
fi

# Validate interval is a number
if ! [[ "$1" =~ ^[0-9]+$ ]]; then
    echo "Error: '$1' is not a valid number"
    exit 1
fi

INTERVAL=$1
SECONDS=$((INTERVAL * 60))
MP3_FILE="$2"

# Function to play audio
play_audio() {
    # If MP3 file is provided and exists, play it
    if [ -n "$MP3_FILE" ] && [ -f "$MP3_FILE" ]; then
        # Try different players (in order of preference)
        if command -v mpv &>/dev/null; then
            mpv --no-video --really-quiet "$MP3_FILE" &
        elif command -v mpg123 &>/dev/null; then
            mpg123 -q "$MP3_FILE" &
        elif command -v aplay &>/dev/null; then
            # aplay can only play WAV, but try anyway
            aplay "$MP3_FILE" 2>/dev/null &
        elif command -v ffplay &>/dev/null; then
            ffplay -nodisp -autoexit -loglevel quiet "$MP3_FILE" &
        else
            echo "Warning: No MP3 player found. Install mpv, mpg123, or ffplay"
            # Fall back to system sound
            system_sound
        fi
    else
        # Fall back to system sound
        if [ -n "$MP3_FILE" ] && [ ! -f "$MP3_FILE" ]; then
            echo "Warning: MP3 file '$MP3_FILE' not found. Using system sound."
        fi
        system_sound
    fi
}

# Original system sound function
system_sound() {
    echo -e "\a" 2>/dev/null
    if command -v speaker-test &>/dev/null; then
        speaker-test -t sine -f 1000 -l 1 &>/dev/null &
    fi
}

echo "Timer started - Alert every ${INTERVAL} minutes"
if [ -n "$MP3_FILE" ] && [ -f "$MP3_FILE" ]; then
    echo "Using MP3: $MP3_FILE"
else
    echo "Using system sound"
fi
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

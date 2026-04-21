#!/bin/bash

# Check if interval was provided
if [ -z "$1" ]; then
    echo "Error: Please provide time interval in minutes"
    echo "Usage: $0 <minutes> [mp3-file-or-directory]"
    echo "Example: $0 20"
    echo "Example with MP3: $0 20 /path/to/alert.mp3"
    echo "Example with directory: $0 20 /path/to/music/directory"
    exit 1
fi

# Validate interval is a number
if ! [[ "$1" =~ ^[0-9]+$ ]]; then
    echo "Error: '$1' is not a valid number"
    exit 1
fi

INTERVAL=$1
SECONDS=$((INTERVAL * 60))
AUDIO_PATH="$2"

# Function to get a random MP3 from directory
get_random_mp3() {
    local dir="$1"
    
    # Find all mp3 files (case insensitive)
    mapfile -t mp3_files < <(find "$dir" -type f \( -iname "*.mp3" -o -iname "*.MP3" \) 2>/dev/null)
    
    if [ ${#mp3_files[@]} -eq 0 ]; then
        echo ""
        return 1
    fi
    
    # Pick random file
    local random_index=$((RANDOM % ${#mp3_files[@]}))
    echo "${mp3_files[$random_index]}"
}

# Function to play audio
play_audio() {
    # No audio path provided - use system sound
    if [ -z "$AUDIO_PATH" ]; then
        system_sound
        return
    fi
    
    # Check if path is a directory
    if [ -d "$AUDIO_PATH" ]; then
        local random_mp3=$(get_random_mp3 "$AUDIO_PATH")
        
        if [ -n "$random_mp3" ]; then
            # Play random MP3 from directory
            play_mp3 "$random_mp3"
        else
            echo "Warning: No MP3 files found in directory '$AUDIO_PATH'"
            system_sound
        fi
    # Check if path is a file
    elif [ -f "$AUDIO_PATH" ]; then
        # Play specific MP3 file
        play_mp3 "$AUDIO_PATH"
    else
        echo "Warning: '$AUDIO_PATH' is not a valid file or directory"
        system_sound
    fi
}

# Function to play MP3 file
play_mp3() {
    local mp3_file="$1"
    
    # Try different players (in order of preference)
    if command -v mpv &>/dev/null; then
        mpv --no-video --really-quiet "$mp3_file" &
    elif command -v mpg123 &>/dev/null; then
        mpg123 -q "$mp3_file" &
    elif command -v ffplay &>/dev/null; then
        ffplay -nodisp -autoexit -loglevel quiet "$mp3_file" &
    else
        echo "Warning: No MP3 player found. Install mpv, mpg123, or ffplay"
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

# Display audio source information
if [ -z "$AUDIO_PATH" ]; then
    echo "Audio: System beep"
elif [ -d "$AUDIO_PATH" ]; then
    mp3_count=$(find "$AUDIO_PATH" -type f -iname "*.mp3" 2>/dev/null | wc -l)
    echo "Audio: Random MP3 from directory '$AUDIO_PATH' ($mp3_count files)"
elif [ -f "$AUDIO_PATH" ]; then
    echo "Audio: MP3 file '$(basename "$AUDIO_PATH")'"
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
    
    # If using directory, show which file was selected
    if [ -d "$AUDIO_PATH" ]; then
        random_mp3=$(get_random_mp3 "$AUDIO_PATH")
        if [ -n "$random_mp3" ]; then
            echo "  Playing: $(basename "$random_mp3")"
        fi
    fi
    
    # Audio alert
    play_audio
    
    ((COUNT++))
done

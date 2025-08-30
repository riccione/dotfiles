#!/bin/bash

LLAMA_DIR=~/bin/llama.cpp/build/bin
MODEL_DIR=~/Documents/llm/models

# Collect all .gguf files
models=("$MODEL_DIR"/*.gguf)

# Check if models exist
if [ ${#models[@]} -eq 0 ]; then
    echo "No .gguf models found in $MODEL_DIR"
    exit 1
fi

show_help() {
    echo "Usage: $(basename "$0") [extra llama-server args]"
    echo
    echo "This script will let you pick a .gguf model from:"
    echo "  $MODEL_DIR"
    echo
    echo "Options inside menu:"
    echo "  [number] - select and run the chosen model"
    echo "  h        - show this help message"
    echo "  q        - quit"
    echo
}

while true; do
    echo "Available models:"
    i=1
    for m in "${models[@]}"; do
        echo "  $i) $(basename "$m")"
        ((i++))
    done
    echo "  h) help"
    echo "  q) quit"
    echo

    read -rp "Select a model (number, h for help, q to quit): " choice

    case "$choice" in
        q|Q)
            echo "Exiting."
            exit 0
            ;;
        h|H)
            show_help
            ;;
        ''|*[!0-9]*)
            echo "Invalid input. Please enter a number, h, or q."
            ;;
        *)
            if [ "$choice" -ge 1 ] && [ "$choice" -le ${#models[@]} ]; then
                model="${models[$((choice-1))]}"
                echo "Running with model: $model"
                export LD_LIBRARY_PATH="$LLAMA_DIR:$LD_LIBRARY_PATH"
                exec "$LLAMA_DIR/llama-server" -m "$model" "$@"
            else
                echo "Invalid number: $choice"
            fi
            ;;
    esac
done

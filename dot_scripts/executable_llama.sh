#!/bin/bash
LLAMA_DIR=~/bin/llama.cpp/build/bin
LD_LIBRARY_PATH=$LLAMA_DIR $LLAMA_DIR/llama-server "$@"
export LD_LIBRARY_PATH="$LLAMA_DIR:$LD_LIBRARY_PATH"
"$LLAMA_DIR/llama-server" -m ~/Documents/llm/models/Qwen2.5.1-Coder-7B-Instruct-Q8_0.gguf

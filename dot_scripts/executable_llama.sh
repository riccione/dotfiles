#!/bin/bash
LLAMA_DIR=~/bin/llama.cpp
LD_LIBRARY_PATH=$LLAMA_DIR $LLAMA_DIR/llama-server "$@"

#!/bin/bash

# Usage: ./secure_download.sh <encrypted_file.age> <private_key_file> <output_dir>

set -e

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS] <encrypted_file.age> <private_key_file> <output_dir>

Decrypt an age-encrypted archive, verify hashes, and extract contents.

Arguments:
  encrypted_file.age   Encrypted archive produced by secure-archive script
  private_key_file     age private key file
  output_dir           Directory to extract files into

Options:
  -h                   Show this help message and exit

Examples:
  $(basename "$0") archive.tar.gz.age key.txt out/
  $(basename "$0") secrets.age ~/.config/age/key.txt ./output

EOF
}

ENCRYPTED_FILE="$1"
PRIVATE_KEY="$2"
OUTPUT_DIR="$3"

if [[ -z "$ENCRYPTED_FILE" || -z "$PRIVATE_KEY" || -z "$OUTPUT_DIR" ]]; then
    echo "[!] Missing required arguments"
    usage
    exit 1
fi

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

# Determine base name and archive name
BASENAME=$(basename "$ENCRYPTED_FILE" .tar.gz.age)
HASH_FILE="${BASENAME}_hashes.txt"
DECRYPTED_ARCHIVE="$OUTPUT_DIR/${BASENAME}.tar.gz"

echo "[*] Decrypting $ENCRYPTED_FILE..."
age -d -i "$PRIVATE_KEY" "$ENCRYPTED_FILE" > "$DECRYPTED_ARCHIVE"

# Optional: verify hash if hash file exists
HASH_FILE="$(dirname "$ENCRYPTED_FILE")/${BASENAME}_hashes.txt"
if [[ -f "$HASH_FILE" ]]; then
    echo "[*] Verifying hash of decrypted archive..."
    # Assuming the first line in hashes file is the original archive hash
    sha256sum -c --status <<< "$(head -n1 "$HASH_FILE")"
    if [[ $? -eq 0 ]]; then
        echo "    Archive hash OK"
    else
        echo "    Archive hash FAILED"
        exit 1
    fi
else
    echo "[!] No hash file found, skipping hash verification."
fi

echo "[*] Extracting archive..."
tar -xzf "$DECRYPTED_ARCHIVE" -C "$OUTPUT_DIR"

sha256sum -c $HASH_FILE

echo "[*] Done! Extracted contents to $OUTPUT_DIR"

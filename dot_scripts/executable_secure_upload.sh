#!/bin/bash

# Usage: ./secure_upload.sh <input_path> <recipient_public_key_file> <output_dir>

set -e

INPUT_PATH="$1"
PUBLIC_KEY_FILE="$2"
OUTPUT_DIR="$3"

if [[ -z "$INPUT_PATH" || -z "$PUBLIC_KEY_FILE" || -z "$OUTPUT_DIR" ]]; then
    echo "Usage: $0 <input_path> <recipient_public_key_file> <output_dir>"
    exit 1
fi

# Ensure the public key file exists
if [[ ! -f "$PUBLIC_KEY_FILE" ]]; then
    echo "[!] Public key file not found: $PUBLIC_KEY_FILE"
    exit 1
fi

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

# Determine base name
BASENAME=$(basename "$INPUT_PATH")
ARCHIVE_NAME="$OUTPUT_DIR/${BASENAME}.tar.gz"
ENCRYPTED_NAME="$ARCHIVE_NAME.age"
HASH_FILE="$OUTPUT_DIR/${BASENAME}_hashes.txt"

echo "[*] Archiving and compressing $INPUT_PATH..."
tar -czf "$ARCHIVE_NAME" "$INPUT_PATH"

echo "[*] Calculating hash of archive..."
sha256sum "$ARCHIVE_NAME" > "$HASH_FILE"

echo "[*] Encrypting archive with age using public key file..."
age -o "$ENCRYPTED_NAME" -r "$(cat "$PUBLIC_KEY_FILE")" "$ARCHIVE_NAME"

echo "[*] Calculating hash of encrypted file..."
sha256sum "$ENCRYPTED_NAME" >> "$HASH_FILE"

echo "[*] Secure archive created:"
echo "    Archive: $ARCHIVE_NAME"
echo "    Encrypted: $ENCRYPTED_NAME"
echo "    Hashes: $HASH_FILE"

# Optionally remove unencrypted archive
# shred -u "$ARCHIVE_NAME"

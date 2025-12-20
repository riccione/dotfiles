#!/bin/bash

# Usage: ./secure_upload.sh <input_path> <recipient_public_key_file> <output_dir>

set -e

usage() {
        cat <<EOF
Usage: $(basename "$0") [OPTIONS] <input_path> <recipient_public_key_file> <output_dir>

Securely archive and encrypt files using age.

Arguments:
  input_path                 File or directory to archive
  recipient_public_key_file  age recipient public key file
  output_dir                 Directory for output files

Options:
  -r                          Randomize output filenames (hide sensitive names)
  -h                          Show this help message and exit

Examples:
  $(basename "$0") data/ key.pub out/
  $(basename "$0") -r secrets/ key.pub out/

EOF
}

RANDOM_NAME=false
# Parse flags
while getopts ":r" opt; do
  case $opt in
    r)
      RANDOM_NAME=true
      ;;
    *)
      echo "Usage: $0 [-r] <input_path> <recipient_public_key_file> <output_dir>"
      exit 1
      ;;
  esac
done
shift $((OPTIND - 1))

INPUT_PATH="$1"
PUBLIC_KEY_FILE="$2"
OUTPUT_DIR="$3"

if [[ -z "$INPUT_PATH" || -z "$PUBLIC_KEY_FILE" || -z "$OUTPUT_DIR" ]]; then
    echo "[!] Missing requred arguments"
    usage
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
if $RANDOM_NAME; then
    BASENAME="$(openssl rand -hex 16)"
else
    BASENAME="$(basename "$INPUT_PATH")"
fi

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

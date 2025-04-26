#!/bin/bash
set -e

# ----------------------------------------
# Link .sh scripts to ~/.local/bin
# ----------------------------------------

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_DIR="$HOME/.local/bin"

echo "[*] Linking all .sh scripts from $SCRIPT_DIR to $TARGET_DIR (without extension)..."

# ディレクトリが存在するか確認
if [ ! -d "$SCRIPT_DIR" ]; then
  echo "[!] Error: $SCRIPT_DIR does not exist."
  exit 1
fi

mkdir -p "$TARGET_DIR"

# .sh ファイルを再帰的に探してリンク
find "$SCRIPT_DIR" -type f -name "*.sh" | while read -r filepath; do
  filename=$(basename "$filepath" .sh)
  linkpath="$TARGET_DIR/$filename"
  ln -sf "$filepath" "$linkpath"
  echo "[*] Linked $filename"
done

echo "[*] Script linking completed."

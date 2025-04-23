#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_DIR="$HOME/.local/bin"

echo "$SCRIPT_DIR 以下の .sh スクリプトを $TARGET_DIR にリンクします（拡張子なし）..."

# ディレクトリが存在するか確認
if [ ! -d "$SCRIPT_DIR" ]; then
  echo "エラー: $SCRIPT_DIR が存在しません。"
  exit 1
fi

mkdir -p "$TARGET_DIR"

# .sh ファイルを再帰的に探してリンク
find "$SCRIPT_DIR" -type f -name "*.sh" | while read -r filepath; do
  filename=$(basename "$filepath" .sh)  # 拡張子を除く
  linkpath="$TARGET_DIR/$filename"
  ln -sf "$filepath" "$linkpath"
  echo "$filename をリンクしました"
done

echo "リンク作成が完了しました。"

# ~/.bash_exports に PATH 追加 (なければ)
EXPORT_LINE='export PATH="$HOME/.local/bin:$PATH"'
EXPORT_FILE="$HOME/.bash_exports"

if [ ! -f "$EXPORT_FILE" ]; then
  touch "$EXPORT_FILE"
fi

if ! grep -Fxq "$EXPORT_LINE" "$EXPORT_FILE"; then
  echo "$EXPORT_LINE" >> "$EXPORT_FILE"
  echo ".bash_exports に PATH を追加しました。"
else
  echo ".bash_exports にはすでに PATH が追加されています。"
fi

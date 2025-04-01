#!/bin/bash

set -e  # エラーがあったら止める

echo "📦 Installing dotfiles..."

# dotfiles ディレクトリの場所（このスクリプトがある場所を基準に）
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 対象ファイル
FILES=(
  .bashrc
  .gitconfig
  .profile
)

# シンボリックリンク作成
for file in "${FILES[@]}"; do
  target="$HOME/$file"
  source="$DOTFILES_DIR/$file"

  # すでにある場合はバックアップ
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    echo "🔁 Backing up existing $file to $file.backup"
    mv "$target" "$target.backup"
  fi

  echo "🔗 Linking $file"
  ln -sf "$source" "$target"
done

echo "✅ Dotfiles installation complete!"

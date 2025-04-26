#!/bin/bash
set -e

# ----------------------------------------
# install.sh
# dotfiles環境セットアップ用
# ----------------------------------------

echo
echo "[*] Starting dotfiles installation..."
echo

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 必要なパッケージをインストール
echo "[*] Running setup_apt.sh..."
bash "$DOTFILES_DIR/install/setup_apt.sh"

# dotfilesをリンクする関数
link_dotfile() {
  local src="$DOTFILES_DIR/$1"
  local dest="$HOME/$1"

  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    mv "$dest" "$dest.backup"
    echo "[!] Found existing $1. Backed up to $1.backup"
  fi

  ln -sf "$src" "$dest"
  echo "[*] Linked $1"
}

# 必要なファイルだけリンクする
link_dotfile .bashrc
link_dotfile .profile
link_dotfile .gitconfig

# 完了メッセージ
echo
echo "[*] Dotfiles linking completed."
echo "[*] Please run 'source ~/.bashrc' to apply the new settings."
echo

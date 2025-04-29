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

# ----------------------------------------
# Git user.name / user.email 確認
# ----------------------------------------

echo "[*] Checking Git user information..."

expected_name="YOSHIHIDEShimoji"
expected_email="g.y.shimoji@gmail.com"

echo "[*] Expected Git user.name: $expected_name"
echo "[*] Expected Git user.email: $expected_email"

read -p "[?] Is your Git user.name and user.email correct? (y/n): " confirm

if [ "$confirm" != "y" ]; then
  echo "[!] Please manually update your Git configuration after installation."
else
  echo "[*] Git user information confirmed. Continuing..."
fi

# ----------------------------------------
# 必要パッケージをインストール
# ----------------------------------------

echo
echo "[*] Running setup_apt.sh..."
bash "$DOTFILES_DIR/install/setup_apt.sh"

# ----------------------------------------
# dotfilesリンク作成
# ----------------------------------------

link_dotfile() {
  local src="$DOTFILES_DIR/$1"
  local dest="$HOME/$1"

  if [ ! -e "$src" ]; then
    echo "[!] Warning: source file $src not found. Skipping."
    return
  fi

  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    mv "$dest" "$dest.backup"
    echo "[!] Found existing $1. Backed up to $1.backup"
  fi

  ln -sf "$src" "$dest"
  echo "[*] Linked $1"
}

link_dotfile .bashrc
link_dotfile .profile
link_dotfile .gitconfig

# ----------------------------------------
# 完了メッセージ
# ----------------------------------------

echo
echo "[*] Dotfiles linking completed."
echo "[*] Please run 'source ~/.bashrc' to apply the new settings."
echo

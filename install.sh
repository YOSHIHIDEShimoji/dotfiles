#!/bin/bash
set -e

# ----------------------------------------
# install.sh 完全版
# dotfiles環境セットアップ用
# ----------------------------------------

echo
echo "[*] Starting dotfiles installation..."
echo

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ----------------------------------------
# Git user.name / user.email チェック
# ----------------------------------------

current_name=$(git config user.name || echo "not set")
current_email=$(git config user.email || echo "not set")

echo "[*] Detected Git user.name: $current_name"
echo "[*] Detected Git user.email: $current_email"

read -p "[?] Is this information correct for this machine? (y/n): " confirm

if [ "$confirm" != "y" ]; then
  read -p "[?] Enter your correct Git user.name: " new_name
  read -p "[?] Enter your correct Git user.email: " new_email

  cat > "$DOTFILES_DIR/gitconfig/user" << EOF
[user]
  name = $new_name
  email = $new_email
EOF

  echo "[*] Updated dotfiles/gitconfig/user with new information."
else
  echo "[*] Git user information confirmed. Continuing..."
fi

# ----------------------------------------
# 必要パッケージをインストール
# ----------------------------------------

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

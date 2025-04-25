#!/bin/bash
set -e

#----------------------------------------
# Main setup script for dotfiles
#----------------------------------------

echo
echo "[*] Starting dotfiles installation..."
echo

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Run setup_apt.sh first to install required packages (including gh)
bash "$DOTFILES_DIR/install/setup_apt.sh"

# Check if GitHub CLI (gh) is installed after setup_apt.sh
echo "[*] Checking if GitHub CLI (gh) is installed..."
if ! command -v gh >/dev/null 2>&1; then
  echo "[!] GitHub CLI (gh) is not installed. Please check the installation."
  exit 1
else
  echo "[*] GitHub CLI (gh) is installed."
fi

# Backup existing dotfiles and link new ones
link_dotfile() {
  local src="$DOTFILES_DIR/$1"
  local dest="$HOME/$1"

  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    echo "[!] Backing up existing $1 to $1.backup"
    mv "$dest" "$dest.backup"
  fi

  ln -sf "$src" "$dest"
  echo "[*] Linked $1"
}

link_dotfile .bashrc
link_dotfile .profile
link_dotfile .gitconfig

# Run setup scripts for SSH and GitHub configuration
bash "$DOTFILES_DIR/install/setup_ssh.sh"
bash "$DOTFILES_DIR/install/setup_gh.sh"

echo
echo "[*] All setup tasks completed. Please run 'source ~/.bashrc' to apply changes."
echo


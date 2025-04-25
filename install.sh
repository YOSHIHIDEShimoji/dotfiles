#!/bin/bash
set -e

echo
echo "[*] Starting dotfiles installation..."
echo

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

echo
echo "[*] Dotfiles linking complete. Run 'source ~/.bashrc' to apply changes."
echo

# Optional: clean up backups and extracted directory
echo
read -p "[?] Do you want to delete backup files and the extracted directory (if applicable)? (y/n): " confirm
if [ "$confirm" = "y" ]; then
  rm -f ~/.bashrc.backup ~/.profile.backup ~/.gitconfig.backup && echo "[*] Backup files removed."

  TAR_PARENT=$(basename "$(pwd)")
  if [[ "$TAR_PARENT" == dotfiles-* ]]; then
    cd .. && rm -rf "$TAR_PARENT"
    echo "[*] Extracted directory '$TAR_PARENT' removed."
  fi
else
  echo "[*] Backup files and extracted directory kept."
fi

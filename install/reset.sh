#!/bin/bash
set -e

#----------------------------------------
# Reset: Clean environment safely
#----------------------------------------

# If running from dotfiles/install/reset.sh, copy to a safe location first
if [[ "$(dirname "$0")" == *dotfiles/install* ]]; then
  echo "[*] Copying reset script to temporary location..."
  tmpfile=$(mktemp)
  cp "$0" "$tmpfile"
  echo "[*] Re-running from temporary location..."
  bash "$tmpfile"
  exit
fi

echo "[*] Resetting environment..."

cd "$HOME"

# Remove dotfiles-related directories and files
[ -d dotfiles ] && rm -rf dotfiles
[ -f dotfiles.tar.gz ] && rm -f dotfiles.tar.gz
[ -d .ssh ] && rm -rf .ssh
[ -f .bashrc ] && rm -f .bashrc
[ -f .profile ] && rm -f .profile
[ -f .gitconfig ] && rm -f .gitconfig

# Restore backups if they exist
[ -f .bashrc.backup ] && mv .bashrc.backup .bashrc
[ -f .profile.backup ] && mv .profile.backup .profile
[ -f .gitconfig.backup ] && mv .gitconfig.backup .gitconfig

echo "[*] Environment has been reset."

# Optionally return to previous directory
cd -


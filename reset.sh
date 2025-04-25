#!/bin/bash
set -e

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

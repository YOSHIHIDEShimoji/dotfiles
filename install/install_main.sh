#!/bin/bash
set -e

echo "Starting full dotfiles installation..."

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo
echo "=============================================="
echo ">>> Running install_git.sh"
echo "=============================================="
bash "$SCRIPT_DIR/install_git.sh"

echo
echo "=============================================="
echo ">>> Running install_functions.sh"
echo "=============================================="
bash "$SCRIPT_DIR/install_functions.sh"

echo
echo "=============================================="
echo ">>> Running install_exports.sh"
echo "=============================================="
bash "$SCRIPT_DIR/install_exports.sh"

echo
echo "=============================================="
echo ">>> Running install_aliases.sh"
echo "=============================================="
bash "$SCRIPT_DIR/install_aliases.sh"

echo
echo "=============================================="
echo "Dotfiles installation complete!"
echo "Please run the following command to apply changes:"
echo
echo "    source ~/.bashrc"
echo "=============================================="
echo


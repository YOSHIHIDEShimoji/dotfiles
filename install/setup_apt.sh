#!/bin/bash
set -e

#----------------------------------------
# Setup: Install required applications
#----------------------------------------

echo
echo "[*] Installing required packages..."
echo

# Detect package manager
if command -v apt >/dev/null 2>&1 || which apt >/dev/null 2>&1; then
  INSTALL_CMD="sudo apt install -y"
  UPDATE_CMD="sudo apt update"
elif command -v dnf >/dev/null 2>&1 || which dnf >/dev/null 2>&1; then
  INSTALL_CMD="sudo dnf install -y"
  UPDATE_CMD="sudo dnf update -y"
elif command -v pacman >/dev/null 2>&1 || which pacman >/dev/null 2>&1; then
  INSTALL_CMD="sudo pacman -Sy --noconfirm"
  UPDATE_CMD="sudo pacman -Syu --noconfirm"
elif command -v zypper >/dev/null 2>&1 || which zypper >/dev/null 2>&1; then
  INSTALL_CMD="sudo zypper install -y"
  UPDATE_CMD="sudo zypper refresh"
else
  echo "[!] Error: No supported package manager found (apt, dnf, pacman, zypper)"
  exit 1
fi

# List of required packages
PACKAGES=()
while IFS= read -r pkg; do
  [[ "$pkg" =~ ^#.*$ || -z "$pkg" ]] && continue
  PACKAGES+=("$pkg")
done < "$(dirname "$0")/packages-common.txt"

# Update package list
echo "[*] Updating package list..."
$UPDATE_CMD

# Install each package
for pkg in "${PACKAGES[@]}"; do
  echo "[*] Installing $pkg..."
  $INSTALL_CMD "$pkg"
done

echo
echo "[*] All required packages installed."
echo


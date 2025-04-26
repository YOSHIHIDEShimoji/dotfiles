#!/bin/bash
set -e

#----------------------------------------
# Setup: Upload SSH key to GitHub
#----------------------------------------

echo
echo "[*] Checking GitHub authentication..."
if ! gh auth status >/dev/null 2>&1; then
  echo "[!] GitHub is not authenticated. Please run 'gh auth login' first."
  exit 1
else
  echo "[*] GitHub authentication confirmed."
fi

# Check if SSH key exists
SSH_KEY="$HOME/.ssh/id_ed25519.pub"
if [ ! -f "$SSH_KEY" ]; then
  echo "[!] SSH public key not found: $SSH_KEY"
  echo "    Please run setup_ssh.sh first."
  exit 1
fi

# Check if the SSH key is already added to GitHub
echo
echo "[*] Checking if SSH key is already registered with GitHub..."
pubkey_contents=$(cat "$SSH_KEY")
if gh ssh-key list | grep -qF "$pubkey_contents"; then
  echo "[*] This SSH key is already registered with your GitHub account. Skipping upload."
else
  echo
  read -rp "Enter a title for your SSH public key: " key_title
  echo "[*] Uploading SSH public key to GitHub..."
  if gh ssh-key add "$SSH_KEY" --title "$key_title"; then
    echo "[*] SSH public key successfully added to GitHub."
  else
    echo "[!] Failed to add SSH public key. Please check manually."
    exit 1
  fi
fi

echo
echo "[*] GitHub setup complete."
echo

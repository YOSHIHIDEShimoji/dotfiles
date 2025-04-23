#!/bin/bash
set -e

#----------------------------------------
# Setup: GitHub authentication and SSH key upload
#----------------------------------------

echo
echo "[*] Starting GitHub authentication via web browser..."
echo

if gh auth status >/dev/null 2>&1; then
  echo "[*] Already authenticated with GitHub."
else
  if gh auth login --web --git-protocol ssh --scopes admin:public_key; then
    echo "[*] GitHub authentication successful."
  else
    echo "[!] GitHub authentication failed. Please authenticate manually."
    exit 1
  fi
fi

# Ensure required scope is present for SSH key operations
echo
echo "[*] GitHub requires extra permission to upload your SSH key."
echo "    A one-time code will be shown and a browser window will open."
echo "    Please copy the code and complete the process in your browser."
echo
read -rp "Press Enter to begin the authorization process..."

# Execute auth refresh
script -q -c "gh auth refresh -h github.com -s admin:public_key" /dev/null

# Fallback: open GitHub login page manually if xdg-open fails (e.g. WSL)
if grep -qi microsoft /proc/version && command -v explorer.exe >/dev/null 2>&1; then
  echo "[*] Opening browser using explorer.exe..."
  explorer.exe "https://github.com/login/device"
else
  echo "[!] Please manually open the URL: https://github.com/login/device"
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


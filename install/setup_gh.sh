#!/bin/bash
set -e
#----------------------------------------
# Setup: GitHub authentication and SSH key upload
#----------------------------------------
echo
echo "[*] Checking if GitHub CLI (gh) is installed..."
echo
# Check if GitHub CLI (gh) is installed
if ! command -v gh >/dev/null 2>&1; then
  echo "[!] GitHub CLI (gh) is not installed."
  echo "    Please install GitHub CLI first and authenticate using the following command:"
  echo
  echo "    gh auth login --web --git-protocol ssh"
  echo
  exit 1
else
  echo "[*] GitHub CLI (gh) is installed."
fi
echo
echo "[*] Checking GitHub authentication..."
echo
# If already authenticated, skip authentication
if gh auth status >/dev/null 2>&1; then
  echo "[*] GitHub authentication confirmed."
else
  echo "[!] GitHub is not authenticated."
  echo "    Please run the following command manually to authenticate:"
  echo
  echo "    gh auth login --web --git-protocol ssh"
  echo
  echo "Once authenticated, please rerun this script to complete the setup."
  exit 0
fi
# Ensure required scope is present for SSH key operations
echo
echo "[*] GitHub requires extra permission to upload your SSH key."
echo "    A one-time code will be shown and a browser window will open."
echo "    Please copy the code and complete the process in your browser."
echo
read -rp "Press Enter to begin the authorization process..."
echo "[*] Running GitHub authentication refresh..."
# 認証プロセスを直接実行し、自動コード抽出をスキップ
gh auth refresh -h github.com -s admin:public_key

echo "[*] If a one-time code was displayed, please copy it."
echo "[*] Please visit: https://github.com/login/device"
# ブラウザを開く試み
if grep -qi microsoft /proc/version 2>/dev/null && command -v explorer.exe >/dev/null 2>&1; then
  echo "[*] Opening GitHub device page using explorer.exe..."
  explorer.exe "https://github.com/login/device"
elif command -v xdg-open >/dev/null 2>&1; then
  echo "[*] Opening GitHub device page..."
  xdg-open "https://github.com/login/device" &>/dev/null
elif command -v open >/dev/null 2>&1; then
  echo "[*] Opening GitHub device page..."
  open "https://github.com/login/device"
else
  echo "[!] Could not automatically open browser."
  echo "    Please manually visit: https://github.com/login/device"
fi

# 認証が完了したか確認する
echo
echo "[*] After completing authentication in the browser, press Enter to continue..."
read -r

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

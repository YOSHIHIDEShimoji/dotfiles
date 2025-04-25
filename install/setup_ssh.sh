#!/bin/bash
set -e

#----------------------------------------
# Setup: Generate SSH key and register with agent
#----------------------------------------

echo
echo "[*] Checking SSH key..."
echo

SSH_DIR="$HOME/.ssh"
SSH_KEY="$SSH_DIR/id_ed25519"

# Ensure .ssh directory exists with correct permissions
if [ ! -d "$SSH_DIR" ]; then
  echo "[*] Creating $SSH_DIR..."
  mkdir -p "$SSH_DIR"
  chmod 700 "$SSH_DIR"
fi

# Check if SSH key already exists
if [ -f "$SSH_KEY" ]; then
  echo "[*] SSH key already exists: $SSH_KEY"
else
  echo "[*] No SSH key found. Creating a new one..."

  # Try to get email from Git config or environment variable
  email=${EMAIL_FOR_SSH:-$(git config user.email)}

  if [ -z "$email" ]; then
    while [ -z "$email" ]; do
      read -rp "Enter your email for the SSH key: " email
    done
  else
    echo "[*] Using Git configured email: $email"
  fi

  # Generate SSH key with no passphrase
  ssh-keygen -t ed25519 -C "$email" -f "$SSH_KEY" -N ""
  echo "[*] New SSH key created: $SSH_KEY"
fi

# Start ssh-agent and add key
echo "[*] Starting ssh-agent..."
eval "$(ssh-agent -s)"

echo "[*] Adding SSH key to agent..."
ssh-add "$SSH_KEY"

echo
echo "[*] SSH key setup complete."
echo


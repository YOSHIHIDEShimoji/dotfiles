#!/bin/bash
set -e

echo "Setting up .bash_aliases..."

dotfiles_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tempfile=$(mktemp)

# 新しい.bash_aliasesを一時ファイルに作る
cat << 'EOF' > "$tempfile"
# Auto-loading all aliases
for f in ~/dotfiles/aliases/*.sh; do
  [ -e "\$f" ] && source "\$f"
done
EOF

target="$dotfiles_dir/.bash_aliases"

if [ -e "$target" ]; then
  echo "Existing .bash_aliases detected. Checking difference..."
  
  if diff -u "$target" "$tempfile" > /tmp/dotfiles_diff_result; then
    echo "No changes detected. Skipping update."
    rm "$tempfile"
  else
    cat /tmp/dotfiles_diff_result
    echo
    read -p "Do you want to overwrite .bash_aliases? (y/n): " answer
    if [ "$answer" = "y" ]; then
      mv "$tempfile" "$target"
      echo ".bash_aliases updated!"
    else
      echo "Skipped updating .bash_aliases."
      rm "$tempfile"
    fi
  fi
else
  mv "$tempfile" "$target"
  echo ".bash_aliases created!"
fi


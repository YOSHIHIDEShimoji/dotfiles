#!/bin/bash
set -e

echo "Setting up .bash_exports..."

dotfiles_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tempfile=$(mktemp)

# 新しい.bash_exportsを一時ファイルに作る
cat << 'EOF' > "$tempfile"
# Auto-loading all exports
for f in ~/dotfiles/exports/*.sh; do
  [ -e "\$f" ] && source "\$f"
done
EOF

target="$dotfiles_dir/.bash_exports"

if [ -e "$target" ]; then
  echo "Existing .bash_exports detected. Checking difference..."
  
  if diff -u "$target" "$tempfile" > /tmp/dotfiles_diff_result; then
    echo "No changes detected. Skipping update."
    rm "$tempfile"
  else
    cat /tmp/dotfiles_diff_result
    echo
    read -p "Do you want to overwrite .bash_exports? (y/n): " answer
    if [ "$answer" = "y" ]; then
      mv "$tempfile" "$target"
      echo ".bash_exports updated!"
    else
      echo "Skipped updating .bash_exports."
      rm "$tempfile"
    fi
  fi
else
  mv "$tempfile" "$target"
  echo ".bash_exports created!"
fi


#!/bin/bash
set -e

echo "Setting up .bash_functions..."

dotfiles_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tempfile=$(mktemp)

# 新しい.bash_functionsを一時ファイルに作る
cat << 'EOF' > "$tempfile"
# Auto-loading all functions
for f in ~/dotfiles/functions/*.sh; do
  [ -e "\$f" ] && source "\$f"
done
EOF

target="$dotfiles_dir/.bash_functions"

if [ -e "$target" ]; then
  echo "Existing .bash_functions detected. Checking difference..."
  
  if diff -u "$target" "$tempfile" > /tmp/dotfiles_diff_result; then
    echo "No changes detected. Skipping update."
    rm "$tempfile"
  else
    cat /tmp/dotfiles_diff_result
    echo
    read -p "Do you want to overwrite .bash_functions? (y/n): " answer
    if [ "$answer" = "y" ]; then
      mv "$tempfile" "$target"
      echo ".bash_functions updated!"
    else
      echo "Skipped updating .bash_functions."
      rm "$tempfile"
    fi
  fi
else
  mv "$tempfile" "$target"
  echo ".bash_functions created!"
fi


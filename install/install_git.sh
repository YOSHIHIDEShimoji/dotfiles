#!/bin/bash
set -e

echo "Setting up .gitconfig..."

dotfiles_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tempfile=$(mktemp)

# 新しい.gitconfigを一時ファイルに作る
cat "$dotfiles_dir/gitconfig/"* > "$tempfile"

target="$dotfiles_dir/.gitconfig"

if [ -e "$target" ]; then
  echo "Existing .gitconfig detected. Checking difference..."
  
  if diff -u "$target" "$tempfile" > /tmp/dotfiles_diff_result; then
    echo "No changes detected. Skipping update."
    rm "$tempfile"
  else
    cat /tmp/dotfiles_diff_result
    echo
    read -p "Do you want to overwrite .gitconfig? (y/n): " answer
    if [ "$answer" = "y" ]; then
      mv "$tempfile" "$target"
      echo ".gitconfig updated!"
    else
      echo "Skipped updating .gitconfig."
      rm "$tempfile"
    fi
  fi
else
  mv "$tempfile" "$target"
  echo ".gitconfig created!"
fi


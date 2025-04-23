#!/bin/bash
set -e

dotfiles_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
files=(.bashrc .gitconfig .profile)

for file in "${files[@]}"; do
  target="$HOME/$file"
  source="$dotfiles_dir/$file"

  if [ -e "$target" ] && [ ! -L "$target" ]; then
    mv "$target" "$target.bak"
    echo "Backed up: $target → $target.bak"
  fi

  ln -sf "$source" "$target"
  echo "Linked: $target → $source"
done

echo
echo "Done. Please run 'source ~/.bashrc' if you want to apply the changes immediately."


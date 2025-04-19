#!/bin/bash

set -e  # エラーがあったらスクリプトを止める

echo "Installing dotfiles..."

# このスクリプトが置かれている場所を取得
dotfiles_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 対象ファイルリスト
files=(
  .bash_aliases
  .bash_exports
  .bash_functions
  .bashrc
  .gitconfig
  .profile
)

# 対象ファイルを処理
for file in "${files[@]}"; do
  target="$HOME/$file"
  source="$dotfiles_dir/$file"

  echo "Checking $file"
  if [ ! -e "$target" ]; then
    echo "$file not found. Creating empty file."
    touch "$target"
  fi

  if [ ! -e "$source" ]; then
    echo "Moving $file to dotfiles directory."
    mv "$target" "$source"
  fi

  echo "Linking $file"
  ln -sf "$source" "$target"
done

# 特別処理①: .gitconfig に必要な設定を追記する
user_block="[user]\n    name = YOSHIHIDEShimoji\n    email = g.y.shimoji@gmail.com"
init_block="[init]\n    defaultBranch = main"
alias_block="[alias]\n  st = status\n  co = checkout\n  br = branch\n  cm = commit -m\n  ca = commit -a -m\n  last = log -1 HEAD\n  lg = log --oneline --graph --all --decorate\n  df = diff\n  dfc = diff --cached\n  unstage = reset HEAD --\n  undo = reset --soft HEAD~1\n  pu = push\n  pl = pull"

if ! grep -q "\[user\]" "$dotfiles_dir/.gitconfig"; then
  echo -e "\n$user_block" >> "$dotfiles_dir/.gitconfig"
  echo "Added [user] block to .gitconfig"
fi

if ! grep -q "\[init\]" "$dotfiles_dir/.gitconfig"; then
  echo -e "\n$init_block" >> "$dotfiles_dir/.gitconfig"
  echo "Added [init] block to .gitconfig"
fi

if ! grep -q "\[alias\]" "$dotfiles_dir/.gitconfig"; then
  echo -e "\n$alias_block" >> "$dotfiles_dir/.gitconfig"
  echo "Added [alias] block to .gitconfig"
fi

# 特別処理②: .bash_functions に open() 関数を追記
open_function='open() {
  if [ $# -eq 0 ]; then
    explorer.exe .
  else
    for path in "$@"; do
      explorer.exe "$(wslpath -w "$path")"
    done
  fi
}'

if ! grep -q "open()" "$dotfiles_dir/.bash_functions"; then
  echo -e "\n$open_function" >> "$dotfiles_dir/.bash_functions"
  echo "Added open() function to .bash_functions"
fi

# 特別処理③: .bashrc に .bash_aliases, .bash_functions, .bash_exports 読み込み設定を追加

aliases_snippet="# Alias definitions.\n# You may want to put all your additions into a separate file like\n# ~/.bash_aliases, instead of adding them here directly.\n# See /usr/share/doc/bash-doc/examples in the bash-doc package.\n\nif [ -f ~/.bash_aliases ]; then\n    . ~/.bash_aliases\nfi"

functions_snippet="# Function definitions.\n# You may want to put all your additions into a separate file like\n# ~/.bash_functions, instead of adding them here directly.\n\nif [ -f ~/.bash_functions ]; then\n    . ~/.bash_functions\nfi"

exports_snippet="# Exports definitions.\n# You may want to put all your additions into a separate file like\n# ~/.bash_exports, instead of adding them here directly.\n\nif [ -f ~/.bash_exports ]; then\n    . ~/.bash_exports\nfi"

if ! grep -q "\.bash_aliases" "$dotfiles_dir/.bashrc"; then
  echo -e "\n$aliases_snippet" >> "$dotfiles_dir/.bashrc"
  echo "Added .bash_aliases loading to .bashrc"
fi

if ! grep -q "\.bash_functions" "$dotfiles_dir/.bashrc"; then
  echo -e "\n$functions_snippet" >> "$dotfiles_dir/.bashrc"
  echo "Added .bash_functions loading to .bashrc"
fi

if ! grep -q "\.bash_exports" "$dotfiles_dir/.bashrc"; then
  echo -e "\n$exports_snippet" >> "$dotfiles_dir/.bashrc"
  echo "Added .bash_exports loading to .bashrc"
fi

echo "Dotfiles installation complete!"
echo ""
echo "To apply the changes, run the following command:"
echo ""
echo "    source ~/.bashrc"
echo ""
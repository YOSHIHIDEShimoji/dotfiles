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

# dotfilesをリンク
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

# .gitconfigに[user]設定を追加
user_block="[user]\n    name = YOSHIHIDEShimoji\n    email = g.y.shimoji@gmail.com"
if ! grep -q "\[user\]" "$dotfiles_dir/.gitconfig"; then
  echo -e "\n$user_block" >> "$dotfiles_dir/.gitconfig"
  echo "Added [user] block to .gitconfig"
fi

# .gitconfigに[init]設定を追加
init_block="[init]\n    defaultBranch = main"
if ! grep -q "\[init\]" "$dotfiles_dir/.gitconfig"; then
  echo -e "\n$init_block" >> "$dotfiles_dir/.gitconfig"
  echo "Added [init] block to .gitconfig"
fi

# .gitconfigに[alias]設定を追加
alias_block="[alias]\n  st = status\n  co = checkout\n  br = branch\n  cm = commit -m\n  ca = commit -a -m\n  last = log -1 HEAD\n  lg = log --oneline --graph --all --decorate\n  df = diff\n  dfc = diff --cached\n  unstage = reset HEAD --\n  undo = reset --soft HEAD~1\n  pu = push\n  pl = pull"
if ! grep -q "\[alias\]" "$dotfiles_dir/.gitconfig"; then
  echo -e "\n$alias_block" >> "$dotfiles_dir/.gitconfig"
  echo "Added [alias] block to .gitconfig"
fi

# .bash_functionsにopen()関数を追加
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

# .bashrcに.bash_aliases読み込みを追加
aliases_snippet="# Alias definitions.\n# You may want to put all your additions into a separate file like\n# ~/.bash_aliases, instead of adding them here directly.\n# See /usr/share/doc/bash-doc/examples in the bash-doc package.\n\nif [ -f ~/.bash_aliases ]; then\n    . ~/.bash_aliases\nfi"
if ! grep -q "\.bash_aliases" "$dotfiles_dir/.bashrc"; then
  echo -e "\n$aliases_snippet" >> "$dotfiles_dir/.bashrc"
  echo "Added .bash_aliases loading to .bashrc"
fi

# .bashrcに.bash_functions読み込みを追加
functions_snippet="# Function definitions.\n# You may want to put all your additions into a separate file like\n# ~/.bash_functions, instead of adding them here directly.\n\nif [ -f ~/.bash_functions ]; then\n    . ~/.bash_functions\nfi"
if ! grep -q "\.bash_functions" "$dotfiles_dir/.bashrc"; then
  echo -e "\n$functions_snippet" >> "$dotfiles_dir/.bashrc"
  echo "Added .bash_functions loading to .bashrc"
fi

# .bashrcに.bash_exports読み込みを追加
exports_snippet="# Exports definitions.\n# You may want to put all your additions into a separate file like\n# ~/.bash_exports, instead of adding them here directly.\n\nif [ -f ~/.bash_exports ]; then\n    . ~/.bash_exports\nfi"
if ! grep -q "\.bash_exports" "$dotfiles_dir/.bashrc"; then
  echo -e "\n$exports_snippet" >> "$dotfiles_dir/.bashrc"
  echo "Added .bash_exports loading to .bashrc"
fi

# .bashrcにPATH設定を追加
path_snippet='export PATH="$HOME/.local/bin:$PATH"'
if ! grep -q 'export PATH="\$HOME/.local/bin:\$PATH"' "$dotfiles_dir/.bashrc"; then
  echo -e "\n$path_snippet" >> "$dotfiles_dir/.bashrc"
  echo "Added PATH export to .bashrc"
fi

# 最後に案内メッセージ
echo
echo "=============================================="
echo "To apply the changes, run the following command:"
echo
echo "    source ~/.bashrc"
echo "=============================================="
echo


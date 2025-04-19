#!/bin/bash

set -e  # エラーがあったらスクリプトを止める

echo "\U0001F4E6 Installing dotfiles..."

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

  # ホームにファイルがなければ作成
echo "\U0001F195 Checking $file"
  if [ ! -e "$target" ]; then
    echo "⚡ $file not found. Creating empty file."
    touch "$target"
  fi

  # dotfilesにまだ存在しなければ移動
  if [ ! -e "$source" ]; then
    echo "\U0001F4C2 Moving $file to dotfiles directory."
    mv "$target" "$source"
  fi

  # シンボリックリンクを作成
  echo "\U0001F517 Linking $file"
  ln -sf "$source" "$target"

done

# 特別処理①: .gitconfig に必要な設定を追記する
user_block="[user]\n    name = YOSHIHIDEShimoji\n    email = g.y.shimoji@gmail.com"
init_block="[init]\n    defaultBranch = main"
alias_block="[alias]\n  st = status\n  co = checkout\n  br = branch\n  cm = commit -m\n  ca = commit -a -m\n  last = log -1 HEAD\n  lg = log --oneline --graph --all --decorate\n  df = diff\n  dfc = diff --cached\n  unstage = reset HEAD --\n  undo = reset --soft HEAD~1\n  pu = push\n  pl = pull"

if ! grep -q "\[user\]" "$dotfiles_dir/.gitconfig"; then
  echo -e "\n$user_block" >> "$dotfiles_dir/.gitconfig"
  echo "\U0001F4DD Added [user] block to .gitconfig"
fi

if ! grep -q "\[init\]" "$dotfiles_dir/.gitconfig"; then
  echo -e "\n$init_block" >> "$dotfiles_dir/.gitconfig"
  echo "\U0001F4DD Added [init] block to .gitconfig"
fi

if ! grep -q "\[alias\]" "$dotfiles_dir/.gitconfig"; then
  echo -e "\n$alias_block" >> "$dotfiles_dir/.gitconfig"
  echo "\U0001F4DD Added [alias] block to .gitconfig"
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
  echo "\U0001F4DD Added open() function to .bash_functions"
fi

echo "\U00002705 Dotfiles installation complete!"

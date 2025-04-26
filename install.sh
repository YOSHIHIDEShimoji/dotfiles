#!/bin/bash

set -e  # エラーが発生したらスクリプトを即終了する

# -----------------------------------------------
# install.sh
# dotfiles環境をセットアップするためのメインスクリプト
# -----------------------------------------------

# このスクリプトが置かれている場所（dotfilesルート）を取得
dotfiles_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 最初に案内メッセージを表示
cat << EOF
まず最初に以下を手動で実行してください：

  sudo apt update && sudo apt install gh && gh auth login --web --git-protocol ssh

※ブラウザでのGitHub認証が必要です
EOF

read -p "上記を完了しましたか？ (y/n): " answer
if [ "$answer" != "y" ]; then
  echo "セットアップを中断しました。"
  exit 1
fi

# -----------------------------------------------
# 必要なセットアップスクリプトを順番に実行
# -----------------------------------------------

echo "Running setup_apt.sh..."
bash "$dotfiles_dir/install/setup_apt.sh"

echo "Running setup_ssh.sh..."
bash "$dotfiles_dir/install/setup_ssh.sh"

echo "Running setup_gh.sh..."
bash "$dotfiles_dir/install/setup_gh.sh"

# -----------------------------------------------
# dotfiles本体のセットアップ開始
# -----------------------------------------------

echo "Installing dotfiles..."

# バックアップ先ディレクトリを用意
backup_dir="$HOME/dotfiles_backup"
mkdir -p "$backup_dir"

# 対象ファイルリスト
files=(
  .bash_aliases
  .bash_exports
  .bash_functions
  .bashrc
  .gitconfig
  .profile
)

# ファイルごとにバックアップとリンク作成
for file in "${files[@]}"; do
  target="$HOME/$file"
  source="$dotfiles_dir/$file"

  echo "Processing $file..."

  if [ -e "$target" ] && [ ! -L "$target" ]; then
    echo "Backing up existing $file to $backup_dir"
    mv "$target" "$backup_dir/"
    echo "$file was backed up to $backup_dir/$file"
  fi

  ln -sf "$source" "$target"
done

# 完了メッセージ
echo
echo "Setup completed successfully!"
echo "Please run 'source ~/.bashrc' to apply the settings immediately."

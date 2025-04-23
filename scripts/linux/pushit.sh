#!/bin/bash

# -m オプションでコミットメッセージを受け取る
while getopts "m:" opt; do
  case "$opt" in
    m) msg="$OPTARG" ;;
    *) echo "Usage: $0 [-m commit_message]"; exit 1 ;;
  esac
done

# Gitリポジトリかどうか確認
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  echo "This directory is not a Git repository."
  exit 1
fi

# Gitルートディレクトリに移動
cd "$(git rev-parse --show-toplevel)" || {
  echo "Failed to move to Git root."
  exit 1
}

# ステータス表示
echo "=== Git Status ==="
git status

# 先に変更をステージング
git add .

# ステージされた変更がなければ終了
if git diff --cached --quiet; then
  echo "There were no changes, so nothing was pushed."
  exit 0
fi

# コミットメッセージの確認
if [ -z "$msg" ]; then
  echo ""
  read -p "Enter your commit message: " msg
fi

# Git操作
git commit -m "$msg"
git push

echo ""
echo "Push has been completed!"

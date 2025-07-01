#!/bin/bash

# 引数がない場合はエラー
if [ $# -eq 0 ]; then
  echo "Error: Commit message is required."
  echo "Usage: $0 \"commit message\""
  exit 1
fi

# 最初の引数をコミットメッセージとして取得
msg="$1"

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

# Git操作
echo ""
echo "=== Committing with message: \"$msg\" ==="
git commit -m "$msg"
git push
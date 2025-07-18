gbd() {
  if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "このディレクトリは Git リポジトリではありません。"
    return 1
  fi

  local current_branch
  current_branch=$(git rev-parse --abbrev-ref HEAD)

  if [ "$current_branch" = "main" ] || [ "$current_branch" = "master" ]; then
    echo "現在のブランチが main のため削除を中止します。"
    return 1
  fi

  echo "ブランチ '$current_branch' を main にチェックアウト後に削除します。よろしいですか？ (y/n)"
  read -r ans
  if [[ "$ans" == [Yy] ]]; then
    git checkout main &&
    git branch -d "$current_branch" || {
      echo "ローカルブランチの削除に失敗しました。"
      echo "マージしてから再度実行して下さい。"
      return 1
    }
    git push origin --delete "$current_branch"
    echo "'$current_branch' を削除しました。"
  else
    echo "キャンセルしました。"
  fi
}

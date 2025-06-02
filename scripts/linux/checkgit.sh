#!/bin/bash

root_dir="$(pwd)"
exclude_dir="$HOME/.pyenv"
declare -a repos=()

# 色定義
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
RESET="\e[0m"

# ~/.pyenv配下を除外してGitルート探索
while IFS= read -r dir; do
  if git -C "$dir" rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    is_child=false
    for existing in "${repos[@]}"; do
      if [[ "$dir" == "$existing"* ]]; then
        is_child=true
        break
      fi
    done
    if [ "$is_child" = false ]; then
      repos+=("$dir")
    fi
  fi
done < <(find "$root_dir" -type d \( -path "$exclude_dir" -o -path "$exclude_dir/*" \) -prune -o -type d -print)

# 結果をtreeっぽく表示
echo "."
repo_count=${#repos[@]}

for i in "${!repos[@]}"; do
  path="${repos[$i]}"
  rel_path="${path#$root_dir/}"  # 相対パスに変換

  if [ "$i" -eq $((repo_count-1)) ]; then
    branch_symbol="└──"
  else
    branch_symbol="├──"
  fi

  # ブランチ名取得
  branch_name=$(git -C "$path" rev-parse --abbrev-ref HEAD 2>/dev/null)

  # git status --shortで変更確認
  status_output=$(git -C "$path" status --short)

  # fetchして最新状態を取得（fetch結果は表示しない）
  git -C "$path" fetch --quiet 2>/dev/null

  # 未push確認
  ahead_flag=""
  if git -C "$path" status -sb 2>/dev/null | grep -q '\[ahead'; then
    ahead_flag=" ${RED}[Unpushed commits]${RESET}"
  fi

  # pull必要確認
  behind_flag=""
  if git -C "$path" status -sb 2>/dev/null | grep -q '\[behind'; then
    behind_flag=" ${YELLOW}[Need pull]${RESET}"
  fi

  # 色分け表示
  if [ -z "$status_output" ]; then
    status_text="${GREEN}Clean${RESET}"
  else
    status_text="${RED}Changes${RESET}"
  fi

  echo -e "${branch_symbol} ${rel_path} (${branch_name}) : ${status_text}${ahead_flag}${behind_flag}"
done

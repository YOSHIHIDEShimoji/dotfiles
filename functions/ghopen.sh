ghopen() {
  # 引数があれば使う、なければカレントディレクトリ
  target_path="${1:-.}"

  # 絶対パス化しておく
  abs_path=$(realpath "$target_path")

  # Gitルートの取得（失敗したら終了）
  repo_root=$(git -C "$abs_path" rev-parse --show-toplevel 2>/dev/null) || {
    echo "Not in a Git repository"
    return 1
  }

  # Gitリポジトリ名（最後のディレクトリ名）を取得
  repo_name=$(basename "$repo_root")

  # 相対パスを取得
  rel_path=$(realpath --relative-to="$repo_root" "$abs_path")

  # ブランチ名取得
  branch=$(git -C "$abs_path" symbolic-ref --short HEAD)

  # GitHub URLを生成（ユーザー名は固定）
  url="https://github.com/YOSHIHIDEShimoji/${repo_name}/tree/${branch}/${rel_path}"

  # WSL判定して起動方法を分岐
  if grep -qi microsoft /proc/version; then
    explorer.exe "$url"
  else
    google-chrome "$url" &
  fi
}

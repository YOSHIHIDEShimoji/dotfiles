c() {
  [[ "$1" == *.c ]] || { echo "Usage: c file.c [args ...]"; return 1; }

  src="$(realpath "$1")"
  shift  # 残りの引数を実行ファイルに渡すためにずらす

  dir="$(dirname "$src")"
  name="$(basename "${src%.c}")"

  build_dir="$dir/build"
  mkdir -p "$build_dir"

  out="$build_dir/$name"

  cc "$src" -o "$out" && "$out" "$@"
}

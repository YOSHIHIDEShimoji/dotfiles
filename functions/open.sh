open() {
  if [ $# -eq 0 ]; then
    explorer.exe .
  else
    for path in "$@"; do
      explorer.exe "$(wslpath -w "$path")"
    done
  fi
}


c() {
  [[ "$1" == *.c ]] || { echo "Usage: c file.c"; return 1; }
  fullpath="$(realpath "$1")"
  out="${fullpath%.c}"
  cc "$fullpath" -o "$out" && "$out"
}


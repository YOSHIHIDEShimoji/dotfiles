c() {
  [[ "$1" == *.c ]] || { echo "Usage: c file.c"; return 1; }
  cc "$1" -o "${1%.c}"
}


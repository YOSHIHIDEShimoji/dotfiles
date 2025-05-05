vic() {
  filename="$1"
  if [ -z "$filename" ]; then
    echo "Usage: vic filename.c"
    return 1
  fi

  if [[ ! "$filename" =~ \.c$ ]]; then
    echo "Error: filename must end with .c"
    return 1
  fi

  if [ ! -f "$filename" ]; then
    {
      echo '#include <stdio.h>'
      echo
      echo 'int main(void)'
      echo '{'
      echo 
      echo '}'
    } > "$filename"
  fi

  vi "$filename"
}



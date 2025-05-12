# すでに含まれていない場合だけ追加する
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;  # 何もしない
  *) export PATH="$HOME/.local/bin:$PATH" ;;
esac


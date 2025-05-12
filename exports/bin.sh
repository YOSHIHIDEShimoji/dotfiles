# すでに含まれていない場合だけ追加する
case ":$PATH:" in
  *":$HOME/bin:"*) ;;  # 何もしない
  *) export PATH="$HOME/bin:$PATH" ;;
esac

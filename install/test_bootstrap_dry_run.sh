#!/usr/bin/env bash
# bootstrap.sh のドライ実行テスト
# 副作用なし（ln/sudo/launchctl/brew bundle/mv/rm は一切実行しない）

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"

PASS=0
FAIL=0
WARN=0

pass() { echo "[PASS] $*"; PASS=$((PASS + 1)); }
fail() { echo "[FAIL] $*"; FAIL=$((FAIL + 1)); }
warn() { echo "[WARN] $*"; WARN=$((WARN + 1)); }

echo "=== bootstrap.sh ドライ実行テスト ==="
echo "DOTFILES_DIR: $DOTFILES_DIR"
echo ""

# ==========================================
# 1. 必須コマンド確認
# ==========================================
# このテストは両 OS で走る必要がある（クロスプラットフォーム構成を守る節[10]を
# Linux 側 CI でも通すため）。macOS 専用コマンドを無条件に必須にすると Linux で
# 必ず FAIL 終了し、検査の実体が macOS だけに閉じてしまう。
IS_MAC=false
[[ "$(uname)" == "Darwin" ]] && IS_MAC=true

echo "--- [1] 必須コマンド ---"
REQUIRED_CMDS=(ln mkdir envsubst awk xargs)
if [[ "$IS_MAC" == true ]]; then
	REQUIRED_CMDS+=(launchctl plutil)
fi
for cmd in "${REQUIRED_CMDS[@]}"; do
	if command -v "$cmd" &>/dev/null; then
		pass "コマンド存在: $cmd"
	else
		fail "コマンドが見つからない: $cmd"
	fi
done
echo ""

# ==========================================
# 2. LaunchAgents plist
# ==========================================
echo "--- [2] LaunchAgents plist ---"
LAUNCH_SRC="$DOTFILES_DIR/LaunchAgents"
if [[ "$IS_MAC" == false ]]; then
	pass "macOS 以外のため LaunchAgents 検査をスキップ（launchd は macOS 専用）"
elif [ -d "$LAUNCH_SRC" ]; then
	shopt -s nullglob
	plist_files=("$LAUNCH_SRC"/*.plist)
	shopt -u nullglob
	if [ "${#plist_files[@]}" -eq 0 ]; then
		warn "LaunchAgents ディレクトリは存在するが plist ファイルがない"
	else
		for plist in "${plist_files[@]}"; do
			if plutil -lint "$plist" &>/dev/null; then
				pass "plist 構文OK: $(basename "$plist")"
			else
				fail "plist 構文エラー: $(basename "$plist")"
				plutil -lint "$plist" 2>&1 | sed 's/^/  /'
			fi
		done
	fi
else
	warn "LaunchAgents ディレクトリが存在しない: $LAUNCH_SRC"
fi
echo ""

# ==========================================
# 3-6. links.prop パース・ファイル存在・親ディレクトリ・衝突チェック
# ==========================================
# macOS 専用リンクグループ。bootstrap.sh の IS_MAC 分岐がリンクする集合と一致させる
# （整合は節[10-5] が bootstrap.sh 側を構造検査して担保する）。
# Linux ではこれらのグループはリンクされないため、リンク先（dst 側）の検査を行うと
# 「mkdir -p で作成される」という事実に反する警告を出してしまう。
MAC_ONLY_LINK_GROUPS=" karabiner vscode ghostty "

check_links_prop() {
	local dir="$1"
	local prop="$DOTFILES_DIR/$dir/links.prop"
	local dst_checks=true

	# macOS 専用グループは、Linux では src 側（repo の完全性）だけを検査し
	# dst 側（リンク先の親ディレクトリ・衝突）はスキップする
	if [[ "$IS_MAC" == false && "$MAC_ONLY_LINK_GROUPS" == *" $dir "* ]]; then
		dst_checks=false
	fi

	echo "--- [$dir/links.prop] ---"

	if [ ! -f "$prop" ]; then
		fail "links.prop が存在しない: $prop"
		echo ""
		return
	fi
	pass "links.prop 存在: $prop"

	while IFS= read -r line; do
		[[ -z "$line" || "$line" =~ ^# ]] && continue

		src=$(echo "$line" | awk -F'->' '{print $1}' | xargs)
		dst=$(echo "$line" | awk -F'->' '{print $2}' | xargs | envsubst)

		if [ -z "$src" ]; then
			fail "src が空: $line"
			continue
		fi
		if [ -z "$dst" ]; then
			fail "dst が空（envsubst 展開後）: $line"
			continue
		fi

		src_path="$DOTFILES_DIR/$dir/$src"

		# テスト4: ソースファイル存在
		if [ -e "$src_path" ]; then
			pass "ソースファイル存在: $src_path"
		elif [ "$dir/$src" = "zsh/starship/current.toml" ] && [ -f "$DOTFILES_DIR/zsh/starship/tokyo-night.toml" ]; then
			# current.toml は .gitignore 対象（#13）で fresh checkout には無い。
			# bootstrap.sh が tokyo-night.toml からシードしてからリンクするため、
			# シード元が存在すれば PASS 扱いにする（テストを実装挙動に一致させる＝#21）。
			pass "ソースファイル（bootstrap がシード）: $src_path ← tokyo-night.toml"
		else
			fail "ソースファイルが存在しない: $src_path"
		fi

		# テスト5・6 は dst 側の検査。macOS 専用グループは Linux ではリンクされない
		# （bootstrap.sh の IS_MAC 分岐内）ため、この OS では実施しない
		if [ "$dst_checks" = false ]; then
			continue
		fi

		# テスト5: リンク先親ディレクトリ
		dst_dir="$(dirname "$dst")"
		if [ -d "$dst_dir" ]; then
			pass "リンク先親ディレクトリ存在: $dst_dir"
		else
			warn "親ディレクトリなし（mkdir -p で作成される）: $dst_dir"
		fi

		# テスト6: 既存ファイル衝突（シンボリックリンクでない通常ファイル）
		if [ -e "$dst" ] && [ ! -L "$dst" ]; then
			warn "既存ファイル衝突（バックアップ対象）: $dst"
		fi

	done < "$prop"

	if [ "$dst_checks" = false ]; then
		pass "macOS 専用グループのため dst 検査をスキップ（この OS ではリンクされない）: $dir"
	fi
	echo ""
}

echo "--- [3-6] links.prop パース・ソースファイル・親ディレクトリ・衝突 ---"
echo ""
# links.prop を持つ全ディレクトリを自動列挙する（手動リストの追加漏れを構造的に防ぐ＝#21。
# 以前は claude/ が対象外だった）。bootstrap.sh がリンクする集合と一致する。
for _prop in "$DOTFILES_DIR"/*/links.prop; do
	[ -f "$_prop" ] || continue
	check_links_prop "$(basename "$(dirname "$_prop")")"
done

# ==========================================
# 7. Brewfile 検証
# ==========================================
echo "--- [7] Brewfile ---"
BREWFILE="$DOTFILES_DIR/install/Brewfile"
if [[ "$IS_MAC" == false ]]; then
	pass "macOS 以外のため Brewfile 検査をスキップ（Linux は Aptfile が対応・節[10]で検査）"
elif [ -f "$BREWFILE" ]; then
	pass "Brewfile 存在: $BREWFILE"
	if command -v brew &>/dev/null; then
		pass "brew コマンド存在"
		pkg_count=$(brew bundle list --file="$BREWFILE" 2>/dev/null | wc -l | xargs)
		pass "Brewfile パッケージ数: $pkg_count"
	else
		warn "brew が見つからない（新規 Mac ではインストール前の可能性あり）"
	fi
else
	fail "Brewfile が存在しない: $BREWFILE"
fi
echo ""

# ==========================================
# 8. VS Code 拡張機能
# ==========================================
echo "--- [8] VS Code 拡張機能 ---"
EXT_FILE="$DOTFILES_DIR/vscode/extensions.txt"
if [ -f "$EXT_FILE" ]; then
	ext_count=$(wc -l < "$EXT_FILE" | xargs)
	pass "extensions.txt 存在: $EXT_FILE ($ext_count 行)"
else
	fail "extensions.txt が存在しない: $EXT_FILE"
fi

if command -v code &>/dev/null; then
	pass "code コマンド存在"
else
	warn "code コマンドが見つからない（VS Code 未インストールまたは PATH 未設定）"
fi
echo ""

# ==========================================
# 9. zsh 関数の構文チェック
# ==========================================
echo "--- [9] zsh 関数の構文 ---"
if command -v zsh &>/dev/null; then
	fn_fail=0
	for fn in "$DOTFILES_DIR"/zsh/functions/*; do
		[ -f "$fn" ] || continue
		if ! zsh -n "$fn" 2>/dev/null; then
			fail "zsh 構文エラー: $(basename "$fn")"
			fn_fail=1
		fi
	done
	[ "$fn_fail" -eq 0 ] && pass "全 zsh 関数の構文OK"
else
	warn "zsh が見つからない（関数の構文チェックをスキップ）"
fi
echo ""

# ==========================================
# 10. クロスプラットフォーム構成の健全性
# ==========================================
# 「単一 repo・単一 branch で macOS と Linux(WSL) の両方が完結する」ことを構造的に守る検査。
# ここが無いと、片 OS だけを触った変更で静かに片肺へ戻る（#32 で実際に起きた）。
echo "--- [10] クロスプラットフォーム構成 ---"

# 10-1. bootstrap は1本であること。2本立てにすると片方の改善がもう片方に届かず乖離する。
if [ -f "$DOTFILES_DIR/install/bootstrap-linux.sh" ]; then
	fail "install/bootstrap-linux.sh が存在する（bootstrap.sh に OS 分岐で統合する方針）"
else
	pass "bootstrap は install/bootstrap.sh の1本のみ"
fi

# 10-2. 配置パスを OS で変えないこと（旧構成の OS 別ディレクトリ復活を防ぐ）。
# 検査対象は設定・スクリプト領域に限る。docs/ や CLAUDE.md・CI 定義は
# 「なぜこの規約があるか」を説明するために語そのものを含むため対象外にする。
FORBIDDEN_PATH_PATTERN='dotfiles-linux'
FORBIDDEN_SCAN_PATHS=(zsh install scripts git tmux ssh claude karabiner vscode ghostty)
if git -C "$DOTFILES_DIR" grep -qI "$FORBIDDEN_PATH_PATTERN" -- "${FORBIDDEN_SCAN_PATHS[@]}" ':!install/test_bootstrap_dry_run.sh' 2>/dev/null; then
	fail "'$FORBIDDEN_PATH_PATTERN' への参照が設定/スクリプトに残っている（両 OS とも ~/dotfiles に統一する）"
	git -C "$DOTFILES_DIR" grep -nI "$FORBIDDEN_PATH_PATTERN" -- "${FORBIDDEN_SCAN_PATHS[@]}" ':!install/test_bootstrap_dry_run.sh' | sed 's/^/  /'
else
	pass "配置パスは両 OS 共通（OS 別ディレクトリへの参照なし）"
fi

# 10-3. bootstrap.sh が OS 分岐を持つこと
if grep -q 'IS_MAC' "$DOTFILES_DIR/install/bootstrap.sh" && grep -q 'IS_WSL' "$DOTFILES_DIR/install/bootstrap.sh"; then
	pass "bootstrap.sh に OS 判定（IS_MAC / IS_WSL）あり"
else
	fail "bootstrap.sh に OS 判定が無い"
fi

# 10-4. Aptfile（Linux 側のパッケージ定義。Brewfile に相当）
APTFILE="$DOTFILES_DIR/install/Aptfile"
if [ -f "$APTFILE" ]; then
	pass "Aptfile 存在: $APTFILE"
	if grep -q '^\[wsl\]' "$APTFILE" && grep -q '^\[linux\]' "$APTFILE"; then
		pass "Aptfile に [wsl]/[linux] セクションあり"
	else
		fail "Aptfile に [wsl]/[linux] セクションが無い"
	fi
else
	fail "Aptfile が存在しない: $APTFILE"
fi

# 10-5. macOS 専用リンクグループを Linux で回していないこと。
# vscode/ghostty/karabiner の links.prop は宛先が ~/Library/... 固定のため、
# Linux で回すと偽の ~/Library ツリーとダングリングリンクを作る。
#
# 出現「回数」で判定してはいけない。回数だけを数える実装は
#   (a) リンク呼び出しを分岐の外へ移動しても（＝防ぎたい退行そのもの）
#   (b) 分岐内の3行をコメントアウトしても
# どちらも素通りする（ミューテーション実験で実証済み）。
# ここでは「macOS 分岐ブロックの内側に3つ」かつ「ブロックの外側に0」を構造で検査する。
mac_link_check=$(awk '
	# コメント行は数えない
	/^[[:space:]]*#/ { next }
	# macOS 分岐の開始を検出し、以降の if/fi をネスト深度で追跡する
	!inblk && /if[[:space:]]*\[\[[[:space:]]*"\$IS_MAC"[[:space:]]*==[[:space:]]*true/ {
		inblk = 1; depth = 1; next
	}
	inblk {
		if ($0 ~ /(^|[[:space:];])if[[:space:]]/) depth++
		if ($0 ~ /(^|[[:space:];])fi([[:space:]]|;|$)/) { depth--; if (depth == 0) { inblk = 0; next } }
	}
	/link_from_prop[[:space:]]+(karabiner|vscode|ghostty)/ {
		if (inblk) inside++; else outside++
	}
	END { printf "%d %d", inside+0, outside+0 }
' "$DOTFILES_DIR/install/bootstrap.sh")
mac_inside=${mac_link_check% *}
mac_outside=${mac_link_check#* }
if [ "$mac_inside" -eq 3 ] && [ "$mac_outside" -eq 0 ]; then
	pass "karabiner/vscode/ghostty のリンクは macOS 分岐の内側のみ（内=3 外=0）"
else
	fail "macOS 専用リンクの配置が不正（分岐内=$mac_inside 期待3 / 分岐外=$mac_outside 期待0）"
	[ "$mac_outside" -ne 0 ] && echo "  → 分岐外にあると Linux で ~/Library が作られる" >&2
fi

# 10-6. 無人実行を止めない不変条件（tripwire）。
# 実機 WSL で「対話プロンプト待ちによる無限停止」が2件起きた。いずれも CI では
# 構造的に再現できない（runner の sudo はパスワードレス全許可で sudo -v が成功し、
# TTY が無いので SSH のホスト鍵プロンプトも出ない）。挙動テストが書けないため、
# 修正が消えたことを文字列で検知する tripwire を置く。**消さないこと。**
# **コメント行を除外した実行行だけを見ること。** 説明コメントに検査語が含まれるため、
# 素の grep だと「なぜ必要かのコメントは残し、実行行からオプションだけ外す」という
# 最もありがちな劣化を検知できない（節 10-5 と同型の穴）。
bootstrap_code() { grep -v '^[[:space:]]*#' "$DOTFILES_DIR/install/bootstrap.sh"; }

if bootstrap_code | grep -q -- '--bin-dir'; then
	pass "starship の導入先が明示されている（sudo -v による停止を回避）"
else
	fail "starship の --bin-dir 指定が消えている（/usr/local/bin だと sudo -v で無限停止する）"
fi
if bootstrap_code | grep -q 'BatchMode=yes' && bootstrap_code | grep -q 'GIT_TERMINAL_PROMPT=0'; then
	pass "clone が非対話（SSH ホスト鍵プロンプトで停止しない）"
else
	fail "clone の非対話指定が消えている（未知ホストのプロンプトで無限停止する）"
fi
# gpg も同クラス。鍵ファイルが既存だと上書き確認で停止する。
gpg_lines=$(bootstrap_code | grep -c 'gpg --dearmor' || true)
gpg_safe=$(bootstrap_code | grep 'gpg --dearmor' | grep -c -- '--batch' || true)
if [ "$gpg_lines" -eq 0 ] || [ "$gpg_lines" -eq "$gpg_safe" ]; then
	pass "gpg --dearmor はすべて非対話（--batch 付き・${gpg_safe}/${gpg_lines}）"
else
	fail "gpg --dearmor に --batch の無い行がある（鍵の上書き確認で無限停止する）"
fi

# 10-7. Aptfile を実際にパースできること。
# セクション見出しの grep だけでは不十分。実機で「テスト全緑なのにパッケージ 0 個」が
# 起きうる（例: セクション行だけ CRLF 化すると grep '^\[wsl\]' は通るがパースは落ちる）。
# bootstrap.sh の get_packages と同一ロジックで実行結果を検査する。
if [ -f "$APTFILE" ]; then
	if grep -q $'\r' "$APTFILE"; then
		fail "Aptfile に CR が混入している（パーサがセクションを認識できなくなる）"
	else
		pass "Aptfile に CR の混入なし"
	fi
	parse_aptfile() {
		local target="$1" section="" line
		while IFS= read -r line; do
			[[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
			if [[ "$line" =~ ^\[([a-z-]+)\]$ ]]; then section="${BASH_REMATCH[1]}"; continue; fi
			[[ "$section" == "$target" ]] && echo "$line"
		done < "$APTFILE"
	}
	wsl_list="$(parse_aptfile wsl)"
	linux_list="$(parse_aptfile linux)"
	wsl_n=$(printf '%s\n' "$wsl_list" | grep -c . || true)
	linux_n=$(printf '%s\n' "$linux_list" | grep -c . || true)
	if [ "$wsl_n" -gt 0 ] && printf '%s\n' "$wsl_list" | grep -qx 'zsh' && printf '%s\n' "$wsl_list" | grep -qx 'git'; then
		pass "Aptfile [wsl] をパースできる（${wsl_n} 件・zsh/git を含む）"
	else
		fail "Aptfile [wsl] のパース結果が不正（${wsl_n} 件）"
	fi
	if printf '%s\n' "$linux_list" | grep -qx 'xclip' && printf '%s\n' "$linux_list" | grep -qx 'xdg-utils'; then
		pass "Aptfile [linux] をパースできる（${linux_n} 件・xclip/xdg-utils を含む）"
	else
		fail "Aptfile [linux] のパース結果が不正（${linux_n} 件）"
	fi
	# WSL は [wsl] のみを入れる設計。GUI アプリが [wsl] に紛れ込むと WSL に入ってしまう。
	if printf '%s\n' "$wsl_list" | grep -qxE 'code|google-chrome-stable|ghostty|xclip|xdg-utils'; then
		fail "[linux] 専用のパッケージが [wsl] に混入している（WSL に GUI アプリが入る）"
	else
		pass "[wsl] に純 Linux 専用パッケージの混入なし"
	fi
fi
echo ""

# ==========================================
# サマリー
# ==========================================
echo "========================================"
echo " テスト結果サマリー"
echo "========================================"
printf " PASS: %d\n" "$PASS"
printf " WARN: %d\n" "$WARN"
printf " FAIL: %d\n" "$FAIL"
echo "========================================"

if [ "$FAIL" -gt 0 ]; then
	echo " → FAIL があります。bootstrap.sh 実行前に修正してください。"
	exit 1
else
	echo " → 問題なし。bootstrap.sh を安全に実行できます。"
	exit 0
fi

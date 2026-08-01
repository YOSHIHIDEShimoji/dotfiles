#!/usr/bin/env bash
# test_wsl_behavior.sh — WSL/Linux 分岐の「挙動」テスト
#
# なぜ構文チェックでは足りないか:
#   実機 WSL で見つかった退行のうち2件は、修正を revert しても構文的に正当なため
#   zsh -n も dry-run も緑のまま通ってしまう。
#     (1) explorer.exe は成功時でも終了コード 1 を返す。`|| true` が無いと
#         o/ghopen/word/excel/powerpoint が「開いているのに失敗扱い」になる
#     (2) dump は macOS 以外で VS Code 拡張の manifest を書き出してはいけない
#         （WSL の code は Windows 側に解決され、純 Linux は Linux 側の一覧を返す。
#           どちらも Mac が正典として持つ vscode/extensions.txt を潰す）
#
# そこで Windows 側コマンドをスタブに差し替えて実際に関数を実行し、結果を検証する。
# Linux でのみ意味を持つため、macOS ではスキップする。

set -uo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PASS=0; FAIL=0
pass() { echo "[PASS] $*"; PASS=$((PASS + 1)); }
fail() { echo "[FAIL] $*"; FAIL=$((FAIL + 1)); }

if [ "$(uname)" = "Darwin" ]; then
	echo "macOS のためスキップ（このテストは Linux/WSL 分岐が対象）"
	exit 0
fi
if ! command -v zsh >/dev/null 2>&1; then
	echo "zsh が無いためスキップ"
	exit 0
fi

# ─── スタブ環境の構築 ───────────────────────────────────────
STUB="$(mktemp -d)"
WORK="$(mktemp -d)"
cleanup() { chmod -R u+w "$STUB" "$WORK" 2>/dev/null; command rm -rf "$STUB" "$WORK"; }
trap cleanup EXIT

# explorer.exe: 実機と同じく「成功しても終了コード 1」を再現する
cat > "$STUB/explorer.exe" <<'EOF'
#!/bin/sh
echo "explorer.exe called: $*" >> "$STUB_LOG"
exit 1
EOF
# wslpath: 引数をそのまま返す
cat > "$STUB/wslpath" <<'EOF'
#!/bin/sh
shift 2>/dev/null || true
echo "$@"
EOF
# code: 固定の拡張一覧を返す（実機と異なる内容であることが重要）
cat > "$STUB/code" <<'EOF'
#!/bin/sh
echo "stub.extension-from-linux"
EOF
chmod +x "$STUB/explorer.exe" "$STUB/wslpath" "$STUB/code"
export STUB_LOG="$WORK/stub.log"; : > "$STUB_LOG"

run_fn() {
	# $1: WSL_DISTRO_NAME の値（空なら純 Linux 相当）, $2: 実行する zsh コード
	local distro="$1"; shift
	PATH="$STUB:$PATH" WSL_DISTRO_NAME="$distro" DOTFILES="$WORK/dotfiles" \
		zsh -f -c "fpath=($DOTFILES_DIR/zsh/functions \$fpath); autoload -Uz o ghopen word excel powerpoint dump; $*" \
		</dev/null 2>&1
}

echo "========================================"
echo " WSL/Linux 挙動テスト"
echo "========================================"

# ─── 1. explorer.exe の終了コードを握りつぶしているか ───────
echo "--- [1] explorer.exe の終了コード ---"
for fn in o ghopen; do
	if run_fn Ubuntu "$fn https://example.com >/dev/null; exit \$?"; then
		pass "$fn が成功を返す（explorer.exe の exit 1 に引きずられない）"
	else
		fail "$fn が失敗を返す（explorer.exe は成功時も exit 1。|| true が必要）"
	fi
done

# word/excel/powerpoint はテンプレートから生成するので DOTFILES を用意する
mkdir -p "$WORK/dotfiles/templates"
for ext in docx xlsx pptx; do : > "$WORK/dotfiles/templates/template.$ext"; done
for fn in word excel powerpoint; do
	if run_fn Ubuntu "cd $WORK && $fn t >/dev/null; exit \$?"; then
		pass "$fn が成功を返す"
	else
		fail "$fn が失敗を返す（explorer.exe の exit 1 を握りつぶせていない）"
	fi
done

# 実際に explorer.exe が呼ばれたことも確認する（呼ばずに成功していたら無意味）
if grep -q 'explorer.exe called' "$STUB_LOG"; then
	pass "WSL 分岐が実際に explorer.exe を通っている"
else
	fail "explorer.exe が一度も呼ばれていない（WSL 分岐に入っていない可能性）"
fi

# ─── 2. dump が manifest を壊さないか ───────────────────────
echo ""
echo "--- [2] dump が VS Code 拡張 manifest を書き出さないこと ---"
mkdir -p "$WORK/dotfiles/vscode"
MANIFEST="$WORK/dotfiles/vscode/extensions.txt"
# WSL 相当・純 Linux 相当の両方で検証する（純 Linux では apt が code を入れるため
# ここが macOS 限定でないと manifest が Linux 側の一覧で上書きされる）
for distro in Ubuntu ""; do
	label=$([ -n "$distro" ] && echo "WSL 相当" || echo "純 Linux 相当")
	echo "macos.authoritative-extension" > "$MANIFEST"
	before="$(cat "$MANIFEST")"
	run_fn "$distro" "cd $WORK/dotfiles && dump >/dev/null 2>&1" >/dev/null
	after="$(cat "$MANIFEST")"
	if [ "$before" = "$after" ]; then
		pass "dump が manifest を書き換えない（$label）"
	else
		fail "dump が manifest を上書きした（$label）: '$after'"
	fi
done

echo ""
echo "========================================"
printf " PASS: %d\n" "$PASS"
printf " FAIL: %d\n" "$FAIL"
echo "========================================"
[ "$FAIL" -gt 0 ] && exit 1
exit 0

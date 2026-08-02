#!/usr/bin/env bash
# bootstrap.sh — macOS / Linux(WSL) 共通セットアップ
# パッケージ定義: macOS = install/Brewfile ／ Linux = install/Aptfile
#
# 設計方針（docs/platform-notes.md 参照）:
#   - スクリプトは1本。OS 固有処理だけを分岐に閉じ込め、共通処理は分岐の外に置く。
#     2本立てにすると片方に入った改善がもう片方に届かず乖離する（#32 以前が実際にそうだった）。
#   - 配置パスは両 OS とも ~/dotfiles。OS でディレクトリ名を変えない。

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# インストール先を即座に command -v で検出できるようにする
export PATH="$HOME/.local/bin:$PATH"

# ─── ヘルパー ───────────────────────────────────────────────
info() { echo "[INFO]  $*"; }
warn() { echo "[WARN]  $*"; }

# ─── OS 判定 ────────────────────────────────────────────────
IS_MAC=false
IS_WSL=false
[[ "$(uname)" == "Darwin" ]] && IS_MAC=true
if [[ "$IS_MAC" == false ]]; then
	[[ -n "$WSL_DISTRO_NAME" ]] || grep -qi microsoft /proc/version 2>/dev/null && IS_WSL=true
fi

# ─── ログ設定 ───────────────────────────────────────────────
LOG_FILE="/tmp/bootstrap-$(date +%Y%m%d-%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1
info "ログを保存中: $LOG_FILE"
trap 'echo "" >&2; echo "エラーが発生しました。ログを確認してください:" >&2; echo "  $LOG_FILE" >&2' ERR

# ─── 前提チェック: envsubst ─────────────────────────────────
# links.prop の ${HOME} 展開に必須。欠けたまま進むと dst が空文字になり静かに壊れる（#22）。
# macOS 標準には無く、Linux も最小構成では入っていないことがある。
if ! command -v envsubst >/dev/null 2>&1; then
	if [[ "$IS_MAC" == true ]]; then
		echo "envsubst が見つかりません。'brew install gettext' を実行してから再試行してください。" >&2
		exit 1
	fi
	info "envsubst が無いため gettext-base をインストールします..."
	sudo apt-get update -y
	sudo apt-get install -y gettext-base
fi

# ─── links.prop からシンボリックリンクを作る（共通機構）──────
link_from_prop() {
	dir="$1"
	prop="$DOTFILES_DIR/$dir/links.prop"

	[ -f "$prop" ] || return

	while IFS= read -r line; do
		# 空行・コメントをスキップ
		[[ -z "$line" || "$line" =~ ^# ]] && continue

		# awk で '->' で分割して source と destination を取得
		src=$(echo "$line" | awk -F'->' '{print $1}' | xargs)
		dst=$(echo "$line" | awk -F'->' '{print $2}' | xargs | envsubst)

		# 空文字チェック
		[ -n "$dst" ] || { echo "Invalid dst in $prop: $line" >&2; continue; }
		[ -n "$src" ] || { echo "Invalid src in $prop: $line" >&2; continue; }

		src_path="$DOTFILES_DIR/$dir/$src"

		# 既存ファイルがある場合はバックアップ
		if [ -e "$dst" ] && [ ! -L "$dst" ]; then
			info "既存ファイルをバックアップ: $dst -> $dst.backup"
			mv "$dst" "$dst.backup"
		fi

		# リンク先の親ディレクトリを作成
		mkdir -p "$(dirname "$dst")"

		# -n: dst が既存のディレクトリ symlink でも辿らず置換する（辿ると中に
		#     リンクが増殖する＝#22。skills/iCloud などディレクトリを指す dst で顕在化）
		info "リンク作成: $src_path -> $dst"
		ln -sfnv "$src_path" "$dst"
	done < "$prop"
}

# ════════════════════════════════════════════════════════════
#  Linux 固有: apt パッケージのインストール
# ════════════════════════════════════════════════════════════
if [[ "$IS_MAC" == false ]]; then
	# Aptfile の [wsl] / [linux] セクションから対象パッケージを取得する。
	#   WSL      → [wsl] のみ
	#   純 Linux → [wsl] + [linux]（GUI アプリ等）
	get_packages() {
		local target="$1"
		local section="" line
		local aptfile="$DOTFILES_DIR/install/Aptfile"
		[[ -f "$aptfile" ]] || return

		while IFS= read -r line; do
			[[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
			if [[ "$line" =~ ^\[([a-z-]+)\]$ ]]; then
				section="${BASH_REMATCH[1]}"
				continue
			fi
			[[ "$section" == "$target" ]] && echo "$line"
		done < "$aptfile"
	}

	mapfile -t wsl_pkgs < <(get_packages "wsl")
	if [[ "$IS_WSL" == false ]]; then
		mapfile -t linux_pkgs < <(get_packages "linux")
		all_pkgs=("${wsl_pkgs[@]}" "${linux_pkgs[@]}")
	else
		all_pkgs=("${wsl_pkgs[@]}")
	fi

	# 公式 apt に含まれないパッケージはリポジトリを事前追加する
	info "追加リポジトリを確認します..."
	sudo mkdir -p /etc/apt/keyrings

	for pkg in "${all_pkgs[@]}"; do
		case "$pkg" in
			eza)
				if ! apt-cache show eza &>/dev/null 2>&1; then
					info "eza: 公式 deb リポジトリを追加します..."
					wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
						| sudo gpg --dearmor --batch --yes -o /etc/apt/keyrings/gierens.gpg
					echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
						| sudo tee /etc/apt/sources.list.d/gierens.list
					sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
				fi
				;;
			ghostty)
				if ! apt-cache show ghostty &>/dev/null 2>&1; then
					info "ghostty: apt.ghostty.org リポジトリを追加します..."
					curl -fsSL https://apt.ghostty.org/gpg.key \
						| sudo gpg --dearmor --batch --yes -o /etc/apt/keyrings/ghostty-archive-keyring.gpg
					echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/ghostty-archive-keyring.gpg] https://apt.ghostty.org/ any main" \
						| sudo tee /etc/apt/sources.list.d/ghostty.list
				fi
				;;
			code)
				if ! apt-cache show code &>/dev/null 2>&1; then
					info "VS Code: packages.microsoft.com リポジトリを追加します..."
					wget -qO- https://packages.microsoft.com/keys/microsoft.asc \
						| sudo gpg --dearmor --batch --yes -o /etc/apt/keyrings/packages.microsoft.gpg
					echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
						| sudo tee /etc/apt/sources.list.d/vscode.list
				fi
				;;
			google-chrome-stable)
				if ! apt-cache show google-chrome-stable &>/dev/null 2>&1; then
					info "Google Chrome: dl.google.com リポジトリを追加します..."
					wget -qO- https://dl.google.com/linux/linux_signing_key.pub \
						| sudo gpg --dearmor --batch --yes -o /etc/apt/keyrings/google-chrome.gpg
					echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/google-chrome.gpg] https://dl.google.com/linux/chrome/deb/ stable main" \
						| sudo tee /etc/apt/sources.list.d/google-chrome.list
				fi
				;;
			gh)
				if ! apt-cache show gh &>/dev/null 2>&1; then
					info "GitHub CLI: cli.github.com リポジトリを追加します..."
					wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg \
						| sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
					sudo chmod 644 /etc/apt/keyrings/githubcli-archive-keyring.gpg
					echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
						| sudo tee /etc/apt/sources.list.d/github-cli.list
				fi
				;;
		esac
	done

	# zsh は Aptfile に含まれるが、chsh より前に確実に入れる
	if ! command -v zsh &>/dev/null; then
		info "zsh を先行インストールします..."
		sudo apt-get update -y
		sudo apt-get install -y zsh
	fi

	ZSH_PATH="$(which zsh)"
	if [ "$SHELL" != "$ZSH_PATH" ]; then
		info "デフォルトシェルを zsh に変更します: $ZSH_PATH"
		sudo chsh -s "$ZSH_PATH" "$USER"
		warn "シェル変更の反映にはログアウト・再ログインが必要です。"
	fi

	info "パッケージをインストールします: ${all_pkgs[*]}"
	sudo apt-get update -y
	sudo apt-get install -y "${all_pkgs[@]}"

	# Debian 系では fd/bat が fdfind/batcat という名前で入る
	if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
		mkdir -p "$HOME/.local/bin"
		ln -sf "$(which fdfind)" "$HOME/.local/bin/fd"
		info "fd -> fdfind のシンボリックリンクを作成しました。"
	fi
	if command -v batcat &>/dev/null && ! command -v bat &>/dev/null; then
		mkdir -p "$HOME/.local/bin"
		ln -sf "$(which batcat)" "$HOME/.local/bin/bat"
		info "bat -> batcat のシンボリックリンクを作成しました。"
	fi

	# apt に無いものを個別導入。
	# 導入先は ~/.local/bin（exports.sh で PATH 済み）に固定し、sudo を経由させない。
	# 既定の /usr/local/bin を使うと starship のインストーラが `sudo -v` を呼び、
	# NOPASSWD 設定下でも「interactive authentication is required」で停止する
	# （sudo -v はコマンド実行ではなく認証情報の検証のため NOPASSWD の対象外）。
	# 無人セットアップを止めないために、書き込みに特権が要らない場所へ入れる。
	mkdir -p "$HOME/.local/bin"
	if ! command -v starship &>/dev/null; then
		info "starship をインストールします..."
		curl -sS https://starship.rs/install.sh | sh -s -- --yes --bin-dir "$HOME/.local/bin"
	fi
	if ! command -v zoxide &>/dev/null; then
		info "zoxide をインストールします..."
		# zoxide のインストーラは既定で ~/.local/bin に入れる（sudo 不要）
		curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
	fi
	if ! command -v tldr &>/dev/null; then
		info "tldr をインストールします..."
		# npm の -g 先も特権不要な場所に向ける（sudo npm を避ける）
		npm config set prefix "$HOME/.local" 2>/dev/null || true
		npm install -g tldr || warn "tldr のインストールに失敗しました（任意ツールのため続行）"
	fi

	# git-delta: gitconfig の pager = delta が要求する。無いと git のページャ出力が毎回エラーになる（#23）。
	# apt に無いため GitHub Releases の .deb から導入する。
	if ! command -v delta &>/dev/null; then
		info "git-delta をインストールします（GitHub Releases）..."
		delta_arch="$(dpkg --print-architecture)"
		delta_ver="$(curl -fsSL https://api.github.com/repos/dandavison/delta/releases/latest \
			| grep -m1 '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')"
		if [[ -n "$delta_ver" ]]; then
			delta_deb="git-delta_${delta_ver}_${delta_arch}.deb"
			delta_url="https://github.com/dandavison/delta/releases/download/${delta_ver}/${delta_deb}"
			delta_tmp="$(mktemp -d)"
			if curl -fsSL -o "$delta_tmp/$delta_deb" "$delta_url"; then
				sudo dpkg -i "$delta_tmp/$delta_deb" || sudo apt-get install -f -y
				info "git-delta ${delta_ver} (${delta_arch}) をインストールしました。"
			else
				warn "git-delta の .deb 取得に失敗しました（${delta_url}）。手動導入してください。"
			fi
		else
			warn "git-delta の最新バージョン取得に失敗しました。手動導入してください。"
		fi
	fi

	# dust: d エイリアスが使う（apt に無いため GitHub Releases の .deb から導入）。
	# アセット名はタグ v1.2.4 → du-dust_1.2.4-1_amd64.deb の形式（実測確認済み）。
	if ! command -v dust &>/dev/null; then
		info "dust をインストールします（GitHub Releases）..."
		dust_arch="$(dpkg --print-architecture)"
		dust_ver="$(curl -fsSL https://api.github.com/repos/bootandy/dust/releases/latest \
			| grep -m1 '"tag_name"' | sed -E 's/.*"v?([^"]+)".*/\1/')"
		if [[ -n "$dust_ver" ]]; then
			dust_deb="du-dust_${dust_ver}-1_${dust_arch}.deb"
			dust_url="https://github.com/bootandy/dust/releases/download/v${dust_ver}/${dust_deb}"
			dust_tmp="$(mktemp -d)"
			if curl -fsSL -o "$dust_tmp/$dust_deb" "$dust_url"; then
				sudo dpkg -i "$dust_tmp/$dust_deb" || sudo apt-get install -f -y
				info "dust ${dust_ver} (${dust_arch}) をインストールしました。"
			else
				warn "dust の .deb 取得に失敗しました（${dust_url}）。任意ツールのため続行します。"
			fi
		else
			warn "dust の最新バージョン取得に失敗しました。任意ツールのため続行します。"
		fi
	fi

	# uv: Brewfile と揃える（apt に無いため公式スクリプト。~/.local/bin に入り sudo 不要）
	if ! command -v uv &>/dev/null; then
		info "uv をインストールします..."
		curl -LsSf https://astral.sh/uv/install.sh | sh || warn "uv の導入に失敗（任意ツールのため続行）"
	fi

	# zsh-you-should-use: apt に無いため git clone で導入（brew 版と同じプラグイン。
	# zshrc が ~/.local/share/zsh-you-should-use をフォールバック探索する）
	YSU_DIR="$HOME/.local/share/zsh-you-should-use"
	if [ ! -d "$YSU_DIR" ]; then
		info "zsh-you-should-use を clone します..."
		git clone -q --depth 1 https://github.com/MichaelAquilina/zsh-you-should-use.git "$YSU_DIR" \
			|| warn "zsh-you-should-use の clone に失敗（任意プラグインのため続行）"
	fi
fi

# ════════════════════════════════════════════════════════════
#  共通: starship テーマの初期化・実行権限
# ════════════════════════════════════════════════════════════
# current.toml は gitignore 対象のため fresh setup では未生成。未生成のまま links.prop で
# リンクすると dangling symlink になり既定プロンプトに落ちるため実体を用意する（sstyle と同じ挙動）。
STARSHIP_DIR="$DOTFILES_DIR/zsh/starship"
if [ ! -f "$STARSHIP_DIR/current.toml" ] && [ -f "$STARSHIP_DIR/tokyo-night.toml" ]; then
	info "starship テーマを初期化します: tokyo-night"
	cp "$STARSHIP_DIR/tokyo-night.toml" "$STARSHIP_DIR/current.toml"
	echo "tokyo-night" > "$STARSHIP_DIR/.current-name"
fi

# scripts/bin を実行可能にする（シェル起動時の chmod を廃止したため、ここで一度だけ実行）
[ -d "$DOTFILES_DIR/scripts/bin" ] && chmod -R +x "$DOTFILES_DIR/scripts/bin" 2>/dev/null || true

# ════════════════════════════════════════════════════════════
#  シンボリックリンク（グループの取捨は OS 依存）
# ════════════════════════════════════════════════════════════
# karabiner/vscode/ghostty の links.prop は宛先が ~/Library/... 固定のため、
# Linux で回すと偽の ~/Library ツリーとダングリングリンクを作る。回さない。
info "シンボリックリンクを作成します..."
link_from_prop zsh
link_from_prop git
link_from_prop tmux
link_from_prop ssh
link_from_prop claude

if [[ "$IS_MAC" == true ]]; then
	link_from_prop karabiner
	link_from_prop vscode
	link_from_prop ghostty
fi

# ~/.claude/skills -> ~/.agents/skills の恒久リンク（cc-skills-sync 不要）
# -n: 既存のディレクトリ symlink を辿らず置換（再実行で中に自己参照リンクを作らない＝#22）
ln -sfnv "${HOME}/.agents/skills" "${HOME}/.claude/skills"

# ════════════════════════════════════════════════════════════
#  共通: マシン固有ファイルのシード
# ════════════════════════════════════════════════════════════
# ControlMaster のソケットディレクトリを作成
mkdir -p "${HOME}/.ssh/cm"
chmod 700 "${HOME}/.ssh/cm"

# マシン固有ホスト定義（~/.ssh/config.local）を未存在時にテンプレートからシード（#16）。
# 実 IP・ユーザー名は追跡対象外のこのファイルに書く（ssh/config が Include する）。
if [ ! -f "${HOME}/.ssh/config.local" ] && [ -f "${DOTFILES_DIR}/ssh/config.local.example" ]; then
	cp "${DOTFILES_DIR}/ssh/config.local.example" "${HOME}/.ssh/config.local"
	chmod 600 "${HOME}/.ssh/config.local"
	info "seeded ~/.ssh/config.local (Host win 等のマシン固有ホストをここに記入)"
fi

# マシン/アカウント固有の Claude ローカルルール（~/.claude/CLAUDE.local.md）を
# 未存在時にテンプレートからシード（#30）。claude/CLAUDE.md の @CLAUDE.local.md が読み込む。
mkdir -p "${HOME}/.claude"
if [ ! -f "${HOME}/.claude/CLAUDE.local.md" ] && [ -f "${DOTFILES_DIR}/claude/CLAUDE.local.md.example" ]; then
	cp "${DOTFILES_DIR}/claude/CLAUDE.local.md.example" "${HOME}/.claude/CLAUDE.local.md"
	info "seeded ~/.claude/CLAUDE.local.md (プロジェクト名・Vault 実パス等の固有情報をここに記入)"
fi

# ════════════════════════════════════════════════════════════
#  macOS 固有: LaunchAgents / pmset / iCloud / Homebrew
# ════════════════════════════════════════════════════════════
if [[ "$IS_MAC" == true ]]; then
	LAUNCH_SRC="$DOTFILES_DIR/LaunchAgents"
	LAUNCH_DST="${HOME}/Library/LaunchAgents"

	if [ -d "$LAUNCH_SRC" ]; then
		info "Setting up LaunchAgents..."
		mkdir -p "$LAUNCH_DST"

		# *.plist が一つもない場合の対策
		shopt -s nullglob

		for plist in "$LAUNCH_SRC"/*.plist; do
			filename=$(basename "$plist")
			target="$LAUNCH_DST/$filename"

			info "Linking LaunchAgent: $filename"
			ln -sfnv "$plist" "$target"

			# 新しい Mac で実行した場合など、未ロードならロードする
			if ! launchctl list | grep -q "${filename%.plist}"; then
				info "  -> Loading $filename"
				launchctl load "$target" 2>/dev/null || true
			fi
		done
		shopt -u nullglob
	fi

	# pmset をパスワードなしで実行するための設定
	SUDOERS_FILE="/private/etc/sudoers.d/lowpowermode"
	if [ ! -f "$SUDOERS_FILE" ]; then
		info "Setting up passwordless pmset..."
		# sudo の認証をキャッシュ更新（必要ならここでパスワードを聞かれる）
		sudo -v
		echo "${USER} ALL=(ALL) NOPASSWD: /usr/bin/pmset" | sudo tee "$SUDOERS_FILE" > /dev/null
		# sudoers ファイルの権限は 440 にする
		sudo chmod 440 "$SUDOERS_FILE"
	else
		info "pmset sudoers rule already exists. Skipping."
	fi

	# ~/iCloud -> iCloud Drive のショートカット
	# -n 必須: これが無いと再実行時に iCloud Drive 実体の中へリンクが作られ全デバイスへ同期される（#22）
	ln -sfnv "${HOME}/Library/Mobile Documents/com~apple~CloudDocs" "${HOME}/iCloud"

	# 権限を追加
	chmod go-w /opt/homebrew/share || true

	# Homebrew パッケージのインストール
	BREWFILE="$DOTFILES_DIR/install/Brewfile"
	if command -v brew &>/dev/null && [ -f "$BREWFILE" ]; then
		info "Installing packages via Brewfile..."
		# 非致命にする。cask には特権 installer や GUI 操作を要するものがあり
		# （例: google-japanese-ime の pkg installer）、その1つが失敗しただけで
		# set -e により bootstrap 全体が中断し、以降の pyenv venv・my-projects clone・
		# welcome に到達しなくなる。Linux 側が個別ツールの失敗を warn で流すのと揃える。
		# 失敗したパッケージは最後にまとめて表示し、握りつぶさない。
		if brew bundle --file="$BREWFILE"; then
			info "Brew installation completed."
		else
			warn "Brewfile の一部が導入できませんでした（続行します）。"
			warn "  未導入分の確認: brew bundle check --file=$BREWFILE --verbose"
		fi
	else
		warn "Homebrew not found or Brewfile missing. Skipping package install."
	fi
fi

# ════════════════════════════════════════════════════════════
#  VS Code 拡張機能
# ════════════════════════════════════════════════════════════
# WSL では Windows 側の VS Code を Remote-WSL 経由で使うため、WSL 内には入れない。
# 参考: https://learn.microsoft.com/ja-jp/windows/wsl/tutorials/wsl-vscode
EXTFILE="$DOTFILES_DIR/vscode/extensions.txt"
if [[ "$IS_WSL" == true ]]; then
	info "WSL のため VS Code 拡張機能のインストールをスキップします。"
	info "Windows 側の VS Code に Remote Development 拡張機能パックを導入してください。"
elif [ -f "$EXTFILE" ] && command -v code &>/dev/null; then
	info "Installing VS Code extensions..."
	xargs -L 1 code --install-extension < "$EXTFILE"
fi

# ════════════════════════════════════════════════════════════
#  共通: pyenv / scripts 用 venv / my-projects
# ════════════════════════════════════════════════════════════
# macOS では Brewfile が pyenv を入れる。Linux は pyenv.run から導入する。
if [[ "$IS_MAC" == false ]] && [ ! -d "$HOME/.pyenv" ]; then
	info "pyenv をインストールします..."
	curl https://pyenv.run | bash
	export PYENV_ROOT="$HOME/.pyenv"
	export PATH="$PYENV_ROOT/bin:$PATH"
fi

# scripts/bin の Python ツール用 venv を用意する（#25）。
# excel2csv 等は shebang で PYENV_VERSION=dotfiles-scripts-3.11.9 を固定しており、
# この venv に pandas/openpyxl 等（requirements.txt）が入っている必要がある。
if command -v pyenv >/dev/null 2>&1; then
	SCRIPTS_ENV="dotfiles-scripts-3.11.9"
	PY_VERSION="3.11.9"
	REQ_FILE="$DOTFILES_DIR/scripts/requirements.txt"
	export PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"
	if ! pyenv versions --bare | grep -qx "$PY_VERSION"; then
		info "pyenv: Python $PY_VERSION をインストールします..."
		pyenv install -s "$PY_VERSION"
	fi
	if ! pyenv versions --bare | grep -qx "$SCRIPTS_ENV"; then
		info "pyenv: venv $SCRIPTS_ENV を作成します..."
		pyenv virtualenv "$PY_VERSION" "$SCRIPTS_ENV"
	fi
	if [ -f "$REQ_FILE" ]; then
		info "pyenv: scripts の依存を $SCRIPTS_ENV にインストールします..."
		"$PYENV_ROOT/versions/$SCRIPTS_ENV/bin/pip" install -q -r "$REQ_FILE" || \
			warn "pip install に失敗。手動で確認してください。"
	fi
else
	warn "pyenv が見つからないため scripts 用 venv の作成をスキップしました（excel2csv 等は動きません）。"
fi

# my-projects のクローン
MY_PROJECTS="$HOME/my-projects"
mkdir -p "$MY_PROJECTS"

clone_if_missing() {
	local repo="$1"
	local dest="$MY_PROJECTS/$(basename "$repo" .git)"
	if [ -d "$dest" ]; then
		info "Already exists: $dest"
		return
	fi
	# SSH 鍵が無い環境（新規 WSL 等）でも止まらないよう HTTPS にフォールバックする。
	# 対象は public リポジトリなので鍵なしで clone できる。
	#
	# SSH 側は必ず非対話で即失敗させること。既定のままだと未知ホストで
	# 「Are you sure you want to continue connecting?」を TTY に出して待ち続ける
	# （このプロンプトは stderr のリダイレクトでは抑止できない）。
	#   BatchMode=yes              … パスフレーズ/確認を一切聞かない
	#   StrictHostKeyChecking=accept-new … 初回のホスト鍵は自動登録（後で鍵を入れれば SSH が通る）
	#   GIT_TERMINAL_PROMPT=0      … git 側の資格情報プロンプトも抑止
	info "Cloning $repo -> $dest"
	GIT_TERMINAL_PROMPT=0 \
	GIT_SSH_COMMAND="ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=10" \
		git clone "git@github.com:YOSHIHIDEShimoji/${repo}.git" "$dest" 2>/dev/null \
		|| GIT_TERMINAL_PROMPT=0 git clone "https://github.com/YOSHIHIDEShimoji/${repo}.git" "$dest" \
		|| warn "clone に失敗: $repo（後で手動取得してください）"
}

clone_if_missing spotify-playlist-tools

# ─── 完了 ───────────────────────────────────────────────────
echo ""
echo "════════════════════════════════════════════════"
echo " セットアップ完了"
echo "════════════════════════════════════════════════"
if [[ "$IS_MAC" == false ]]; then
	echo " ターミナルを開き直してください（pyenv / starship の反映に必要）"
	echo ""
fi
echo " オプションのインストール（必要な場合のみ実行）"
if [[ "$IS_MAC" == true ]]; then
	echo "   zsh install/install-mactex-ja.zsh              # MacTeX 日本語環境"
fi
echo "   bash install/cli-tools/install-claude-code.sh  # Claude Code"
echo "   bash install/cli-tools/install-gemini-cli.sh   # Gemini CLI"
echo "   bash install/cli-tools/install-codex.sh        # Codex"
echo "   bash install/setup-john-wordlists.sh           # John/Hashcat ワードリスト"
if [[ "$IS_WSL" == true ]]; then
	echo ""
	echo " WSL 向け追加セットアップ（Windows 側で実施）:"
	echo "   [Nerd Fonts] starship のアイコン表示に必須"
	echo "     https://www.nerdfonts.com/font-downloads から .ttf を導入し、"
	echo "     Windows Terminal → 設定 → WSL プロファイル → 外観 → フォントフェイスで選択"
	echo "   [VS Code] ms-vscode-remote.vscode-remote-extensionpack を Windows 側に導入"
fi
echo "════════════════════════════════════════════════"

# ─── ウェルカム表示 ─────────────────────────────────────────
zsh "$DOTFILES_DIR/install/welcome.sh"

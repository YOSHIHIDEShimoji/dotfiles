# docs/platform-notes.md

**単一 repo・単一 `main` ブランチで macOS と Linux(WSL) の両方を賄うための、OS 固有ファイル/関数の参照表。**

## 経緯

2026-07-08 に2本ブランチ運用（`linux` ブランチ + `git worktree` + `/sync-to-linux`）を廃止し、単一 `main` が両 OS をカバーする構成にした。2026-07-10（#32）に「WSL 不使用が確定した」として Linux/WSL 対応を一度全撤去したが、2026-08-02 に WSL 環境を再構築したため前提が失効し、復元した。

復元時に旧構成の2つの負債を解消している。**この2点は今後も戻さないこと。**

1. **bootstrap を2本立てにしない。** 旧構成は `bootstrap.sh`(Mac) と `bootstrap-linux.sh`(Linux) に分かれており、片方に入った改善がもう片方に届かず実際に乖離した（`~/.ssh/config.local` シード・`CLAUDE.local.md` シード・`my-projects` clone・scripts 用 venv・`~/.ssh/cm`・`link_from_prop ssh`・`envsubst` 前提チェックの7機能が Linux 側だけ欠落していた）。現在は `install/bootstrap.sh` 1本に OS 分岐で統合している。
2. **配置パスを OS で変えない。** 旧構成は Linux 側の `DOTFILES`/`ZDOTDIR` を `~/dotfiles-linux` にしていた（2本ブランチ時代の名残）。現在は両 OS とも `~/dotfiles`。

いずれも `install/test_bootstrap_dry_run.sh` の節[10]と CI の `linux-lint` ジョブが自動検査しており、逆戻りすると落ちる。

**編集時の原則:** 大半のファイルは OS 非依存でそのまま動く。下記の Mac 専用 / Linux 専用の「器」は他 OS では触らない。共有ファイル内の OS 差異は `uname` / `$WSL_DISTRO_NAME` 分岐か `command -v` ガードで吸収し、**全 OS の枝を保つ**。

---

## セットアップ手順（両 OS 共通）

```bash
git clone https://github.com/YOSHIHIDEShimoji/dotfiles.git ~/dotfiles
bash ~/dotfiles/install/bootstrap.sh
```

`bootstrap.sh` が `uname` と `/proc/version` で OS を判定し、macOS なら Homebrew + Brewfile、Linux なら apt + Aptfile の経路を選ぶ。

## Mac 専用（Linux/WSL では未リンク・未使用）

- `ghostty/`・`karabiner/`・`vscode/` — links.prop の宛先が `~/Library/...` 固定。Linux で回すと偽の `~/Library` ツリーとダングリングリンクを作るため、`bootstrap.sh` の macOS 分岐でのみリンクする
- `LaunchAgents/`・`scripts/bookmark/`
- `install/Brewfile`・`install/install-mactex-ja.zsh`
- `zsh/functions/awake`（caffeinate）・`zsh/functions/lp`（pmset）
- `scripts/bin/transcribe`（whisper.cpp + CoreML、Apple Silicon 専用）
- `scripts/bin/launchd_list`・`scripts/lib/launchd_manager.py`（macOS launchd 専用）
- `zsh/aliases.sh` の `moodle` エイリアス（Darwin ガード済み）

**WSL での VS Code:** WSL 内には入れない。Windows 側の VS Code に Remote Development 拡張機能パックを導入し、WSL から `code .` で接続する。

## Linux/WSL 専用（macOS では未使用）

- `install/Aptfile` — apt パッケージ定義（Brewfile 相当）。`[wsl]`（WSL・純 Linux 共通の CLI 群）と `[linux]`（純 Linux のみ = GUI アプリ等）の二層構造。WSL は `[wsl]` のみ、純 Linux は両方を導入する

## 共有ファイル内で OS 分岐しているもの（編集時は全 OS の枝を保つ）

- `install/bootstrap.sh` — `IS_MAC` / `IS_WSL` で分岐。パッケージ経路・LaunchAgents・pmset sudoers・iCloud リンク vs apt リポジトリ追加・`chsh`・`fd`/`bat` 別名リンク・starship/zoxide/delta の個別導入
- `zsh/exports.sh` — PATH（Homebrew/TeX/Java は Mac のみ、WSL は Windows 側 VS Code の bin を追加）
- `zsh/zshrc` — プラグインの探索先（brew の share 配下 / `/usr/share/...`）、fzf 統合（`--zsh` 非対応の古い apt 版はシステム統合ファイルを使う）
- `zsh/aliases.sh` — clipboard（`clip.exe` / `xclip`）
- `zsh/functions/`:
  - `copyfile`・`copypath` — pbcopy / clip.exe(+iconv UTF-16LE) / xclip
  - `o` — open / explorer.exe(+wslpath) / xdg-open
  - `ghopen` — open / explorer.exe / xdg-open
  - `word`・`excel`・`powerpoint` — `open -a`（Mac）/ explorer.exe が既定ハンドラで開く（WSL）/ 純Linux は非対応メッセージ
  - `update` — brew（Mac）/ apt（Linux）
  - `dump` — Brewfile を dump（Mac）/ Aptfile は手動管理のため Linux ではスキップ
  - `rst` — RStudio 起動パス
- `scripts/bin/yt2ob` — 出力先は環境変数 `YT2OB_OUTPUT_DIR` で上書き可（既定は Mac iCloud パス）

## 純Linux と WSL の差

- **clipboard**: WSL = `clip.exe`（+ UTF-16LE iconv）/ 純Linux = `xclip`（Aptfile の `[linux]` セクションで導入）
- **open**: WSL = `explorer.exe` + `wslpath` / 純Linux = `xdg-open`（`xdg-utils`）
- **word/excel/powerpoint**: WSL は Windows 側の Office を `explorer.exe` 経由で開く。純Linux は Office 非対応
- **ghostty**: 純 Linux のみ。ただし `ghostty/links.prop` の宛先は `~/Library/...` 固定のため、純 Linux で使うには宛先を `~/.config/ghostty/config` にする対応が別途必要（既知の未対応。WSL では ghostty を使わないため現状ブロッキングではない）

## 既知の制約

- **GUI アプリ（Chrome / VS Code / ghostty）は WSL には入れない。** Aptfile の `[linux]` セクションに置いてあり、WSL では読み込まれない
- **SSH 鍵が無い環境**（新規 WSL 等）でも `bootstrap.sh` は止まらない。`my-projects` の clone は SSH → HTTPS の順にフォールバックする（対象は public リポジトリ）

# 🚀 dotfiles セットアップガイド

---

## 💡 理念 / Philosophy

- Linux/WSL環境で簡単に開発環境を復元できるようにする
- 必要最小限の設定ファイル (.bashrc, .profile, .gitconfig) をシンボリックリンクで管理
- bash起動時に自動設定を適用
- 自動化できるところは徹底的に自動化
- GitHub認証(ログイン)は手動実行
- `.gitconfig`は[include]のみ記述し、`dotfiles/gitconfig/`配下を編集して管理
- `aliases/`, `exports/`, `functions/`ディレクトリ配下に設定を分割管理し、bash起動時に自動読み込みできる構造

---

## 📂 ディレクトリ構成

```plaintext
dotfiles/
├── install/           # セットアップスクリプト (setup_apt.sh など)
├── scripts/linux/     # Linux用スクリプト (create_series.sh, link_scripts.sh, pushit.sh)
├── aliases/           # Bashエイリアス管理
├── exports/           # 環境変数管理
├── functions/         # Bash関数管理
├── gitconfig/         # Git設定モジュール
├── .bashrc, .profile, .gitconfig
└── README.md          # このガイド
```

---

## 🛠️ セットアップ手順

### 1. GitHub CLIをインストールして認証

```bash
sudo apt update && sudo apt install gh && gh auth login --web --git-protocol ssh
```

- GitHub CLI (gh) をインストール
- ブラウザを使ってGitHub認証を完了

---

### 2. リポジトリをclone

```bash
git clone --branch merge-setup git@github.com:YOSHIHIDEShimoji/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

---

### 3. install.shを実行

```bash
bash install.sh
```

---

### 4. bash設定を再読込

```bash
source ~/.bashrc
```

---

### 5. 📌 ~/.local/bin にスクリプトをリンクする場合

```bash
bash ~/dotfiles/scripts/linux/link_scripts.sh
```

※ `~/.local/bin` をPATHに含めている前提です。

---

## 📜 install.shが行うこと

- `install/setup_apt.sh`を実行し、必要なパッケージ (git, curl, ghなど) をインストール
- `.bashrc`, `.profile`, `.gitconfig` をホームディレクトリにシンボリックリンク
- 既存ファイルがある場合は `.backup` に退避して安全確保

---

## 📖 運用ポリシー

- dotfiles配下以外に不要なファイルを置かない
- 変更があれば必ずdotfilesリポジトリに反映する
- backupファイル (*.backup) は手動管理（自動削除しない）
- `.gitconfig`はincludeベースでモジュール分割管理
- `aliases/`, `exports/`, `functions/`にファイルを置くだけでbash起動時に自動適用
- GitHub認証 (`gh auth login`) は手動で行う

---

## 🛠️ .bashrcによる読み込み仕様

.bashrcには以下のコードが記述されており、各ディレクトリ配下のスクリプトを自動読み込みします。

```bash
# Aliases definitions.
for f in ~/dotfiles/aliases/*.sh; do
  [ -r "$f" ] && . "$f"
done

# Function definitions.
for f in ~/dotfiles/functions/*.sh; do
  [ -r "$f" ] && . "$f"
done

# Exports definitions.
for f in ~/dotfiles/exports/*.sh; do
  [ -r "$f" ] && . "$f"
done
```

これにより、ファイルを追加するだけで自動的に読み込まれます。

---

## ⚠️ 注意事項

- reset.shを実行することによって、元の環境に戻せます。

---

*Designed to streamline, modularize, and simplify environment setup across machines ✨*


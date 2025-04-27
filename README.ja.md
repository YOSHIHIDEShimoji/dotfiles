# 🚀 dotfiles セットアップガイド

---

## 💡 理念 / Philosophy

- Linux/WSL環境で簡単に開発環境を復元できるようにする
- 必要最小限の設定ファイル (.bashrc, .profile, .gitconfig) をシンボリックリンクで管理
- bash起動時に自動設定を適用
- 自動化できるところは尽力自動化
- GitHub証明(ログイン)は手動実行
- `.gitconfig`は[include]のみ記述し、`dotfiles/gitconfig/`配下を編集して管理
- `aliases/`, `exports/`, `functions/`ディレクトリ配下に分割して管理、bash起動時に自動読込

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
├── README.ja.md       # このガイド
└── README.md          # 英語版
```

---

## 🛠️ セットアップ手順

### 1. GitHub CLIをインストールして証明

```bash
sudo apt update && sudo apt install gh && gh auth login --web --git-protocol ssh
```

- GitHub CLI (gh) をインストール
- ブラウザを使ってGitHub証明を完了

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

- 実行すると、最初にGitのユーザー名とメールアドレスが表示されます
- 異なる場合は、入力をもとに`dotfiles/gitconfig/user`が自動書き換えされます

---

### 4. bash設定を再読込

```bash
source ~/.bashrc
```

---

## 📜 install.shが行うこと

- `install/setup_apt.sh`を実行し、git, curl, ghなど必要パッケージをインストール
- Gitのユーザー情報を確認し、必要な場合は`dotfiles/gitconfig/user`を書き換え
- `.bashrc`, `.profile`, `.gitconfig`をホームディレクトリにシンボリックリンク
- 既存ファイルがある場合は`.backup`に送り移し

---

## 📖 運用ポリシー

- dotfiles配下以外に不要なファイルを置かない
- 変更があれば必ずdotfilesリポジトリに反映
- backupファイル (\*.backup)は手動管理
- `.gitconfig`はinclude基本でモジュール分割
- `aliases/`, `exports/`, `functions/`に追加するだけでbash起動時に自動適用
- GitHub証明(`gh auth login`)は手動実行

---

## 🛠️ .bashrcによる読み込み仕様

.bashrcには次のコードが記述されています：

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

これにより、ファイルを追加するだけで自動読込されます

---

## ⚠️ 注意事項

- reset.shは必要な場合のみ使用してください。

---

*Designed to streamline, modularize, and simplify environment setup across machines ✨*


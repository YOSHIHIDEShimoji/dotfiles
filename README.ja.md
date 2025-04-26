# dotfiles セットアップガイド

---

## 理念 / Philosophy

- Linux/WSL環境で立即開発環境を再現する
- 必要最小限の設定ファイルのみを管理する (ターゲット: `.bashrc`, `.profile`, `.gitconfig`)
- bash起動時に自動設定を適用
- シンボリックリンクで一調性を保持
- 自動化で出来ることは尽力自動化
- GitHub証明(`gh auth login`)だけは手動実行

---

## ディレクトリ構成

- `install/` : セットアップスクリプト (setup\_apt.sh 等)
- dotfiles : `.bashrc`, `.profile`, `.gitconfig`
- `README.md` : このガイド

---

## セットアップ手順

### 1. 最初に手動実行

```bash
sudo apt update && sudo apt install gh && gh auth login --web --git-protocol ssh
```

- GitHub CLI (gh)をインストール
- ブラウザでGitHub証明を実行

※ブラウザ操作が必要です

---

### 2. リポジトリをclone

```bash
git clone --branch merge-setup git@github.com:YOSHIHIDEShimoji/dotfiles.git ~/dotfiles
cd ~/dorfiles
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

## install.shが行うこと

- `install/setup_apt.sh`を実行し、git, curl, ghなど必要パッケージをインストール
- 下記ファイルをシンボリックリンク
  - `.bashrc`
  - `.profile`
  - `.gitconfig`
- 既存ファイルがある場合は、自動で.backupに復元
  - 例: `.bashrc` → `.bashrc.backup`

---

## 運用ポリシー

- dotfiles配下以外に不要なファイルを置かない
- 変更があれば必ずdotfilesリポジトリに反映
- backupファイル (\*.backup) は自動削除しない
- GitHub証明(ログイン)は必ず事前に実行

---

## 注意事項

- reset.shは必要な場合のみ使用してください


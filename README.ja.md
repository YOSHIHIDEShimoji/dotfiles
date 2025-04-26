## dotfiles Setup Guide

---

### 【理念 / Philosophy】

- Linux/WSL環境でインストールの復元を楽にする
- bash起動時にカテゴリごとに分割された設定ファイルを自動読込み
- .bashrc, .profile, .gitconfigをシンボリックリンク管理
- 自動化できるところは尽力自動化、だけどGitHub証明だけは手動

---

### 【ディレクトリ構成 / Directory Structure】

- **aliases/** : bashエイリアス設定 (\*.sh)
- **exports/** : 環境変数設定 (\*.sh)
- **functions/** : シェル関数定義 (\*.sh)
- **gitconfig/** : Git設定モジュール
- **install/** : セットアップスクリプト群
- **scripts/linux/** : Linux用個別スクリプト
- **scripts/windows/** : Windows用 (PowerShell/AutoHotkey/BAT)
- **install.sh** : dotfilesセットアップメインスクリプト
- **README.md** : 使用方法説明書

---

### 【スタート前に必ず手動でやること】

最初に下記コマンドを実行してください：

```bash
sudo apt update && sudo apt install gh && gh auth login --web --git-protocol ssh
```

- GitHub CLI (gh)をインストール
- GitHubとの証明を完了

※ 通信にブラウザの手動操作が必要です

---

### 【インストール方法】

1. 上記の手動コマンド完了
2. このリポジトリをclone

```bash
git clone git@github.com:YOSHIHIDEShimoji/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

3. install.shを実行

```bash
bash install.sh
```

- install/setup\_apt.sh
- install/setup\_ssh.sh
- install/setup\_gh.sh

を順番に実行したのち、
bash系のリンク作成などを行います

4. bash環境を再読み込み

```bash
source ~/.bashrc
```

---

### 【.bashrcの読み込み仕様】

- \~/dotfiles/aliases/\*.sh
- \~/dotfiles/exports/\*.sh
- \~/dotfiles/functions/\*.sh
  を自動読込み

→ 新しい設定を追加する場合は、各ディレクトリに.shファイルを置くだけ

---

### 【.gitconfigの読み込み仕様】

- .gitconfig本体には[include]しか記述しない
- gitconfig/配下の alias, core, init, user を読み込む

→ Git設定をモジュール単位で管理

---

### 【リセット(reset.sh)について】

- dotfilesやリンクされたファイルを削除
- .bashrc.backup などのバックアップを復元
- 実行時は自分を/tmpに移してから実行（セーフに実行継続）

※ 安全にクリーンリセット可能

---

### 【注意事項】

- gh auth loginの手動操作はが必要です。

---


この設計思想をもとに、ストレスフリーな環境再現を実現しましょう！


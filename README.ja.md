# dotfiles 環境構築用セットアップ

このリポジトリは、Linux (特に WSL) 環境の開発セットアップを自動化するために設計された `dotfiles` 管理用の構成です。
シンボリックリンクを通して `.bashrc`, `.profile`, `.gitconfig` などを管理し、カテゴリごとの設定ファイルも柔軟に読み込めるようになっています。

---

## 📌 設計思想

### ✅ カテゴリ単位での管理と自動読み込み
- `.bashrc` では、以下のように `aliases/`, `exports/`, `functions/` 以下にある `.sh` ファイルをすべて自動で読み込みます：

```bash
for f in ~/dotfiles/aliases/*.sh; do [ -r "$f" ] && . "$f"; done
for f in ~/dotfiles/exports/*.sh; do [ -r "$f" ] && . "$f"; done
for f in ~/dotfiles/functions/*.sh; do [ -r "$f" ] && . "$f"; done
```

- 各カテゴリごとに設定ファイルを分離できるため、**管理が楽で Git での変更追跡もしやすい**構成です。
- `.bash_aliases`, `.bash_exports`, `.bash_functions` を作る必要はありません。

### ✅ `.gitconfig` のモジュール化
- Git 設定は `gitconfig/` 以下にカテゴリ別に保存され、`.gitconfig` 本体には次のように `[include]` で読み込み指定を行います：

```ini
[include]
    path = ~/dotfiles/gitconfig/alias
    path = ~/dotfiles/gitconfig/core
    path = ~/dotfiles/gitconfig/init
    path = ~/dotfiles/gitconfig/user
```

- これにより Git 設定も変更・再利用・バージョン管理が柔軟に行えます。

### ✅ 関数とスクリプトの役割分担
- `functions/` には、シェル起動時に自動で読み込まれる軽量な関数を定義します。
  - 例：`open()` のようなシンプルな補助関数
- `scripts/` 以下には、プロセスとして実行したいコマンド（重めの処理や自動化用）を記述します。
  - これらは `.local/bin/` にリンクされ、CLIツールとしてどこからでも実行可能です。

このように、**「機能の重さ」「再利用性」「呼ばれ方」** に応じて適切に分類・分離されています。

---

## 🚀 セットアップ方法

### install.sh の動作概要

- ホームディレクトリに既に存在する `.bashrc`, `.profile`, `.gitconfig` をバックアップ（`.backup` にリネーム）
- `dotfiles/` にある同名ファイルへのシンボリックリンクを作成（上書きではなくリンク）
- その後、`install/setup_*.sh` を順番に実行して環境を整備します

以下のコマンドを一発で実行すれば、セットアップが完了します：

```bash
git clone https://github.com/YOUR_USERNAME/dotfiles.git && cd dotfiles && bash install.sh
```

このスクリプトは以下を行います：
- `.bashrc`, `.profile`, `.gitconfig` のシンボリックリンクを作成
- 必要な CLI パッケージのインストール（`apt`, `dnf`, `pacman` などに対応）
- SSH キーの生成と GitHub CLI を使った自動アップロード

---

## 🛠 scripts ディレクトリの補助スクリプト

`scripts/` 以下には、Linux・Windows 環境向けのユーティリティスクリプトをまとめています。
詳細な説明はそれぞれのサブディレクトリ内のスクリプトやコメントをご参照ください。

- `scripts/linux/`：Linux 環境で使える CLI スクリプト（自動リンクやファイル作成など）
- `scripts/windows/`：Windows 向けの AutoHotkey や PowerShell スクリプト

> 詳細は `scripts/README.md` を参照してください。

## 🔧 設定を追加したいときは？

このリポジトリでは設定の分類が明確になっており、以下のように目的に応じてファイルを追加することで拡張できます：

```
.
├── aliases/         # alias の定義（例：ll='ls -la'）
├── exports/         # 環境変数の設定（例：export PATH）
├── functions/       # 軽量な関数定義（例：open 関数）
├── gitconfig/       # Git の設定（alias, user, core など）
└── scripts/
    ├── linux/       # CLI ツールとして使いたいシェルスクリプト
    └── windows/     # Windows 専用スクリプト（AHK, PowerShell など）
```

- 新しい **alias** を追加したい → `aliases/` に `.sh` ファイルを追加
- 新しい **関数** を定義したい → `functions/` に `.sh` ファイルを追加
- `.local/bin/` にリンクしたい **実行スクリプト** を作りたい → `scripts/linux/` に `.sh` を作成して `link_scripts.sh` を実行

このように、それぞれのディレクトリに役割が割り当てられているので、**目的に応じて迷わず拡張できる**構成になっています。

---

## 🧠 その他補足

- `install.sh` の最後に `source ~/.bashrc` を実行することで、即座に環境が反映されます。
- スクリプトは全て Bash で記述され、エラー時は即終了する設計になっています（`set -e`）。
- GitHub CLI の認証で `xdg-open` が失敗した場合も、WSL 環境なら `explorer.exe` によって Windows のブラウザが起動します。

---

この構成は、シンプルで保守しやすく、それでいてスケーラブルな `dotfiles` の構成例として利用できます。


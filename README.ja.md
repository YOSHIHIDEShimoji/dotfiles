# dotfiles 環境構築用セットアップ

このリポジトリは、Linux環境の開発セットアップを自動化するために設計された `dotfiles` 管理用の構成です。
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

## 🚀 セットアップ手順

### ❗注意：一発での完全自動化は不可です
GitHub認証（`gh auth login`）には**ユーザーの手動操作（ブラウザ認証）が必須**です。
そのため、以下のように**ステップごとに実行**してください。

---

### 🧩 Step 1: dotfilesをクローン


```bash
curl -L https://github.com/YOUR_USERNAME/dotfiles/archive/refs/heads/main.tar.gz \
  | tar -xz && cd dotfiles-main
```

---

### 🧩 Step 2: 必要なパッケージをインストール

```bash
bash install/setup_apt.sh
```

これにより以下がインストールされます：

- `gh`（GitHub CLI）
- `git`, `curl`, `vim`, `tree`, `xdg-utils` など基本ツール

---

### 🧩 Step 3: GitHub 認証（手動）

GitHubにSSHキーを登録するには、**最初に GitHub CLI でログインする必要があります**：

```bash
gh auth login --web --git-protocol ssh
```

- 指示に従ってブラウザでログインしてください。
- 完了後、次のステップへ進みます。

---

### 🧩 Step 4: SSHキーの生成

```bash
bash install/setup_ssh.sh
```

- `~/.ssh/id_ed25519` が生成され、`ssh-agent` に追加されます。
- `git config user.email` または環境変数 `EMAIL_FOR_SSH` からメールアドレスを取得。

---

### 🧩 Step 5: GitHub にSSHキーをアップロード

```bash
bash install/setup_gh.sh
```

- すでに認証済みであれば、公開鍵をGitHubに登録します。
- `admin:public_key` スコープの確認と追加認可が必要です（案内あり）。

---

### 🧩 Step 6: dotfilesのインストール

```bash
bash install.sh
```

- `.bashrc`, `.profile`, `.gitconfig` をバックアップし、dotfiles内のものとリンク
- `.bashrc` に記述された以下の構成が有効になります：

```bash
for f in ~/dotfiles/aliases/*.sh; do [ -r "$f" ] && . "$f"; done
for f in ~/dotfiles/exports/*.sh; do [ -r "$f" ] && . "$f"; done
for f in ~/dotfiles/functions/*.sh; do [ -r "$f" ] && . "$f"; done
```

---

### ✅ 最後に

インストール完了後、以下のコマンドを実行して設定を反映：

```bash
source ~/.bashrc
```

また、`.bashrc.backup`, `.profile.backup`, `.gitconfig.backup` などのバックアップファイルは保持するか削除するかをインストール時に選択できます。不要な場合は削除してください。

---

## 🧠 その他補足

- `.gitconfig` は `[include]` 構文で `dotfiles/gitconfig/` 内の設定を読み込みます。
- `scripts/linux/` にある `.sh` ファイルは `link_scripts.sh` を使って `~/.local/bin/` にリンクできます。
- `functions/` や `aliases/` に `.sh` を追加するだけで自動読み込みされます。

---

この構成は、シンプルで保守しやすく、それでいてスケーラブルな `dotfiles` の構成例として利用できます。


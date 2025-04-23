# スクリプト集

このリポジトリは、**Linux用（bash）** と **Windows用（PowerShell／AutoHotkey／batch）** のスクリプトを収録しています。
作業効率化、ファイル自動生成、キーボードカスタマイズ、アプリ起動自動化を目的としています。

---

# ディレクトリ構成

```
.
├── linux
│   ├── create_series.sh
│   ├── link_scripts.sh
│   └── pushit.sh
├── windows
│   ├── 10_create_series_win.ps1
│   ├── F13_main.ahk
│   ├── F14_day_input.ahk
│   ├── F14_execute_10.ahk
│   ├── F14_main.ahk
│   ├── F15_main.ahk
│   ├── scan_code_check.ahk
│   └── Start_Up_Generative_AI.bat
└── README.md
```

---

# Linux用スクリプト（linux/）

### create_series.sh
指定したテンプレートに基づいて、**連番のディレクトリまたはファイルを一括作成**するスクリプトです。
開始値、終了値、ステップ値、ゼロ埋め、プレースホルダ等を指定可能。ドライランモード対応。

---

### link_scripts.sh
現在のディレクトリ以下の `.sh` ファイルを、ホームディレクトリ `~/.local/bin`に**抽出形式でシンボリックリンク**するスクリプトです。

---

### pushit.sh
現在のGitリポジトリで、**変更ファイルをadd → commit → push**まで一括実行するスクリプトです。  
`-m`オプションでコミットメッセージを指定可能。

---

# Windows用スクリプト（windows/）

### 10_create_series_win.ps1
PowerShell版の**連番ディレクトリ／ファイル生成スクリプト**です。
Linux版`create_series.sh`と同等の機能を持ち、ドライランも対応。

---

### F13_main.ahk
F13キー+別のキーで**矩分移動やコピペ操作を高速化**するAutoHotkeyスクリプトです。

---

### F14_day_input.ahk
F14+数字キーで**今日の日付や日曜日付き日付**を一発入力できるスクリプトです。

---

### F14_execute_10.ahk
エクスプローラー上でF14+F13を押すと、**連番生成スクリプト(10_create_series_win.ps1)を実行**するAutoHotkeyスクリプトです。

---

### F14_main.ahk
F14+アルファベットで**よく使うアプリやフォルダを一発起動**するAutoHotkeyスクリプトです。

---

### F15_main.ahk
F15キーで**生成AIツール群を一括起動**するスクリプトです。

---

### scan_code_check.ahk
**キーボードのスキャンコードを確認**するAutoHotkeyスクリプトです。

---

### Start_Up_Generative_AI.bat
Chromeを起動し、**ChatGPT， Gemini， Claude， Copilot， Perplexity,  ChatHub **などの生成AIサービスを**一括でタブ開き**するバッチファイルです。

---

# ワンポイント
- **WindowsのAutoHotkeyスクリプトを自動起動させたい場合**、  
  `C:\Users\[UserName]\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup`
  にスクリプトのショートカットを作成しておくと便利です。

- `.ahk`ファイルを実行するためには、**AutoHotkeyのインストール**が必要です。

---

# 必要環境

| スクリプト種別 | 必要な環境                            |
|:-----------------|:-----------------------------------|
| `.sh`            | bash (Linux, WSL, Git Bashなど)   |
| `.ps1`           | PowerShell                          |
| `.ahk`           | AutoHotkey v1またはv2          |
| `.bat`           | Windowsコマンドプロンプト      |


#!/bin/bash

# Windowsで以下をダウンロード、設定しておく
# Temurin をダウンロード
# Andoroid Studio をダウンロード
# Windowsに環境変数JAVA_HOMEを設定する。
# 上段 変数名： jAVA_HOME 、変数値： C:\Program Files\Eclipse Adoptium\jdk-21.0.7.6-hotspot 
# 下段 変数名： JAVA_HOME 、値： %JAVA_HOME%\bin


# エラーが出たら終了
set -e

# Flutter のセットアップ
cd ~
git clone https://github.com/flutter/flutter.git -b stable
echo 'export PATH="$HOME/flutter/bin:$PATH"' > ~/dotfiles/exports/flutter.sh

# 必要なパッケージのインストール
sudo apt update
sudo apt install -y clang cmake ninja-build libgtk-3-dev openjdk-17-jdk

# Android SDK の設定
ANDROID_SDK_PATH="/mnt/c/Users/gyshi/AppData/Local/Android/Sdk"
echo "export ANDROID_SDK_ROOT=\"$ANDROID_SDK_PATH\"" > ~/dotfiles/exports/ANDROID_SDK_ROOT.sh

# Java の設定
echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64' > ~/dotfiles/exports/JAVA.sh
echo 'export PATH=$JAVA_HOME/bin:$PATH' >> ~/dotfiles/exports/JAVA.sh

# ユーザーの bin ディレクトリを作成
mkdir -p ~/bin
echo 'export PATH="$HOME/bin:$PATH"' > ~/dotfiles/exports/bin.sh

# adb のラッパースクリプト作成
cat <<'EOF' > ~/bin/adb
#!/bin/bash
/mnt/c/Users/gyshi/AppData/Local/Android/Sdk/platform-tools/adb.exe "$@"
EOF
chmod +x ~/bin/adb

# Android SDK の adb ラッパースクリプト作成
cat <<'EOF' > /mnt/c/Users/gyshi/AppData/Local/Android/Sdk/platform-tools/adb
#!/bin/bash
/mnt/c/Users/gyshi/AppData/Local/Android/Sdk/platform-tools/adb.exe "$@"
EOF
chmod +x /mnt/c/Users/gyshi/AppData/Local/Android/Sdk/platform-tools/adb

# aapt のラッパースクリプト作成
cat <<'EOF' > /mnt/c/Users/gyshi/AppData/Local/Android/Sdk/build-tools/35.0.1/aapt
#!/bin/bash
/mnt/c/Users/gyshi/AppData/Local/Android/Sdk/build-tools/35.0.1/aapt.exe "$@"
EOF
chmod +x /mnt/c/Users/gyshi/AppData/Local/Android/Sdk/build-tools/35.0.1/aapt

# sdkmanager のラッパースクリプト作成
cat <<'EOF' > ~/bin/sdkmanager
#!/bin/bash
/mnt/c/Users/gyshi/AppData/Local/Android/Sdk/cmdline-tools/latest/bin/sdkmanager.bat "$@"
EOF
chmod +x ~/bin/sdkmanager

cat <<'EOF' > /mnt/c/Users/gyshi/AppData/Local/Android/Sdk/cmdline-tools/latest/bin/sdkmanager
#!/bin/bash
(cd /mnt/c/Users/gyshi && /mnt/c/Windows/System32/cmd.exe /c "C:\\Users\\gyshi\\AppData\\Local\\Android\\Sdk\\cmdline-tools\\latest\\bin\\sdkmanager.bat" "$@")
EOF
chmod +x /mnt/c/Users/gyshi/AppData/Local/Android/Sdk/cmdline-tools/latest/bin/sdkmanager

# flutter config の設定
flutter config --android-sdk "$ANDROID_SDK_PATH"
flutter config --no-enable-web

# ここで一度~/.bashrcを読み込む必要がある。管理者権限でWSLを開き、実行する。
echo "Please run WSL with administrator privileges and execute the following command."
echo 
echo "\tsource ~/.bashrc"

# 以下、WindowsのPowerShellを起動して、以下を実行する。
# cd "C:\Users\gyshi\AppData\Local\Android\Sdk\cmdline-tools\latest\bin"
# .\sdkmanager.bat --licenses

# その後WSLに戻って以下のコマンドを実行。
# flutter doctor -v

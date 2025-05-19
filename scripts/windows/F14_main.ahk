#NoEnv  ; 環境変数を無視
#SingleInstance force  ; スクリプトの複数実行を防止
SetWorkingDir %A_ScriptDir%  ; スクリプトのディレクトリを作業ディレクトリに設定

; グローバル変数
global ChibaUnivFolder := "D:\千葉大学\2年\前期"  ; 千葉大フォルダのパス

; F14 + アルファベットのホットキー設定
F14 & a::RunApp("Acrobat", "C:\Program Files\Adobe\Acrobat DC\Acrobat\Acrobat.exe")
F14 & b::RunApp("Git Bash", "C:\Program Files\Git\git-bash.exe")
F14 & c::RunApp("電卓", "calc.exe")
F14 & d::RunApp("ダウンロードフォルダ", "explorer.exe ""C:\Users\gyshi\Downloads\""")
F14 & e::RunApp("サクラエディタ", "C:\Program Files (x86)\sakura\sakura.exe")
F14 & f::RunApp("Everything", "C:\Program Files\Everything\Everything.exe")
F14 & g::RunApp("Google Chrome", "C:\Program Files\Google\Chrome\Application\chrome.exe")
; Chromeのプロファイル起動
F14 & h::RunApp("Chrome Profile 3", "C:\Program Files\Google\Chrome\Application\chrome.exe --profile-directory=""Profile 3""")
F14 & i::RunApp("PowerToys", "C:\Users\gyshi\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\PowerToys (Preview)\PowerToys (Preview).lnk")
F14 & j::RunApp("Chrome Profile 1", "C:\Program Files\Google\Chrome\Application\chrome.exe --profile-directory=""Profile 1""")
F14 & k::RunApp("Chrome Profile 2", "C:\Program Files\Google\Chrome\Application\chrome.exe --profile-directory=""Profile 2""")
F14 & l::RunApp("LINE", "C:\Users\gyshi\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\LINE\LINE.lnk")
F14 & m::RunApp("Spotify", "C:\Users\gyshi\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Spotify.lnk")
F14 & n::RunApp("Notion", "C:\Users\gyshi\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Notion.lnk")
F14 & o::RunApp("PC Manager", "C:\Program Files\WindowsApps\Microsoft.MicrosoftPCManager_3.16.1.0_x64__8wekyb3d8bbwe\PCManager\MSPCManager.exe")
F14 & p::RunApp("PowerPoint", "C:\Program Files\Microsoft Office\root\Office16\POWERPNT.EXE")
F14 & q::RunApp("Dドライブ", "explorer.exe D:\")
F14 & r::RunApp("スタートアップフォルダ", "shell:startup")
F14 & s::RunApp("Spark", "C:\Users\gyshi\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Spark Desktop.lnk")
F14 & t::RunApp("DeepL", "C:\Users\gyshi\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\DeepL.lnk")
F14 & u::RunApp("千葉大フォルダ", "explorer.exe " . ChibaUnivFolder)
F14 & v::RunApp("Visual Studio Code", "C:\Users\gyshi\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Visual Studio Code\Visual Studio Code.lnk")
F14 & w::RunApp("Word", "C:\Program Files\Microsoft Office\root\Office16\WINWORD.EXE")
F14 & x::RunApp("Excel", "C:\Program Files\Microsoft Office\root\Office16\EXCEL.EXE")
F14 & y::RunApp("VirtualBox", "C:\Program Files\Oracle\VirtualBox\VirtualBox.exe")
F14 & z::Run, powershell.exe -WindowStyle Hidden -Command "Start-Process wsl"


F14 & ,::
    ; アクティブウィンドウのクラス名を取得
    WinGetClass, winClass, A

    ; エクスプローラーウィンドウだけを対象にする（クラス名がCabinetWClassまたはExploreWClass）
    if (winClass = "CabinetWClass" || winClass = "ExploreWClass") {
        Run, "C:\Users\gyshi\MyFile\scripts\20_open_wsl_here.bat"
    }
return

; アプリケーションを実行する関数
RunApp(appName, path) {
    Run, %path%
    return
}


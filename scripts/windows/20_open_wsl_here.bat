@echo off
:: エクスプローラーで開いているカレントディレクトリを取得
set "win_path=%cd%"

:: ドライブ文字（C:など）を抽出して小文字に変換
set "drive_letter=%win_path:~0,1%"
for %%A in (a b c d e f g h i j k l m n o p q r s t u v w x y z) do (
    if /I "%drive_letter%"=="%%A" set "mnt_drive=%%A"
)

:: バックスラッシュをスラッシュに変換し、/mnt/ドライブに変換
set "wsl_path=%win_path:\=/%"
set "wsl_path=/mnt/%mnt_drive%%wsl_path:~2%"

:: WSLのbashを起動してそのディレクトリに移動
wsl.exe bash -c "cd '%wsl_path%' && exec bash"

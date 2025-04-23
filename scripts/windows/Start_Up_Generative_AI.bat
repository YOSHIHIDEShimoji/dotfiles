@echo off

REM 1) Chromeの実行ファイルパスを指定
set CHROME_PATH="C:\Program Files\Google\Chrome\Application\chrome.exe"

REM 2) 実際のProfileフォルダ名を確認して設定
set PROFILE="Profile 2"

REM 3) startコマンドでChromeを起動（タブを一括で開く／常に新ウィンドウで）
start "" %CHROME_PATH% --new-window --profile-directory=%PROFILE% ^
  "https://chat.openai.com/" ^
  "https://gemini.google.com/app" ^
  "https://aistudio.google.com/app/prompts/new_chat" ^
  "https://claude.ai/new" ^
  "https://copilot.microsoft.com/chats/oJfLQqKHW28YoLpLpnhvM" ^
  "https://www.perplexity.ai/?login-source=floatingSignup" ^
  "chrome-extension://iaakpnchhognanibcahlpcplchdfmgma/app.html#/"
  

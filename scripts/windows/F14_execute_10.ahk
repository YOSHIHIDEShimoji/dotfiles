#NoEnv
#SingleInstance, Force
SendMode Input
SetWorkingDir %A_ScriptDir%

; F14キーを押しながら.を押す方法
F14 & F13::
    CreateSeries()
return

; F14単独の場合、通常のF14キーとして機能させる
F14::Send {F14}

; 連番作成の関数
CreateSeries() {
    ; 現在のエクスプローラーのパスを取得
    WinGetClass, class, A
    if (class != "CabinetWClass")
        return
        
    ClipSaved := ClipboardAll
    Clipboard := ""
    Send !d
    Sleep, 100
    Send ^c
    ClipWait, 2
    if ErrorLevel
    {
        MsgBox, カレントディレクトリのパスの取得に失敗しました。
        return
    }
    CurrentPath := Clipboard
    Clipboard := ClipSaved
    ClipSaved := ""

    ; スクリプトパスの定義
    ScriptPath := "C:\Users\gyshi\MyFile\scripts\10_create_series_win.ps1"

    ; パラメータを入力するためのGUIを表示
    InputStep := 1
    PlaceholderParam := ""
    StartParam := ""
    StepParam := ""
    ZeroPadParam := ""
    FileParam := " -f"  ; デフォルトはファイル
    
    While (InputStep > 0)
    {
        If (InputStep = 1)
        {
            ; プレースホルダ文字の入力
            InputBox, Placeholder, プレースホルダ文字 [1/6], プレースホルダ文字を入力してください（デフォルト: i）:`n`n戻る: Cancel,, 600, 190
            If ErrorLevel
                return  ; 最初の画面ではキャンセルで終了
            
            If (Placeholder = "")
            {
                Placeholder := "i"  ; デフォルトはi
                PlaceholderParam := ""
            }
            Else
                PlaceholderParam := " -p " . Placeholder
            
            InputStep := 2
        }
        Else If (InputStep = 2)
        {
            ; テンプレート名の入力
            SampleName := "第" . Placeholder . "回.txt"
            InputBox, Template, テンプレート名 [2/6], プレースホルダ文字「%Placeholder%」を使ったテンプレート名を入力してください（例: %SampleName%）:`n`n戻る: Cancel,, 600, 190
            If ErrorLevel
                InputStep := 1  ; 戻る
            Else If (Template = "")
                InputBox, Template, テンプレート名 [2/6], テンプレート名は必須です。入力してください:`n`n戻る: Cancel,, 600, 190
            Else
                InputStep := 3
        }
        Else If (InputStep = 3)
        {
            ; 終了値の入力
            InputBox, EndVal, 終了値 [3/6], 終了値(-e)を入力してください（必須）:`n`n戻る: Cancel,, 600, 190
            If ErrorLevel
                InputStep := 2  ; 戻る
            Else If (EndVal = "")
                InputBox, EndVal, 終了値 [3/6], 終了値は必須です。入力してください:`n`n戻る: Cancel,, 600, 190
            Else
            {
                intCheck := IsInteger(EndVal)
                If (intCheck = 0)  ; 数値ではない
                    InputBox, EndVal, 終了値 [3/6], 終了値は数値で入力してください（必須）:`n`n戻る: Cancel,, 600, 190
                Else If (intCheck = 2)  ; 全角数字を検出
                {
                    MsgBox, 0, 入力エラー, 全角数字が検出されました。半角数字で入力してください。
                    Continue
                }
                Else  ; 正しい数値
                    InputStep := 4
            }
        }
        Else If (InputStep = 4)
        {
            ; 開始値の入力（オプション）
            InputBox, StartVal, 開始値 [4/6], 開始値(-s)を入力してください（デフォルト: 1）:`n`n戻る: Cancel / スキップ: 空白,, 600, 190
            If ErrorLevel
                InputStep := 3  ; 戻る
            Else
            {
                ; 空なら引数なし、数値なら引数あり
                If (StartVal = "")
                    StartParam := ""
                Else
                {
                    intCheck := IsInteger(StartVal)
                    If (intCheck = 0)  ; 数値ではない
                    {
                        MsgBox, 0, 入力エラー, 開始値は数値で入力してください。
                        Continue
                    }
                    Else If (intCheck = 2)  ; 全角数字を検出
                    {
                        MsgBox, 0, 入力エラー, 全角数字が検出されました。半角数字で入力してください。
                        Continue
                    }
                    Else  ; 正しい数値
                        StartParam := " -s " . StartVal
                }
                InputStep := 5
            }
        }
        Else If (InputStep = 5)
        {
            ; ステップ値の入力（オプション）
            InputBox, StepVal, ステップ値 [5/6], ステップ値(-t)を入力してください（デフォルト: 1）:`n`n戻る: Cancel / スキップ: 空白,, 600, 190
            If ErrorLevel
                InputStep := 4  ; 戻る
            Else
            {
                ; 空なら引数なし、数値なら引数あり
                If (StepVal = "")
                    StepParam := ""
                Else
                {
                    intCheck := IsInteger(StepVal)
                    If (intCheck = 0)  ; 数値ではない
                    {
                        MsgBox, 0, 入力エラー, ステップ値は数値で入力してください。
                        Continue
                    }
                    Else If (intCheck = 2)  ; 全角数字を検出
                    {
                        MsgBox, 0, 入力エラー, 全角数字が検出されました。半角数字で入力してください。
                        Continue
                    }
                    Else  ; 正しい数値
                        StepParam := " -t " . StepVal
                }
                InputStep := 6
            }
        }
        Else If (InputStep = 6)
        {
            ; ゼロパディングの入力（オプション）
            InputBox, ZeroPadVal, ゼロパディング [6/6], ゼロパディング桁数(-z)を入力してください（デフォルト: 0）:`n`n戻る: Cancel / スキップ: 空白,, 600, 190
            If ErrorLevel
                InputStep := 5  ; 戻る
            Else
            {
                ; 空なら引数なし、数値なら引数あり
                If (ZeroPadVal = "")
                    ZeroPadParam := ""
                Else
                {
                    intCheck := IsInteger(ZeroPadVal)
                    If (intCheck = 0)  ; 数値ではない
                    {
                        MsgBox, 0, 入力エラー, ゼロパディング桁数は数値で入力してください。
                        Continue
                    }
                    Else If (intCheck = 2)  ; 全角数字を検出
                    {
                        MsgBox, 0, 入力エラー, 全角数字が検出されました。半角数字で入力してください。
                        Continue
                    }
                    Else  ; 正しい数値
                        ZeroPadParam := " -z " . ZeroPadVal
                }
                InputStep := 7
            }
        }
        Else If (InputStep = 7)
        {
            ; ファイル/ディレクトリの選択
            InputBox, FileOrDir, ファイル or ディレクトリ, ファイルを作成する場合は「f」を、ディレクトリを作成する場合は「d」を入力してください。`n`nデフォルト: f（ファイル）`n`n戻る: Cancel,, 600, 200
            If ErrorLevel
                InputStep := 6  ; 戻る
            Else
            {
                If (FileOrDir = "" || FileOrDir = "f")
                    FileParam := " -f"
                Else If (FileOrDir = "d")
                    FileParam := ""
                Else
                {
                    MsgBox, 0, エラー, 「f」または「d」を入力してください。
                    Continue
                }
                ; すべての入力が完了したので実行へ
                InputStep := 0
            }
        }
    }

    ; PowerShellをバックグラウンドで実行
    RunWait, powershell.exe -WindowStyle Hidden -Command "Set-Location '%CurrentPath%'; Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass; & '%ScriptPath%' '%Template%' -e %EndVal%%StartParam%%StepParam%%ZeroPadParam%%PlaceholderParam%%FileParam%",, Hide
}

; 文字列が整数かどうかをチェックする関数
IsInteger(str) {
    ; 全角数字が含まれているか確認
    if (str ~= "[０-９]")
        return 2  ; 全角数字あり
    ; 半角数字のみかチェック
    return str ~= "^-?\d+$"
}
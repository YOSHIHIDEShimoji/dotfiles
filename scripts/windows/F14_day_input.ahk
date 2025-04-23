#NoEnv
#Persistent
#SingleInstance Force
SetWorkingDir %A_ScriptDir%

; グローバル設定変数
global doubleKeyTimeout := 0.1  ; 連続押しを検出する待ち時間（秒単位）

; クリップボード経由で貼り付け（IME干渉なし）
SendRawClipboard(text){
    ClipSaved := ClipboardAll  ; クリップボードの元の状態を保存
    Clipboard := ""            ; 一旦クリア
    Clipboard := text          ; 貼り付けたい文字列を入れる
    ClipWait, 1                ; クリップボードが設定されるのを待つ（最大1秒）
    Send, ^v                   ; Ctrl+Vで貼り付け
    Sleep, 50                  ; 少し待つ
    Clipboard := ClipSaved     ; 元のクリップボードを復元
    VarSetCapacity(ClipSaved, 0) ; メモリ解放
}

; 連続押しを処理するホットキーグループ
; F14 + 1 → 3月15日（年号なし）
; F14 + 11 → 2025年3月15日（年号あり）
F14 & 1::
    KeyWait, 1  ; キーが離されるのを待つ
    KeyWait, 1, D T%doubleKeyTimeout%  ; 0.4秒以内に再度押されるか待つ
    if (ErrorLevel = 0) {  ; 二度目が押された
        ; 年号あり
        FormatTime, today,, yyyy年M月d日
        SendRawClipboard(today)
    } else {
        ; 年号なし
        FormatTime, today,, M月d日
        SendRawClipboard(today)
    }
return

F14 & 2::
    KeyWait, 2
    KeyWait, 2, D T%doubleKeyTimeout%
    if (ErrorLevel = 0) {
        ; 年号あり
        FormatTime, today,, yyyy年M月d日（ddd）
        SendRawClipboard(today)
    } else {
        ; 年号なし
        FormatTime, today,, M月d日（ddd）
        SendRawClipboard(today)
    }
return

F14 & 3::
    KeyWait, 3
    KeyWait, 3, D T%doubleKeyTimeout%
    if (ErrorLevel = 0) {
        ; 年号あり
        FormatTime, today,, yyyy/M/d
        SendRawClipboard(today)
    } else {
        ; 年号なし
        FormatTime, today,, M/d
        SendRawClipboard(today)
    }
return

F14 & 4::
    KeyWait, 4
    KeyWait, 4, D T%doubleKeyTimeout%
    if (ErrorLevel = 0) {
        ; 年号あり
        FormatTime, today,, yyyy/M/d（ddd）
        SendRawClipboard(today)
    } else {
        ; 年号なし
        FormatTime, today,, M/d（ddd）
        SendRawClipboard(today)
    }
return

F14 & 5::
    KeyWait, 5
    KeyWait, 5, D T%doubleKeyTimeout%
    if (ErrorLevel = 0) {
        ; 年号あり（令和）
        FormatTime, year,, yyyy
        FormatTime, month,, M
        FormatTime, day,, d
        reiwa := year - 2018
        text := "令和" . reiwa . "年" . month . "月" . day . "日"
        SendRawClipboard(text)
    } else {
        ; 年号なし
        FormatTime, month,, M
        FormatTime, day,, d
        text := month . "月" . day . "日"
        SendRawClipboard(text)
    }
return

F14 & 6::
    KeyWait, 6
    KeyWait, 6, D T%doubleKeyTimeout%
    if (ErrorLevel = 0) {
        ; 年号あり（令和）
        FormatTime, year,, yyyy
        FormatTime, month,, M
        FormatTime, day,, d
        FormatTime, weekday,, ddd
        reiwa := year - 2018
        text := "令和" . reiwa . "年" . month . "月" . day . "日（" . weekday . "）"
        SendRawClipboard(text)
    } else {
        ; 年号なし
        FormatTime, month,, M
        FormatTime, day,, d
        FormatTime, weekday,, ddd
        text := month . "月" . day . "日（" . weekday . "）"
        SendRawClipboard(text)
    }
return

F14 & 7::
    KeyWait, 7
    KeyWait, 7, D T%doubleKeyTimeout%
    if (ErrorLevel = 0) {
        ; 年号あり（令和）
        FormatTime, year,, yyyy
        FormatTime, month,, M
        FormatTime, day,, d
        reiwa := year - 2018
        text := "R" . reiwa . "." . month . "." . day
        SendRawClipboard(text)
    } else {
        ; 年号なし
        FormatTime, month,, M
        FormatTime, day,, d
        text := month . "." . day
        SendRawClipboard(text)
    }
return

F14 & 8::
    KeyWait, 8
    KeyWait, 8, D T%doubleKeyTimeout%
    if (ErrorLevel = 0) {
        ; 年号あり
        FormatTime, today,, yyyy.M.d
        SendRawClipboard(today)
    } else {
        ; 年号なし
        FormatTime, today,, M.d
        SendRawClipboard(today)
    }
return

F14 & 9::
    KeyWait, 9
    KeyWait, 9, D T%doubleKeyTimeout%
    if (ErrorLevel = 0) {
        ; 年号あり
        FormatTime, today,, yyyy_M_d
        SendRawClipboard(today)
    } else {
        ; 年号なし
        FormatTime, today,, M_d
        SendRawClipboard(today)
    }
return

F14 & 0::
    KeyWait, 0
    KeyWait, 0, D T%doubleKeyTimeout%
    if (ErrorLevel = 0) {
        ; 年号あり
        FormatTime, today, L1033, MMMM d, yyyy
        SendRawClipboard(today)
    } else {
        ; 年号なし
        FormatTime, today, L1033, MMMM d
        SendRawClipboard(today)
    }
return
param(
    [Parameter(Position = 0, Mandatory = $true)]
    [string]$Template,
    [Alias('s')]
    [int]$Start = 1,
    [Alias('e')]
    [Parameter(Mandatory = $true)]
    [int]$End,
    [Alias('t')]
    [int]$Step = 1,
    [Alias('z')]
    [int]$ZeroPad = 0,
    [Alias('p')]
    [string]$Placeholder = 'i',
    [Alias('f')]
    [switch]$File,
    [Alias('d')]
    [string]$DestDir = '.',
    [Alias('n')]
    [switch]$DryRun
)
# 必須チェック
if ($End -eq $null) {
    Write-Error "エラー: 終了値(-e)は必須です。"
    exit 1
}
# 連番生成チェック
if (($Start -gt $End) -and ($Step -gt 0)) {
    Write-Error "エラー: 開始値($Start)が終了値($End)より大きく、ステップ($Step)が正のため、連番が生成されません。"
    exit 1
}
# テンプレートチェック
if (-not $Template.Contains($Placeholder)) {
    Write-Warning "テンプレートにプレースホルダ '$Placeholder' が含まれていません。置換は行われません。"
}
# 名前一覧生成
$names = @()
for ($i = $Start; ($Step -gt 0 -and $i -le $End) -or ($Step -lt 0 -and $i -ge $End); $i += $Step) {
    if ($ZeroPad -gt 0) {
        $num = $i.ToString().PadLeft($ZeroPad, '0')
    } else {
        $num = $i
    }
    $newName = $Template -replace [regex]::Escape($Placeholder), $num
    $names += $newName
}
# ドライラン
if ($DryRun) {
    Write-Host "ドライランモード（実際には作成しません）"
    Write-Host "ディレクトリ '$DestDir' に以下の$(if ($File) { 'ファイル' } else { 'ディレクトリ' })を作成予定です："
    $names | ForEach-Object { Write-Host "  $_" }
    exit 0
}
Write-Host "ディレクトリ '$DestDir' に以下の$(if ($File) { 'ファイル' } else { 'ディレクトリ' })を作成します："
$names | ForEach-Object { Write-Host "  $_" }
Write-Host "-----"
Write-Host "作成を開始します"
foreach ($name in $names) {
    $targetPath = Join-Path $DestDir $name
    if ($File) {
        $dir = Split-Path $targetPath
        if (-not (Test-Path $dir)) { New-Item -Path $dir -ItemType Directory -Force | Out-Null }
        New-Item -Path $targetPath -ItemType File -Force | Out-Null
        Write-Host "[FILE] $targetPath を作成しました"
    } else {
        New-Item -Path $targetPath -ItemType Directory -Force | Out-Null
        Write-Host "[DIR]  $targetPath を作成しました"
    }
}
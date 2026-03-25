param (
    [Parameter(Mandatory = $true)]
    [string]$FeatureName
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = "Stop"

Write-Host "=== Phase 2: Scaffolding (Blueprint Copy) ==="
Write-Host "Target Feature: $FeatureName"

# パスの定義
$BlueprintDir = ".\.blueprints\feature-template"
$TargetDir = ".\src\features\$FeatureName"

# 1. 事前チェック
if (-not (Test-Path $BlueprintDir)) {
    Write-Error "🚨 エラー: ブループリントディレクトリ '$BlueprintDir' が見つかりません。"
    exit 1
}

if (Test-Path $TargetDir) {
    Write-Warning "⚠️ 警告: 対象ディレクトリ '$TargetDir' は既に存在します。上書きを防ぐため処理を中断します。"
    # 既存機能の改修（Evolution等）の場合はScaffoldingをスキップして正常終了させる
    exit 0
}

# 2. 物理コピーの実行
Write-Host "ブループリントを $TargetDir へコピーしています..."
New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
Copy-Item -Path "$BlueprintDir\*" -Destination $TargetDir -Recurse

# 3. プレースホルダーの置換（ファイル名と内容）
Write-Host "機能名 ($FeatureName) を足場に注入しています..."

Get-ChildItem -Path $TargetDir -Recurse -File | ForEach-Object {
    $File = $_
    
    # A. ファイル名の置換 (例: FeatureTemplateUseCase.cs -> BookMemoUseCase.cs)
    $NewName = $File.Name -replace "FeatureTemplate", $FeatureName
    if ($NewName -ne $File.Name) {
        Rename-Item -Path $File.FullName -NewName $NewName
        # リネーム後の新しいパスを取得し直す
        $File = Get-Item (Join-Path $File.DirectoryName $NewName)
    }

    # B. ファイル内容の置換
    $Content = Get-Content $File.FullName -Raw
    if ($Content -match "FeatureTemplate") {
        $Content = $Content -replace "FeatureTemplate", $FeatureName
        # ここに -Encoding UTF8 を追加！
        Set-Content -Path $File.FullName -Value $Content -NoNewline -Encoding UTF8
    }
}

Write-Host "Scaffolding が正常に完了しました。"
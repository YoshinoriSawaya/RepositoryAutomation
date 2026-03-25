param (
    [Parameter(Mandatory = $true)]
    [string]$FeatureName,

    [Parameter(Mandatory = $true)]
    [string]$IssueNumber
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = "Stop"

Write-Host "=== Phase 3: Coding (Qwen2.5-Coder-7B + Aider) ==="

# 1. ターゲットファイルの特定
$TargetDir = ".\src\features\$FeatureName"
if (-not (Test-Path $TargetDir)) {
    Write-Error "🚨 エラー: 対象ディレクトリ '$TargetDir' が存在しません。Scaffoldingが実行されていません。"
    exit 1
}

# 編集対象となるファイル群のパスを取得
$TargetFiles = Get-ChildItem -Path $TargetDir -Recurse -File | Select-Object -ExpandProperty FullName

# 2. Issue本文の取得
Write-Host "GitHubから Issue #$IssueNumber の要件を取得中..."
$IssueBody = gh issue view $IssueNumber --json body -q ".body"

# 3. Aiderへのプロンプト構築
$AiderMessage = @"
Implement the feature described in the issue below.
STRICT RULES:
1. You MUST ONLY modify the files provided in the context.
2. DO NOT modify any shared, core, or infrastructure files outside this feature directory.
3. Follow the Clean Architecture principles established in the scaffolded files.

[Issue Details]
$IssueBody
"@

# 4. VRAM完全アンロードの強制
$env:OLLAMA_KEEP_ALIVE = "0"

Write-Host "Qwen2.5-Coder-7B をロードし、自動コーディングを開始します..."

# 5. Aiderの実行（PowerShellの配列展開を使用して安全に引数を渡す）
$AiderArgs = @(
    "--model", "ollama/qwen2.5-coder:7b",
    "--yes",
    "--no-auto-commits",
    "--message", $AiderMessage
)
$AiderArgs += $TargetFiles
# (中略：Aiderの実行部分)

# 外部コマンド(aider)の実行
& aider $AiderArgs

Write-Host "コーディングフェーズが完了しました。VRAMのクリーンアップ（強制解放）を実行します..."

# 6. Qwenモデルの強制アンロード (Teardown)
$UnloadPayload = @{
    model      = "qwen2.5-coder:7b"
    keep_alive = 0
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:11434/api/generate" -Method Post -Body $UnloadPayload -ContentType "application/json"

Write-Host "VRAMを完全に解放しました。フェーズ3完了。"
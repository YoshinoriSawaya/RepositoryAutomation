param (
    [Parameter(Mandatory = $true)]
    [string]$IssueNumber
)

chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$env:PYTHONIOENCODING = "utf-8"
$OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = "Stop"

Write-Host "=== Phase 2: Implementation ==="

# 1. 最新の指示書を抽出（安全な gh issue view を使用）
Write-Host "Issue #$IssueNumber からコメントを取得中..."
$IssueData = gh issue view $IssueNumber --json comments | ConvertFrom-Json
$Comments = $IssueData.comments
[array]::Reverse($Comments)

$Instructions = $null
foreach ($Comment in $Comments) {
    # Phase 1の出力の後半部分（指示書本体）を確実に抽出する正規表現
    if ($Comment.body -match '(?s)ready-for-coding ラベルを付与してください。\s*(.*)') {
        $Instructions = $Matches[1].Trim()
        break
    }
}

if (-not $Instructions) {
    Write-Error "🚨 指示書が見つかりません。Phase 1のコメントが存在するか確認してください。"
    exit 1
}

# --- Feature Nameの抽出とScaffoldingの実行 ---
Write-Host "Issueタイトルから機能名を抽出し、Scaffoldingを実行します..."
$IssueInfo = gh issue view $IssueNumber --json title | ConvertFrom-Json
# タイトルの最初の単語を安全に抽出（記号や空白を除去）
$FeatureName = ($IssueInfo.title -split '[: 　]')[0].Trim()
Write-Host "対象機能名: $FeatureName"

# 変数を文字列として確実にバインドして呼び出し
.\scripts\Scaffolding.ps1 -FeatureName "$FeatureName"

# Scaffoldingで生成された対象ファイル群を取得
$TargetDir = ".\src\features\$FeatureName"
$TargetFiles = @()
if (Test-Path $TargetDir) {
    $TargetFiles = Get-ChildItem -Path $TargetDir -Recurse -File | Select-Object -ExpandProperty FullName
}
else {
    Write-Warning "Scaffoldingディレクトリ ($TargetDir) が見つかりません。既存機能の改修として進めます。"
}
# --------------------------------------------------------

# 指示書をファイルに保存
$InstructionsPath = "ai_instructions.txt"
Set-Content -Path $InstructionsPath -Value $Instructions -Encoding utf8

# 2. Gitブランチの作成
$BranchName = "feature/auto-issue-$IssueNumber"
git checkout -b $BranchName

# 3. Aiderの実行
# Aiderが確実にVRAMを使えるよう、事前にOllamaの全モデルをアンロード
Invoke-RestMethod -Uri "http://localhost:11434/api/generate" -Method Post -Body '{"model":"llama3.1:8b","keep_alive":0}' -ContentType "application/json" -ErrorAction SilentlyContinue

$AiderMessage = @"
以下の指示書に従って実装を行ってください。
必ずUTF-8で保存し、パブリックメソッドにはXMLドキュメントコメント(///)を記述してください。

[指示書]
$(Get-Content $InstructionsPath -Raw -Encoding utf8)
"@

$env:OLLAMA_KEEP_ALIVE = "0"
$AiderArgs = @(
    "--model", "ollama/qwen2.5-coder:7b",
    "--yes",
    "--message", $AiderMessage
)

# 生成したファイル群をAiderの編集コンテキストとして明示的に渡す
if ($TargetFiles.Count -gt 0) {
    $AiderArgs += $TargetFiles
}

Write-Host "Aiderによる自動コーディングを開始します..."
& aider $AiderArgs

# Aider実行後のVRAM解放
Invoke-RestMethod -Uri "http://localhost:11434/api/generate" -Method Post -Body '{"model":"qwen2.5-coder:7b","keep_alive":0}' -ContentType "application/json" -ErrorAction SilentlyContinue

# 4. PR作成とラベル変更
if (git status --porcelain) {
    git add .
    git commit -m "Auto-implementation for Issue #$IssueNumber"
    git push -u origin $BranchName

    # PR作成 (元のIssueと紐付け)
    $PRUrl = gh pr create --title "Resolve #$IssueNumber - Auto Implementation" --body "Closes #$IssueNumber`n`n🤖 自動生成されたPRです。" --base main
    Write-Host "PR作成完了: $PRUrl"

    # ラベルの付け替え
    gh issue edit $IssueNumber --remove-label "ready-for-coding" --add-label "in-review"
}
else {
    Write-Host "変更が検出されませんでした。"
}
param (
    [Parameter(Mandatory = $true)]
    [string]$PRNumber
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = "Stop"

Write-Host "=== Phase 3: AI Self-Verification ==="

# 1. PRから紐づくIssue番号を取得して指示書を取り出す
$PRInfo = gh pr view $PRNumber --json body | ConvertFrom-Json
$IssueNumber = $null
if ($PRInfo.body -match '(?:Closes|Resolves|Fixes)\s+#(\d+)') {
    $IssueNumber = $Matches[1]
}

$Instructions = "指示書が見つかりませんでした。"
if ($IssueNumber) {
    $Comments = gh api repos/ { owner }/ { repo }/issues/$IssueNumber/comments | ConvertFrom-Json
    [array]::Reverse($Comments)
    foreach ($Comment in $Comments) {
        if ($Comment.body -match '(?s)(.*?)') {
            $Instructions = $Matches[1].Trim()
            break
        }
    }
}

# 2. PRのDiffを取得
$Diff = gh pr diff $PRNumber

# 3. 変更されたファイルの全体コードを取得 (VRAM上限を考慮して長すぎる場合は切り詰める)
$ChangedFiles = gh pr view $PRNumber --json files | ConvertFrom-Json
$FullCodeContext = ""
foreach ($File in $ChangedFiles.files) {
    if (Test-Path $File.path) {
        $FileContent = Get-Content $File.path -Raw -ErrorAction SilentlyContinue
        # C#やTypeScriptなどのソースコードに絞る運用も有効です
        $FullCodeContext += "--- $($File.path) ---`n" + $FileContent + "`n`n"
    }
}

# 文字数制約の適用（Diff + 全体コード）
$ContextText = "Diff:`n$Diff`n`nFull Code:`n$FullCodeContext"
if ($ContextText.Length -gt 6000) {
    $ContextText = $ContextText.Substring(0, 6000) + "`n...[Truncated due to token limits]"
}

# 4. Ollamaによるレビュー
$Prompt = @"
あなたは厳格なコードレビュアーです。
以下の「元の要件（指示書）」、「PRの差分（Diff）」、「変更されたファイルの全体コード」を評価し、
要件を満たしているかチェックリスト形式で評価してください。

応答は必ず以下の形式に従ってください。
- ✅ 要件を満たしている項目
- ⚠️ 確認が必要、または欠落している項目
最後に総合評価（Pass/Needs Work）を記載してください。

[要件（指示書）]
$Instructions

[コード情報]
$ContextText
"@

$Payload = @{
    model      = "llama3.1:8b"
    prompt     = $Prompt
    stream     = $false
    keep_alive = 0
} | ConvertTo-Json -Depth 10

Write-Host "レビューを生成中..."
$Response = Invoke-RestMethod -Uri "http://localhost:11434/api/generate" -Method Post -Body $Payload -ContentType "application/json"

# 5. PRへレビュー結果をコメント
$ReviewComment = @"
🤖 **AI Self-Review (Verification Phase)** 🤖

$($Response.response)
"@

gh pr comment $PRNumber --body $ReviewComment
Write-Host "レビュー完了。PRにコメントしました。"
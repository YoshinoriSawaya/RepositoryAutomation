param (
    [Parameter(Mandatory = $true)]
    [string]$IssueNumber
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = "Stop"

Write-Host "=== Phase 1: Issue Refinement ==="

# 1. Issueデータの取得
$Issue = gh issue view $IssueNumber --json body, comments | ConvertFrom-Json
$IssueText = "Issue Body:`n" + $Issue.body
if ($Issue.comments.Length -gt 0) {
    $IssueText += "`n`nComments:`n" + ($Issue.comments.body -join "`n--`n")
}

# 2. VRAM保護: ゲートキーパーチェック
if ($IssueText.Length -gt 4000) {
    Write-Host "🚨 警告: 4,000文字の制約を超過しました。分割を促します。"
    gh issue comment $IssueNumber --body "🚨 **Constraint Error**: コンテキストが長すぎます。Issueを分割してください。"
    exit 1
}

# 3. LLMによる要件の整理
$Prompt = @"
以下のIssue内容を分析し、コーディングAI（Aider等）が直接実装できる具体的な「実装指示書」に変換してください。
出力は指示書の本文のみとし、Markdown形式で整理してください。

[Issue内容]
$IssueText
"@

$Payload = @{
    model      = "llama3.1:8b"
    prompt     = $Prompt
    stream     = $false
    keep_alive = 0 # 推論後にVRAMを即解放
} | ConvertTo-Json -Depth 10

Write-Host "Llama-3.1-8Bで指示書を生成中..."
$Response = Invoke-RestMethod -Uri "http://localhost:11434/api/generate" -Method Post -Body $Payload -ContentType "application/json"
$RefinedInstructions = $Response.response

# 4. 非表示タグで囲んでコメント投稿（GitHub UI上ではタグは見えません）
$CommentBody = @"
🤖 **Issue Refinement Complete** 🤖
要件を実装可能な指示書に整理しました。内容に問題がなければ `ready-for-coding` ラベルを付与してください。

$RefinedInstructions
"@

# --- 修正部分 ---
# 一度UTF-8のテキストファイルとして保存し、--body-fileで渡す
$TempFile = "temp_comment.md"
[System.IO.File]::WriteAllText($TempFile, $CommentBody, [System.Text.Encoding]::UTF8)

gh issue comment $IssueNumber --body-file $TempFile
Remove-Item $TempFile -ErrorAction SilentlyContinue
# ---------------


Write-Host "Refinement完了。Issueにコメントしました。"
param (
    [Parameter(Mandatory = $true)]
    [string]$IssueNumber
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = "Stop"

Write-Host "=== Phase 1: Issue Refinement ==="

# 1. Issueデータの取得（titleを追加）
$IssueJson = gh issue view $IssueNumber --json title, body, comments
$Issue = $IssueJson | ConvertFrom-Json

# タイトルと本文を結合
$IssueText = "【タイトル】`n$($Issue.title)`n`n【本文】`n$($Issue.body)"

# コメントがあれば追記
if ($Issue.comments -and $Issue.comments.Length -gt 0) {
    $IssueText += "`n`n【コメント】`n" + ($Issue.comments.body -join "`n--`n")
}

Write-Host "抽出したIssueテキスト:`n$IssueText"

# 2. VRAM保護: ゲートキーパーチェック
if ($IssueText.Length -gt 4000) {
    Write-Host "🚨 警告: 4,000文字の制約を超過しました。分割を促します。"
    gh issue comment $IssueNumber --body "🚨 **Constraint Error**: コンテキストが長すぎます。Issueを分割してください。"
    exit 1
}

# 3. LLMによる要件の整理
$Prompt = @"
あなたは熟練のソフトウェアエンジニアです。以下のIssue内容に基づき、開発AI（Aider等）が即座に実装作業に入れる「実装指示書」をMarkdown形式で作成してください。

情報が短い、または不足している場合でも、「内容を入力してください」と返答するのではなく、一般的なWeb開発のベストプラクティスに基づいて必要な項目を推測し、実装案を提示してください。

[対象のIssue]
$IssueText

[指示書の構成案]
1. 概要 (Summary)
2. 変更が必要なファイル/コンポーネントの推測
3. 具体的な実装手順 (DBマイグレーション, UI変更等)
4. テスト項目

出力はMarkdownの指示書本文のみとしてください。挨拶や確認の言葉は一切不要です。
"@

$Payload = @{
    model      = "llama3.1:8b"
    prompt     = $Prompt
    stream     = $false
    options    = @{
        temperature = 0.7  # 少し創造性を許容し、短い入力から指示書を膨らませる
        num_predict = 1000 # 十分な出力長さを確保する
    }
    keep_alive = 0 
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

# Windowsのghコマンド引数バグを回避するため、一時ファイル経由で投稿
$TempFile = "temp_comment.md"
[System.IO.File]::WriteAllText($TempFile, $CommentBody, [System.Text.Encoding]::UTF8)

gh issue comment $IssueNumber --body-file $TempFile
Remove-Item $TempFile -ErrorAction SilentlyContinue




Write-Host "Refinement完了。Issueにコメントしました。"
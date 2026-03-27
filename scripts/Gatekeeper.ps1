param (
    [Parameter(Mandatory=$true)]
    [string]$IssueNumber
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8


$ErrorActionPreference = "Stop"
$CharacterLimit = 4000

Write-Host "=== Phase 0: Gatekeeper (VRAM Protection) ==="

# 1. ルールファイルの読み込み
$RulesPath = ".coding_rules.md"
$RulesText = ""
if (Test-Path $RulesPath) {
    $RulesText = Get-Content $RulesPath -Raw
} else {
    Write-Warning "$RulesPath が見つかりません。ルールなしで進行します。"
}

# 2. GitHub CLIでIssue本文を取得
Write-Host "Issue #$IssueNumber のデータを取得中..."
# GitHub Actions上では $env:GH_TOKEN が必要になります
$IssueBody = gh issue view $IssueNumber --json body -q ".body"

# 3. 文字数の合算と検問
$TotalLength = $RulesText.Length + $IssueBody.Length
Write-Host "入力合計文字数: $TotalLength / $CharacterLimit"

if ($TotalLength -gt $CharacterLimit) {
    Write-Host "🚨 警告: 4,000文字の制約を超過しました。パイプラインを停止します。"
    
    $RejectMessage = @"
🚨 **VRAM Constraint Error (Gatekeeper)** 🚨

Issue本文とコーディングルールの合計文字数（**$TotalLength 文字**）が、システム制約の4,000文字を超過しています。
VRAM（8GB）のオーバーフローを防ぎ、かつ推論精度を保つため、Issueをより小さな機能単位（Vertical Slicing）に分割して出し直してください。
"@

    # Issueに自動コメントを残す
    gh issue comment $IssueNumber --body $RejectMessage

    # Actionsを異常終了（Fail）させる
    exit 1 
}

Write-Host "検問クリア。VRAMの余裕を確認しました。"
Write-Host "=== Phase 1: Reasoning (Llama-3.1-8B) ==="

# 4. Llama 3.1 へのプロンプト構築 (英語出力へ変更)
$Prompt = @"
Review the following issue against our coding rules.
You must analyze if the issue contains enough specific requirements to write code.
Respond strictly in JSON format with the following keys:
- "state": Must be exactly "Match", "Conflict", or "Evolution".
- "reason": A brief explanation of your decision (in English, max 3 sentences).

[Rules]
$RulesText

[Issue]
$IssueBody
"@

# 5. 直列推論の実行（format="json" を追加）
$Payload = @{
    model = "llama3.1:8b"
    prompt = $Prompt
    format = "json"   # ← OllamaにJSON出力を強制する強力なオプション
    stream = $false
    keep_alive = 0
} | ConvertTo-Json

Write-Host "Llama-3.1-8B をロードし、推論を開始します..."
$Response = Invoke-RestMethod -Uri "http://localhost:11434/api/generate" -Method Post -Body $Payload -ContentType "application/json"

# 返ってきたJSON文字列をPowerShellのオブジェクトに変換
$ReasoningResult = $Response.response | ConvertFrom-Json

Write-Host "判定ステータス: [$($ReasoningResult.state)]"
Write-Host "判定理由: $($ReasoningResult.reason)"

# 6. 判定結果に応じたルーティング
if ($ReasoningResult.state -eq "Conflict") {
    Write-Host "ルール違反または情報不足を検知。Issueにフィードバックを返します..."
    
    $CommentBody = @"
🤖 **Architecture Review (Reasoning Phase)** 🤖

ステータス: **Conflict**
内容に以下の問題が検出されたため、パイプラインを停止しました。

> $($ReasoningResult.reason)

設計の規律（Vertical Slicing / クリーンアーキテクチャ）に従い、Issueの内容を修正してください。
"@
    # IssueにAIの理由付きでコメントを投稿
    gh issue comment $IssueNumber --body $CommentBody
    
    # 異常終了させてActionsを止める
    exit 1
} elseif ($ReasoningResult.state -eq "Evolution") {
    Write-Host "ルールの進化が必要です。ルール修正PRの生成に移行します..."
    # TODO: ルール修正フローへ
} elseif ($ReasoningResult.state -eq "Match") {
    Write-Host "Matchを確認。Scaffoldingフェーズへ進みます..."
    # TODO: Blueprint Copyフローへ
} else {
    Write-Host "予期せぬステータスです: $($ReasoningResult.state)"
    exit 1
}
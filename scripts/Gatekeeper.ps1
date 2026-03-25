param (
    [Parameter(Mandatory=$true)]
    [string]$IssueNumber
)

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

# 4. Llama 3.1 へのプロンプト構築
$Prompt = @"
Review the following issue against our coding rules.
Reply ONLY with one of the following states: Match, Conflict, or Evolution.

[Rules]
$RulesText

[Issue]
$IssueBody
"@

# 5. 直列推論の実行（完全アンロードを強制）
$Payload = @{
    model = "llama3.1:8b"
    prompt = $Prompt
    stream = $false
    keep_alive = 0
} | ConvertTo-Json

Write-Host "Llama-3.1-8B をロードし、推論を開始します..."
$Response = Invoke-RestMethod -Uri "http://localhost:11434/api/generate" -Method Post -Body $Payload -ContentType "application/json"

$ReasoningResult = $Response.response.Trim()
Write-Host "判定結果: [$ReasoningResult]"

# 判定結果に応じた次のアクション（モック）
if ($ReasoningResult -match "Conflict") {
    Write-Host "ルール違反を検知。Issueにフィードバックを返します..."
    # TODO: Llamaに理由を生成させてIssueにコメントし、exit 1
} elseif ($ReasoningResult -match "Evolution") {
    Write-Host "ルールの進化が必要です。ルール修正PRの生成に移行します..."
    # TODO: ルール修正フローへ
} else {
    Write-Host "Matchを確認。Scaffoldingフェーズへ進みます..."
    # TODO: Blueprint Copyフローへ
}
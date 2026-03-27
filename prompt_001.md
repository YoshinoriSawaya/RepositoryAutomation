# 指示
現在、GitHub ActionsとローカルLLM（Ollama/Aider等、セルフホストランナー使用）を連携させ、Issueから自動でPull Requestを作成・レビューするシステムを構築しています。
現状のPowerShellスクリプトをベースに、以下の「3フェーズ構成」のワークフローを実現するようにスクリプトとActionsの定義を改修・設計してください。

# システムの全体構成（実現したいワークフロー）
処理時間は長くかかっても問題ありません。精度と確実性を重視します。

## フェーズ1：要件定義とプロンプト化（Issue Refinement）
- **トリガー**: 新規Issue作成時、またはコメントで `/refine` と入力された時。
- **処理**: 雑多なIssue内容（や追加の指示コメント）をLLMに渡し、実装指示用のテンプレート形式に整理させる。
- **出力ルール**: 抽出の目印として、出力テキストは必ず `` と `` という非表示タグで囲んでIssueにコメントさせる。

## フェーズ2：実装とPR作成（Implementation）
- **トリガー**: Issueに `ready-for-coding` ラベルが付与された時。
- **処理**: 
  1. GitHub APIを使用し、対象Issueのコメントを最新のものから逆順（下から上）にスキャンする。
  2. 最初に見つかった `` から `` のブロックを抽出し、`ai_instructions.txt` として保存する。
  3. このテキストファイルをコーディングAI（Aider等）に渡してローカルで実装を実行する。
  4. 新しいブランチをPushしてPRを作成し、元のIssueのラベルを `in-review` に変更する。

## フェーズ3：AIによる自己レビュー（Verification）
- **トリガー**: PRが作成された時（または更新された時）。
- **処理**:
  1. フェーズ2で抽出した「指示書（プロンプト）」を取得する。
  2. PRの「Diff（差分）」を取得する。
  3. Diffの検知漏れを防ぐため、「変更が加わったファイルの全体コード」も取得する。
  4. 上記3つをLLMに渡し、要件を満たしているかチェックリスト形式で評価させる。
  5. PRにレビュー結果（✅ 実装済み、⚠️ 要確認 など）をコメントする。

# 現在の実装（ベースとなるPowerShellスクリプト）
以下のスクリプトをベースに、上記の要件を満たすように改修・拡張してください。

Gatekeeper.ps1
 ```powershell
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
 ``` 

 Scaffolding.ps1
 ```powershell
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
 ```

coding.ps1
 ```powershell
param (
    [Parameter(Mandatory = $true)]
    [string]$FeatureName,

    [Parameter(Mandatory = $true)]
    [string]$IssueNumber
)
# コンソールのコードページをUTF-8(65001)に強制変更
chcp 65001 | Out-Null

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$env:PYTHONIOENCODING = "utf-8"
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
Implement the feature described in the issue.

RULES FOR COMMENTS:
1. Explain the logic using Japanese comments inside the code.
2. Use XML documentation comments (///) for public methods to describe parameters and return values in Japanese.
3. Ensure the file is saved in UTF-8 encoding.

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
 ``` 
# 出力してほしいこと
1. **GitHub Actionsのワークフロー定義案（.yml）**: 3つのフェーズをどのようにジョブやファイルに分割し、トリガー（ラベル検知など）を設定すべきか。
2. **改修後のPowerShellスクリプト**: 
   - Issueコメントから最新のプロンプトブロックを抽出するロジック
   - PRのDiffと変更ファイル全体を取得してLLMに渡すための処理
   などの具体的なコード実装を含めてください。



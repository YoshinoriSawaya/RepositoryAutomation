# RepositoryAutomation

GitHub Issueをトリガーに、ローカルLLM（Ollama）とAiderを用いてクリーンアーキテクチャに基づいたコードを自動生成し、プルリクエスト（PR）を作成するパイプライン。

## 概要

本プロジェクトは、VRAM 8GB（RTX 2070 Super）という限定的なリソース環境で、複数のLLMを直列にオーケストレーションし、自律的な開発ワークフローを実現する実験的実装である。

### 特徴
- **リソース最適化**: モデルのロード・アンロードを明示的に制御し、8GB VRAM内での動作を保証。
- **アーキテクチャの強制**: Scaffoldingによる物理的なディレクトリ構造（Vertical Slicing）の生成により、AIのコード生成範囲を制限。
- **マルチモデル運用**: 判定（Llama-3.1-8B）とコーディング（Qwen2.5-Coder-7B）の責務分離。

## システム構成

### 実行フェーズ
1. **Phase 0 & 1: Gatekeeper / Reasoning**
   - Llama-3.1-8B を使用。Issueの内容を解析し、実装ルール（`.coding_rules.md`）への適合性を判定。
2. **Phase 2: Scaffolding**
   - PowerShellによるディレクトリ/テンプレート生成。`Entity`, `Interface`, `UseCase` の足場を自動構築。
3. **Phase 3: Coding**
   - Aider + Qwen2.5-Coder-7B を使用。指定されたフィーチャーディレクトリ内のみを対象に自動実装。
4. **Phase 4: PR Creation**
   - GitHub CLI (`gh`) を使用。生成されたコードを別ブランチへPushし、PRを自動作成。

## 技術スタック
- **LLM Engine**: [Ollama](https://ollama.com/)
- **AI Agent**: [Aider](https://aider.chat/)
- **Runner**: GitHub Actions (Self-hosted on Windows)
- **Scripting**: PowerShell 7
- **CLI**: GitHub CLI, Git

## ディレクトリ構造
- `.blueprints/`: 共通のコードテンプレート
- `.github/workflows/`: 自動化ワークフロー定義
- `scripts/`: 各フェーズを制御するロジック
- `src/features/`: 自動生成された機能コード

## セットアップ

### 環境変数
GitHub Actionsのワークフローで使用するため、以下の設定が必要。
- `GH_TOKEN`: PR作成権限を持つPAT、またはActionsのデフォルトトークン。
- `PYTHONIOENCODING`: `utf-8` (Windows環境での文字化け防止)

### Runnerの起動
ローカル環境で GitHub Actions の Self-hosted Runner を起動する。
```powershell
./actions-runner/run.cmd
運用ルール
Issueのタイトルは 機能名: 概要 の形式で作成すること。

生成されたPRは必ず人間がレビューし、クリーンアーキテクチャの規律に違反していないか確認すること。
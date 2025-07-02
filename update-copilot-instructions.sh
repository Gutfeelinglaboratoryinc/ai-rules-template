#!/bin/bash

# GitHub Copilot Instructions 更新スクリプト
# 既存のシンボリックリンクがあるプロジェクトの統合ファイルを更新します

set -e

# カラー出力用の定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 成功メッセージ表示
success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# 情報メッセージ表示
info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# 必要な変数の設定
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RULES_SOURCE_DIR="$SCRIPT_DIR/.cursor/rules"
GENERATED_INSTRUCTIONS="$SCRIPT_DIR/generated-copilot-instructions.md"

info "GitHub Copilot Instructions を更新しています..."

# 統合されたcopilot-instructions.mdを生成
generate_copilot_instructions() {
    cat > "$GENERATED_INSTRUCTIONS" << 'EOF'
# GitHub Copilot Instructions

このプロジェクトでは、以下のルールに従ってコード生成・レビューを行ってください。

## 基本開発ルール

EOF

    # base.mdcファイルの内容を追加（Markdown形式に変換）
    if [ -f "$RULES_SOURCE_DIR/base.mdc" ]; then
        echo "### 共通ルール" >> "$GENERATED_INSTRUCTIONS"
        echo "" >> "$GENERATED_INSTRUCTIONS"
        # .mdcファイルから# で始まる行を除いてMarkdown形式で追加
        sed 's/^# /## /' "$RULES_SOURCE_DIR/base.mdc" | grep -v "^alwaysApply:" >> "$GENERATED_INSTRUCTIONS"
        echo "" >> "$GENERATED_INSTRUCTIONS"
    fi

    # backend-python.mdcファイルの内容を追加
    if [ -f "$RULES_SOURCE_DIR/backend-python.mdc" ]; then
        echo "### Python Backend 固有ルール" >> "$GENERATED_INSTRUCTIONS"
        echo "" >> "$GENERATED_INSTRUCTIONS"
        sed 's/^# /## /' "$RULES_SOURCE_DIR/backend-python.mdc" | grep -v "^alwaysApply:" >> "$GENERATED_INSTRUCTIONS"
        echo "" >> "$GENERATED_INSTRUCTIONS"
    fi

    # feature-spec.mdcファイルの内容を追加
    if [ -f "$RULES_SOURCE_DIR/feature-spec.mdc" ]; then
        echo "### 機能設計書作成ルール" >> "$GENERATED_INSTRUCTIONS"
        echo "" >> "$GENERATED_INSTRUCTIONS"
        sed 's/^# /## /' "$RULES_SOURCE_DIR/feature-spec.mdc" | grep -v "^alwaysApply:" >> "$GENERATED_INSTRUCTIONS"
        echo "" >> "$GENERATED_INSTRUCTIONS"
    fi

    # task-request.mdcファイルの内容を追加
    if [ -f "$RULES_SOURCE_DIR/task-request.mdc" ]; then
        echo "### タスク依頼書作成ルール" >> "$GENERATED_INSTRUCTIONS"
        echo "" >> "$GENERATED_INSTRUCTIONS"
        sed 's/^# /## /' "$RULES_SOURCE_DIR/task-request.mdc" | grep -v "^alwaysApply:" >> "$GENERATED_INSTRUCTIONS"
        echo "" >> "$GENERATED_INSTRUCTIONS"
    fi

    cat >> "$GENERATED_INSTRUCTIONS" << 'EOF'

## コード生成・レビュー時の注意事項

### 必須事項
- 上記のコーディング規約に従ってコードを生成する
- セキュリティ要件（認証・認可、入力検証、暗号化）を必ず考慮する
- エラーハンドリングを適切に実装する
- JSDocコメントを必ず記述する

### 生成するコード品質
- テスタブルなコードを生成する
- SOLID原則に従った設計にする
- 適切な命名規則を使用する
- パフォーマンスを考慮した実装にする

### レビュー観点
- 機能設計書に沿った実装かチェックする
- セキュリティホールがないかチェックする
- パフォーマンス問題がないかチェックする
- 可読性・保守性が高いかチェックする

---
このファイルは ai-rules-template から自動生成されています。
手動編集は避け、ルール変更は ai-rules-template で行ってください。
更新日時: $(date '+%Y-%m-%d %H:%M:%S')
EOF
}

# 統合Instructionsファイル生成
generate_copilot_instructions

success "GitHub Copilot Instructions ファイルを更新しました: $GENERATED_INSTRUCTIONS"
info "シンボリックリンクを設定済みのプロジェクトに自動的に反映されます。" 
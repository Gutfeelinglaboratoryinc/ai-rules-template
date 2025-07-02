#!/bin/bash

# GitHub Copilot Instructions セットアップスクリプト
# 使用方法: ./setup-copilot.sh <target_project_path>

set -e

# カラー出力用の定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ヘルプメッセージ
show_help() {
    echo -e "${BLUE}GitHub Copilot Instructions セットアップスクリプト${NC}"
    echo ""
    echo "使用方法:"
    echo "  ./setup-copilot.sh <target_project_path>"
    echo ""
    echo "例:"
    echo "  ./setup-copilot.sh ../my-project"
    echo "  ./setup-copilot.sh /Users/username/projects/my-app"
    echo ""
    echo "オプション:"
    echo "  -h, --help     このヘルプメッセージを表示"
    echo "  -f, --force    既存ファイルを強制上書き"
    echo "  -s, --symlink  シンボリックリンクを作成（推奨）"
    echo "  -c, --copy     ファイルをコピー"
    echo ""
}

# エラーメッセージ表示
error() {
    echo -e "${RED}エラー: $1${NC}" >&2
    exit 1
}

# 成功メッセージ表示
success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# 警告メッセージ表示
warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# 情報メッセージ表示
info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# 引数チェック
if [ $# -eq 0 ]; then
    error "プロジェクトパスが指定されていません。"
    show_help
    exit 1
fi

# オプション解析
FORCE=false
USE_SYMLINK=true
TARGET_PATH=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        -s|--symlink)
            USE_SYMLINK=true
            shift
            ;;
        -c|--copy)
            USE_SYMLINK=false
            shift
            ;;
        -*)
            error "不明なオプション: $1"
            ;;
        *)
            if [ -z "$TARGET_PATH" ]; then
                TARGET_PATH="$1"
            else
                error "複数のプロジェクトパスが指定されています。"
            fi
            shift
            ;;
    esac
done

# 必要な変数の設定
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RULES_SOURCE_DIR="$SCRIPT_DIR/.cursor/rules"

# 絶対パスに変換
TARGET_PATH="$(cd "$TARGET_PATH" 2>/dev/null && pwd)" || error "指定されたパス '$1' が存在しません。"

TARGET_GITHUB_DIR="$TARGET_PATH/.github"
TARGET_COPILOT_INSTRUCTIONS="$TARGET_PATH/.github/copilot-instructions.md"
GENERATED_INSTRUCTIONS="$SCRIPT_DIR/generated-copilot-instructions.md"

info "GitHub Copilot Instructions セットアップを開始します..."
info "ターゲットプロジェクト: $TARGET_PATH"
info "方式: $([ "$USE_SYMLINK" = true ] && echo "シンボリックリンク" || echo "ファイルコピー")"

# ソースディレクトリの存在確認
[ ! -d "$RULES_SOURCE_DIR" ] && error "ルールソースディレクトリが見つかりません: $RULES_SOURCE_DIR"

# .githubディレクトリの作成
info ".githubディレクトリを作成しています..."
mkdir -p "$TARGET_GITHUB_DIR"

# 統合されたcopilot-instructions.mdを生成
info "Copilot Instructions ファイルを生成しています..."
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
EOF
}

# 統合Instructionsファイル生成
generate_copilot_instructions

# ファイル配置（シンボリックリンクまたはコピー）
if [ "$USE_SYMLINK" = true ]; then
    # シンボリックリンクを作成
    if [ -f "$TARGET_COPILOT_INSTRUCTIONS" ] || [ -L "$TARGET_COPILOT_INSTRUCTIONS" ]; then
        if [ "$FORCE" = false ]; then
            warning "copilot-instructions.md は既に存在します。"
            read -p "上書きしますか？ (y/N): " confirm
            if [[ ! $confirm =~ ^[Yy]$ ]]; then
                info "スキップ: copilot-instructions.md"
                exit 0
            fi
        fi
        rm -f "$TARGET_COPILOT_INSTRUCTIONS"
    fi
    
    # macOS/Linux対応の相対パス計算
    if command -v realpath >/dev/null 2>&1; then
        # Linux: realpath が --relative-to オプションをサポート
        if realpath --help 2>&1 | grep -q "\--relative-to"; then
            RELATIVE_PATH=$(realpath --relative-to="$TARGET_GITHUB_DIR" "$GENERATED_INSTRUCTIONS")
        else
            # macOS: 手動で相対パス計算
            RELATIVE_PATH=$(python3 -c "import os.path; print(os.path.relpath('$GENERATED_INSTRUCTIONS', '$TARGET_GITHUB_DIR'))")
        fi
    else
        # realpathが存在しない場合はPythonで計算
        RELATIVE_PATH=$(python3 -c "import os.path; print(os.path.relpath('$GENERATED_INSTRUCTIONS', '$TARGET_GITHUB_DIR'))")
    fi
    
    ln -s "$RELATIVE_PATH" "$TARGET_COPILOT_INSTRUCTIONS"
    success "シンボリックリンクを作成: copilot-instructions.md -> $RELATIVE_PATH"
else
    # ファイルをコピー
    if [ -f "$TARGET_COPILOT_INSTRUCTIONS" ] && [ "$FORCE" = false ]; then
        warning "copilot-instructions.md は既に存在します。"
        read -p "上書きしますか？ (y/N): " confirm
        if [[ ! $confirm =~ ^[Yy]$ ]]; then
            info "スキップ: copilot-instructions.md"
            exit 0
        fi
    fi
    
    cp "$GENERATED_INSTRUCTIONS" "$TARGET_COPILOT_INSTRUCTIONS"
    success "ファイルをコピー: copilot-instructions.md"
fi

# .gitignoreの更新確認
gitignore_file="$TARGET_PATH/.gitignore"
if [ -f "$gitignore_file" ]; then
    if [ "$USE_SYMLINK" = true ]; then
        if ! grep -q "generated-copilot-instructions.md" "$gitignore_file"; then
            read -p ".gitignoreに自動生成ファイルを追加しますか？ (Y/n): " add_gitignore
            if [[ ! $add_gitignore =~ ^[Nn]$ ]]; then
                echo "" >> "$gitignore_file"
                echo "# AI Rules Template - Auto Generated" >> "$gitignore_file"
                echo "generated-copilot-instructions.md" >> "$gitignore_file"
                success ".gitignoreを更新しました"
            fi
        fi
    fi
fi

# セットアップ完了メッセージ
echo ""
success "🎉 GitHub Copilot Instructions のセットアップが完了しました！"
echo ""
info "設定内容:"
echo "  - GitHub Copilot Instructions: $TARGET_COPILOT_INSTRUCTIONS"
echo "  - 方式: $([ "$USE_SYMLINK" = true ] && echo "シンボリックリンク（推奨）" || echo "ファイルコピー")"
echo ""
info "次の手順:"
echo "1. VS Codeでプロジェクトを開く"
echo "2. GitHub Copilot拡張機能が有効になっていることを確認"
echo "3. 設定で 'github.copilot.chat.codeGeneration.useInstructionFiles' を有効にする"
echo "4. コード生成時に自動的にルールが適用されます"
echo ""
if [ "$USE_SYMLINK" = true ]; then
    info "シンボリックリンク使用時の注意:"
    echo "  - ai-rules-templateでルールを更新すると自動的に反映されます"
    echo "  - ./update-copilot-instructions.sh で手動更新も可能です"
else
    warning "ファイルコピー使用時の注意:"
    echo "  - ルール更新時は手動で再実行が必要です"
fi 
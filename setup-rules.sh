#!/bin/bash

# AI Rules Template セットアップスクリプト
# 使用方法: ./setup-rules.sh <target_project_path>

set -e

# カラー出力用の定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ヘルプメッセージ
show_help() {
    echo -e "${BLUE}AI Rules Template セットアップスクリプト${NC}"
    echo ""
    echo "使用方法:"
    echo "  ./setup-rules.sh <target_project_path>"
    echo ""
    echo "例:"
    echo "  ./setup-rules.sh ../my-project"
    echo "  ./setup-rules.sh /Users/username/projects/my-app"
    echo ""
    echo "オプション:"
    echo "  -h, --help     このヘルプメッセージを表示"
    echo "  -f, --force    既存ファイルを強制上書き"
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
DOCS_SOURCE_DIR="$SCRIPT_DIR/docs"

# 絶対パスに変換
TARGET_PATH="$(cd "$TARGET_PATH" 2>/dev/null && pwd)" || error "指定されたパス '$1' が存在しません。"

TARGET_CURSOR_DIR="$TARGET_PATH/.cursor"
TARGET_RULES_DIR="$TARGET_PATH/.cursor/rules"
TARGET_DOCS_DIR="$TARGET_PATH/docs"

info "セットアップを開始します..."
info "ターゲットプロジェクト: $TARGET_PATH"

# ソースディレクトリの存在確認
[ ! -d "$RULES_SOURCE_DIR" ] && error "ルールソースディレクトリが見つかりません: $RULES_SOURCE_DIR"
[ ! -d "$DOCS_SOURCE_DIR" ] && error "ドキュメントソースディレクトリが見つかりません: $DOCS_SOURCE_DIR"

# プロジェクトがGitリポジトリかチェック
if [ ! -d "$TARGET_PATH/.git" ]; then
    warning "ターゲットディレクトリはGitリポジトリではありません。"
    read -p "続行しますか？ (y/N): " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        info "セットアップをキャンセルしました。"
        exit 0
    fi
fi

# .cursorディレクトリの作成
info "Cursorディレクトリを作成しています..."
mkdir -p "$TARGET_CURSOR_DIR"
mkdir -p "$TARGET_RULES_DIR"

# ルールファイルのコピー
info "Cursorルールファイルをコピーしています..."
for rule_file in "$RULES_SOURCE_DIR"/*.mdc; do
    if [ -f "$rule_file" ]; then
        filename=$(basename "$rule_file")
        target_file="$TARGET_RULES_DIR/$filename"
        
        if [ -f "$target_file" ] && [ "$FORCE" = false ]; then
            warning "ファイル '$filename' は既に存在します。"
            read -p "上書きしますか？ (y/N): " confirm
            if [[ ! $confirm =~ ^[Yy]$ ]]; then
                info "スキップ: $filename"
                continue
            fi
        fi
        
        cp "$rule_file" "$target_file"
        success "コピー完了: $filename"
    fi
done

# docsディレクトリの作成（存在しない場合）
if [ ! -d "$TARGET_DOCS_DIR" ]; then
    info "docsディレクトリを作成しています..."
    mkdir -p "$TARGET_DOCS_DIR"
fi

# ドキュメントテンプレートのコピー（任意）
read -p "ドキュメントテンプレートもコピーしますか？ (y/N): " copy_docs
if [[ $copy_docs =~ ^[Yy]$ ]]; then
    info "ドキュメントテンプレートをコピーしています..."
    
    # task-requestディレクトリ
    if [ -d "$DOCS_SOURCE_DIR/task-request" ]; then
        target_task_dir="$TARGET_DOCS_DIR/task-request"
        mkdir -p "$target_task_dir"
        
        for template_file in "$DOCS_SOURCE_DIR/task-request"/*.md; do
            if [ -f "$template_file" ]; then
                filename=$(basename "$template_file")
                target_file="$target_task_dir/template-$filename"
                
                if [ -f "$target_file" ] && [ "$FORCE" = false ]; then
                    warning "テンプレートファイル '$filename' は既に存在します。スキップします。"
                    continue
                fi
                
                cp "$template_file" "$target_file"
                success "テンプレートコピー完了: task-request/$filename"
            fi
        done
    fi
    
    # feature-specディレクトリ
    if [ -d "$DOCS_SOURCE_DIR/feature-spec" ]; then
        target_spec_dir="$TARGET_DOCS_DIR/feature-spec"
        mkdir -p "$target_spec_dir"
        
        for template_file in "$DOCS_SOURCE_DIR/feature-spec"/*.md; do
            if [ -f "$template_file" ]; then
                filename=$(basename "$template_file")
                target_file="$target_spec_dir/template-$filename"
                
                if [ -f "$target_file" ] && [ "$FORCE" = false ]; then
                    warning "テンプレートファイル '$filename' は既に存在します。スキップします。"
                    continue
                fi
                
                cp "$template_file" "$target_file"
                success "テンプレートコピー完了: feature-spec/$filename"
            fi
        done
    fi
fi

# .gitignoreの更新確認
gitignore_file="$TARGET_PATH/.gitignore"
if [ -f "$gitignore_file" ]; then
    if ! grep -q ".cursor/" "$gitignore_file"; then
        read -p ".gitignoreに.cursor/ディレクトリを追加しますか？ (Y/n): " add_gitignore
        if [[ ! $add_gitignore =~ ^[Nn]$ ]]; then
            echo "" >> "$gitignore_file"
            echo "# Cursor AI Editor" >> "$gitignore_file"
            echo ".cursor/" >> "$gitignore_file"
            success ".gitignoreを更新しました"
        fi
    fi
fi

# セットアップ完了メッセージ
echo ""
success "🎉 AI Rules Template のセットアップが完了しました！"
echo ""
info "次の手順:"
echo "1. Cursorエディタでプロジェクトを開く"
echo "2. チャット機能 (Ctrl+L / Cmd+L) を使用して設計書を作成"
echo "3. 例: 'ユーザー認証APIの機能設計書を作成してください'"
echo ""
info "利用可能なルール:"
for rule_file in "$TARGET_RULES_DIR"/*.mdc; do
    if [ -f "$rule_file" ]; then
        filename=$(basename "$rule_file" .mdc)
        echo "  - $filename"
    fi
done
echo ""
info "詳細な使用方法: $SCRIPT_DIR/README.md を参照してください" 
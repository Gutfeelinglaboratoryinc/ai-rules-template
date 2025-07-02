# GitHub Copilot での AI Rules 活用ガイド

## 概要

このガイドでは、ai-rules-templateで定義したルールをVS CodeのGitHub Copilotで活用する方法を説明します。

## セットアップ

### 1. AIルールの適用

```bash
# ai-rules-templateディレクトリで実行
./setup-copilot.sh /path/to/your/project
```

### 2. VS Code設定

`.vscode/settings.json` に以下を追加：

```json
{
  "github.copilot.chat.codeGeneration.useInstructionFiles": true
}
```

または、推奨設定をコピー：

```bash
cp vscode-settings-example.jsonc /path/to/your/project/.vscode/settings.json
```

### 3. 設定確認

VS Codeでプロジェクトを開き、以下を確認：
- GitHub Copilot拡張機能が有効
- `.github/copilot-instructions.md` ファイルが存在
- 設定で `useInstructionFiles` が有効

## 使用方法

### コード生成時

GitHub Copilotは自動的にプロジェクトの `copilot-instructions.md` を読み込み、ルールに従ったコードを生成します。

#### 例：Python関数の生成

**プロンプト**:
```
ユーザー情報を取得するAPIエンドポイントを作成して
```

**生成されるコード** (ルール適用済み):
```python
from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from typing import Optional
import logging

logger = logging.getLogger(__name__)

class UserResponse(BaseModel):
    """ユーザー情報レスポンスモデル"""
    id: int
    name: str
    email: str
    created_at: str

router = APIRouter()

@router.get("/users/{user_id}", response_model=UserResponse)
async def get_user(user_id: int) -> UserResponse:
    """
    ユーザー情報を取得する
    
    Args:
        user_id (int): ユーザーID
        
    Returns:
        UserResponse: ユーザー情報
        
    Raises:
        HTTPException: ユーザーが見つからない場合
    """
    try:
        # ユーザーIDのバリデーション
        if user_id <= 0:
            raise HTTPException(status_code=400, detail="Invalid user ID")
        
        # データベースからユーザー情報を取得
        user = await _get_user_from_db(user_id)
        
        if not user:
            logger.warning(f"User not found: {user_id}")
            raise HTTPException(status_code=404, detail="User not found")
        
        logger.info(f"User retrieved successfully: {user_id}")
        return UserResponse(**user)
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error retrieving user {user_id}: {str(e)}")
        raise HTTPException(status_code=500, detail="Internal server error")

async def _get_user_from_db(user_id: int) -> Optional[dict]:
    """
    データベースからユーザー情報を取得する（プライベートメソッド）
    
    Args:
        user_id (int): ユーザーID
        
    Returns:
        Optional[dict]: ユーザー情報またはNone
    """
    # TODO: 実際のDB接続処理を実装
    pass
```

### チャット機能での活用

**プロンプト例**:
```
このコードをレビューして、プロジェクトのルールに沿っているかチェックしてください
```

Copilotは以下の観点でレビューします：
- JSDocコメントの有無
- エラーハンドリングの実装
- セキュリティ要件の遵守
- 命名規則の確認
- パフォーマンス問題の有無

### 設計書生成での活用

**プロンプト例**:
```
ユーザー管理機能の機能設計書を作成してください
```

ルールに従った設計書テンプレートが生成されます。

## ルール更新時の対応

### 1. ルール更新

`ai-rules-template` でルールファイルを編集：

```bash
# base.mdcやbackend-python.mdcを編集
vim .cursor/rules/base.mdc
```

### 2. Copilot Instructions更新

```bash
# ai-rules-templateディレクトリで実行
./update-copilot-instructions.sh
```

### 3. VS Codeの再読み込み

VS Codeでプロジェクトを再読み込みするか、以下のコマンドを実行：
- `Ctrl+Shift+P` → `Developer: Reload Window`

## ルール適用の確認方法

### 1. 生成コード確認

Copilotで生成されたコードが以下の要件を満たしているか確認：
- ✅ JSDocコメントが記述されている
- ✅ エラーハンドリングが実装されている
- ✅ 適切な命名規則が使用されている
- ✅ セキュリティ要件を満たしている

### 2. チャットでの確認

Copilot Chatで以下を試行：
```
プロジェクトのコーディング規約について教えて
```

設定したルールが反映されているかを確認できます。

## トラブルシューティング

### Q: ルールが適用されていない

**A: 以下を確認してください**
1. `github.copilot.chat.codeGeneration.useInstructionFiles` が `true` になっているか
2. `.github/copilot-instructions.md` ファイルが存在するか
3. VS Codeを再起動したか

### Q: 一部のルールだけ適用したい

**A: ファイル編集で対応**
```bash
# 生成された統合ファイルを編集
vim .github/copilot-instructions.md
```

ただし、次回 `update-copilot-instructions.sh` 実行時に上書きされることにご注意ください。

### Q: プロジェクト固有のルールを追加したい

**A: プロジェクト内でルールを直接編集**
```markdown
<!-- .github/copilot-instructions.md に追記 -->

## プロジェクト固有ルール

### このプロジェクトの特別な要件
- 特定のライブラリの使用方法
- プロジェクト独自の命名規則
- 特別なセキュリティ要件
```

## 参考資料

- [GitHub Copilot Documentation](https://docs.github.com/en/copilot)
- [VS Code Copilot Extension](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot)
- [ai-rules-template README](../README.md) 
# タスク依頼：ユーザー管理API実装

## 📋 基本情報
- **依頼者**：プロダクトマネージャー 田中
- **担当者**：バックエンドエンジニア 佐藤
- **期限**：2024-01-15
- **優先度**：高
- **工数見積**：16時間（2日間）

## 🎯 背景・目的
### 背景
現在、ユーザー情報の管理が手動で行われており、システム管理者の負荷が増大している。また、ユーザー情報の整合性に問題が発生しており、サービス品質に影響を与えている。

### 目的
- ユーザー情報の CRUD 操作を API 化し、管理コストを削減する
- データの整合性を保ち、信頼性の高いユーザー管理システムを構築する
- 将来的なフロントエンド開発のための API 基盤を提供する

### 影響範囲
- **システム**：ユーザー管理システム、認証システム
- **ユーザー**：システム管理者、今後のWebアプリケーションユーザー
- **業務**：ユーザー登録・変更・削除プロセスの自動化

## 📝 作業内容詳細

### 実装対象
- [ ] ユーザー一覧取得 API
- [ ] ユーザー詳細取得 API
- [ ] ユーザー作成 API
- [ ] ユーザー更新 API
- [ ] ユーザー削除 API（論理削除）
- [ ] ユーザー検索 API（名前・メールアドレス）

### 入力・出力定義
#### 入力
| 項目名 | 型 | 必須 | 説明 | 例 |
|--------|----|----|------|-----|
| name | string | ○ | ユーザー名（1-100文字） | "山田太郎" |
| email | string | ○ | メールアドレス | "yamada@example.com" |
| age | integer | × | 年齢（18-120） | 25 |
| department | string | × | 所属部署 | "開発部" |
| role | string | ○ | 権限（admin/user/guest） | "user" |

#### 出力
| 項目名 | 型 | 説明 | 例 |
|--------|----|------|-----|
| id | integer | ユーザーID | 123 |
| name | string | ユーザー名 | "山田太郎" |
| email | string | メールアドレス | "yamada@example.com" |
| age | integer | 年齢 | 25 |
| department | string | 所属部署 | "開発部" |
| role | string | 権限 | "user" |
| is_active | boolean | アクティブ状態 | true |
| created_at | string | 作成日時（ISO8601） | "2024-01-01T00:00:00Z" |
| updated_at | string | 更新日時（ISO8601） | "2024-01-01T12:00:00Z" |

## 🔍 要件・制約事項

### 機能要件
- ユーザーの CRUD 操作が可能であること
- メールアドレスの重複チェックを行うこと
- ページネーション機能を提供すること（1ページ20件）
- 部分一致検索機能を提供すること
- 論理削除によりデータの整合性を保つこと

### 非機能要件
- **パフォーマンス**：一覧取得のレスポンス時間500ms以下
- **セキュリティ**：JWT認証による認可、入力値バリデーション実装
- **可用性**：99.9%の稼働率を保証（既存システムと同等）

### 制約事項
- 既存データベーススキーマとの互換性を保つこと
- 2024年1月15日までにリリース必要
- メンテナンス時間は最小限に抑えること

## ✅ バリデーション仕様

### 入力バリデーション
| 項目 | バリデーションルール | エラーメッセージ |
|------|-------------------|-----------------|
| name | 必須、1-100文字、特殊文字禁止 | "名前は1-100文字で入力してください（特殊文字不可）" |
| email | 必須、メールアドレス形式、重複チェック | "有効なメールアドレスを入力してください" |
| age | 任意、18-120の整数 | "年齢は18-120の整数で入力してください" |
| department | 任意、1-50文字 | "所属部署は50文字以内で入力してください" |
| role | 必須、admin/user/guestのいずれか | "権限は admin, user, guest のいずれかを選択してください" |

### ビジネスロジック検証
- メールアドレスの重複チェック：同一メールアドレスの登録を禁止
- 削除権限チェック：管理者のみが他ユーザーを削除可能
- 自己更新制限：ユーザーは自分の権限を変更不可

## 🧪 テスト仕様

### ユニットテスト例
```javascript
describe('UserService', () => {
  test('正常系：ユーザー作成成功', async () => {
    // Given
    const input = {
      name: "山田太郎",
      email: "yamada@example.com",
      age: 25,
      department: "開発部",
      role: "user"
    };
    
    // When
    const result = await userService.createUser(input);
    
    // Then
    expect(result).toEqual({
      id: expect.any(Number),
      name: "山田太郎",
      email: "yamada@example.com",
      age: 25,
      department: "開発部",
      role: "user",
      is_active: true,
      created_at: expect.any(String),
      updated_at: expect.any(String)
    });
  });
  
  test('異常系：メールアドレス重複エラー', async () => {
    // Given
    const existingUser = { email: "duplicate@example.com" };
    await userService.createUser(existingUser);
    
    const duplicateInput = {
      name: "重複太郎",
      email: "duplicate@example.com",
      role: "user"
    };
    
    // When & Then
    await expect(userService.createUser(duplicateInput))
      .rejects
      .toThrow('このメールアドレスは既に使用されています');
  });
  
  test('異常系：不正な権限値', async () => {
    // Given
    const invalidInput = {
      name: "テスト太郎",
      email: "test@example.com",
      role: "invalid_role"
    };
    
    // When & Then
    await expect(userService.createUser(invalidInput))
      .rejects
      .toThrow('権限は admin, user, guest のいずれかを選択してください');
  });
});
```

### 統合テストシナリオ
1. **ユーザー作成・取得フロー**
   - 前提条件：空のユーザーテーブル
   - 実行手順：
     1. POST /api/v1/users でユーザー作成
     2. GET /api/v1/users/{id} で作成したユーザー取得
   - 期待結果：作成したユーザー情報が正しく取得できる

2. **ユーザー検索フロー**
   - 前提条件：テストユーザー5件が登録済み
   - 実行手順：
     1. GET /api/v1/users?search=山田 で名前検索
     2. GET /api/v1/users?department=開発部 で部署検索
   - 期待結果：条件に合致するユーザーのみ返却される

3. **ページネーションフロー**
   - 前提条件：テストユーザー50件が登録済み
   - 実行手順：
     1. GET /api/v1/users?page=1&limit=20 で1ページ目取得
     2. GET /api/v1/users?page=2&limit=20 で2ページ目取得
   - 期待結果：各ページに最大20件、適切なページネーション情報が返却される

## 📚 参考資料
- [既存ユーザー管理システム仕様書](link-to-current-spec)
- [認証システム連携仕様](link-to-auth-spec)
- [データベース設計書](link-to-db-design)
- [REST API設計ガイドライン](link-to-api-guideline)

## 🔄 完了条件
- [ ] 全API エンドポイントの実装完了
- [ ] ユニットテスト作成・実行完了（カバレッジ80%以上）
- [ ] 統合テスト実行完了（全シナリオ通過）
- [ ] API ドキュメント（OpenAPI/Swagger）作成完了
- [ ] コードレビュー完了
- [ ] ステージング環境でのテスト完了
- [ ] パフォーマンステスト実行完了（レスポンス時間500ms以下確認）

---
**作成日**：2024-01-10  
**最終更新**：2024-01-10 
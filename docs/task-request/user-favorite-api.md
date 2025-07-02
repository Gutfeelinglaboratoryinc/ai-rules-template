# タスク依頼：ユーザーお気に入りURL機能実装

## 📋 基本情報
- **依頼者**：プロダクトマネージャー
- **担当者**：バックエンドエンジニア
- **期限**：2024-02-15
- **優先度**：中
- **工数見積**：20時間（2.5日間）

## 🎯 背景・目的
### 背景
ユーザーから「よく使うサイトをブックマークしたい」「他の人が保存した面白いリンクを見たい」という要望が多数寄せられています。現在はブラウザのブックマーク機能に依存しており、デバイス間での同期やチーム内での共有ができない状況です。

### 目的
- ユーザーが重要なURLを簡単に保存・管理できる機能を提供する
- デバイス間でのブックマーク同期を実現する
- 将来的なソーシャル機能（公開ブックマーク、タグ機能等）の基盤を構築する
- ユーザーエンゲージメントの向上（サイト滞在時間の延長）

### 影響範囲
- **システム**：ユーザー管理システム、認証システム
- **ユーザー**：全登録ユーザー（アクティブユーザー約1,000名）
- **業務**：カスタマーサポート（お気に入り関連の問い合わせ対応）

## 📝 作業内容詳細

### 実装対象
- [ ] お気に入りURL一覧取得 API
- [ ] お気に入りURL詳細取得 API
- [ ] お気に入りURL追加 API
- [ ] お気に入りURL更新 API（タイトル・説明の編集）
- [ ] お気に入りURL削除 API
- [ ] お気に入りURL検索 API（タイトル・URL部分一致）

### 入力・出力定義
#### 入力
| 項目名 | 型 | 必須 | 説明 | 例 |
|--------|----|----|------|-----|
| url | string | ○ | 保存するURL（1-2000文字） | "https://github.com/microsoft/vscode" |
| title | string | ○ | リンクのタイトル（1-200文字） | "Visual Studio Code" |
| description | string | × | 説明・メモ（500文字以内） | "軽量で高機能なエディタ" |
| category | string | × | カテゴリ（20文字以内） | "開発ツール" |
| is_public | boolean | × | 公開設定（デフォルト：false） | false |

#### 出力
| 項目名 | 型 | 説明 | 例 |
|--------|----|------|-----|
| id | integer | お気に入りID | 123 |
| user_id | integer | ユーザーID | 456 |
| url | string | 保存されたURL | "https://github.com/microsoft/vscode" |
| title | string | リンクタイトル | "Visual Studio Code" |
| description | string | 説明・メモ | "軽量で高機能なエディタ" |
| category | string | カテゴリ | "開発ツール" |
| is_public | boolean | 公開設定 | false |
| favicon_url | string | ファビコンURL（自動取得） | "https://github.com/favicon.ico" |
| created_at | string | 作成日時（ISO8601） | "2024-02-01T10:00:00Z" |
| updated_at | string | 更新日時（ISO8601） | "2024-02-01T15:30:00Z" |

## 🔍 要件・制約事項

### 機能要件
- ユーザーはお気に入りURLの CRUD 操作が可能であること
- URL形式の妥当性チェックを行うこと
- ページネーション機能を提供すること（1ページ50件）
- タイトル・URL・カテゴリでの部分一致検索機能を提供すること
- 重複URLの登録を制限すること（同一ユーザー内で）
- ファビコンを自動取得して表示用に保存すること

### 非機能要件
- **パフォーマンス**：一覧取得のレスポンス時間300ms以下
- **セキュリティ**：JWT認証による認可、XSS対策実装
- **可用性**：99.9%の稼働率を保証
- **スケーラビリティ**：ユーザー1人あたり最大1,000件のお気に入り対応

### 制約事項
- 既存ユーザー管理システムとの連携必須
- 2024年2月15日までにリリース必要
- 外部URL取得時のタイムアウトは5秒以内
- ファビコン取得失敗時はデフォルト画像を使用

## ✅ バリデーション仕様

### 入力バリデーション
| 項目 | バリデーションルール | エラーメッセージ |
|------|-------------------|-----------------|
| url | 必須、URL形式、1-2000文字、http/https必須 | "有効なURLを入力してください（http/https必須）" |
| title | 必須、1-200文字、HTMLタグ禁止 | "タイトルは1-200文字で入力してください" |
| description | 任意、500文字以内、HTMLタグ禁止 | "説明は500文字以内で入力してください" |
| category | 任意、1-20文字、英数字・ひらがな・カタカナのみ | "カテゴリは20文字以内で入力してください" |
| is_public | 任意、boolean値 | "公開設定は true または false を指定してください" |

### ビジネスロジック検証
- URL重複チェック：同一ユーザー内での同じURL登録を禁止
- URL到達可能性チェック：登録時にHTTPステータス200-399の確認
- ユーザー制限チェック：1ユーザーあたり最大1,000件まで
- 公開設定チェック：将来機能のため現在は強制的にfalse設定

## 🧪 テスト仕様

### ユニットテスト例
```javascript
describe('FavoriteService', () => {
  test('正常系：お気に入りURL追加成功', async () => {
    // Given
    const userId = 123;
    const input = {
      url: "https://example.com",
      title: "Example Site",
      description: "テストサイト",
      category: "テスト",
      is_public: false
    };
    
    // When
    const result = await favoriteService.createFavorite(userId, input);
    
    // Then
    expect(result).toEqual({
      id: expect.any(Number),
      user_id: 123,
      url: "https://example.com",
      title: "Example Site",
      description: "テストサイト",
      category: "テスト",
      is_public: false,
      favicon_url: expect.any(String),
      created_at: expect.any(String),
      updated_at: expect.any(String)
    });
  });
  
  test('異常系：重複URL登録エラー', async () => {
    // Given
    const userId = 123;
    const duplicateUrl = "https://duplicate.com";
    await favoriteService.createFavorite(userId, {
      url: duplicateUrl,
      title: "First"
    });
    
    const duplicateInput = {
      url: duplicateUrl,
      title: "Second"
    };
    
    // When & Then
    await expect(favoriteService.createFavorite(userId, duplicateInput))
      .rejects
      .toThrow('このURLは既にお気に入りに登録されています');
  });
  
  test('異常系：無効なURL形式', async () => {
    // Given
    const userId = 123;
    const invalidInput = {
      url: "invalid-url",
      title: "Test"
    };
    
    // When & Then
    await expect(favoriteService.createFavorite(userId, invalidInput))
      .rejects
      .toThrow('有効なURLを入力してください（http/https必須）');
  });
  
  test('異常系：お気に入り件数上限エラー', async () => {
    // Given
    const userId = 123;
    // 既に1000件のお気に入りが登録済みの状態を作成
    jest.spyOn(favoriteRepository, 'countByUserId').mockResolvedValue(1000);
    
    const input = {
      url: "https://example.com",
      title: "Test"
    };
    
    // When & Then
    await expect(favoriteService.createFavorite(userId, input))
      .rejects
      .toThrow('お気に入りの登録上限（1000件）に達しています');
  });
});
```

### 統合テストシナリオ
1. **お気に入り登録・取得フロー**
   - 前提条件：認証済みユーザーでログイン
   - 実行手順：
     1. POST /api/v1/favorites でお気に入り追加
     2. GET /api/v1/favorites で一覧取得
     3. GET /api/v1/favorites/{id} で詳細取得
   - 期待結果：登録したお気に入りが正しく取得できる

2. **お気に入り検索フロー**
   - 前提条件：複数のお気に入りが登録済み
   - 実行手順：
     1. GET /api/v1/favorites?search=GitHub でタイトル検索
     2. GET /api/v1/favorites?category=開発ツール でカテゴリ検索
   - 期待結果：条件に合致するお気に入りのみ返却される

3. **お気に入り更新・削除フロー**
   - 前提条件：お気に入りが1件登録済み
   - 実行手順：
     1. PUT /api/v1/favorites/{id} でタイトル更新
     2. DELETE /api/v1/favorites/{id} で削除
     3. GET /api/v1/favorites/{id} で取得（404確認）
   - 期待結果：更新・削除が正しく動作する

4. **ファビコン取得フロー**
   - 前提条件：外部サイトへのアクセス可能な環境
   - 実行手順：
     1. POST /api/v1/favorites で有名サイト（GitHub等）を登録
     2. favicon_url が自動設定されることを確認
   - 期待結果：適切なファビコンURLが取得・保存される

## 📚 参考資料
- [既存ユーザー管理システム仕様書](link-to-user-spec)
- [認証システム連携仕様](link-to-auth-spec)
- [REST API設計ガイドライン](link-to-api-guideline)
- [ファビコン取得ライブラリ仕様](link-to-favicon-lib)

## 🔄 完了条件
- [ ] 全API エンドポイントの実装完了
- [ ] ユニットテスト作成・実行完了（カバレッジ80%以上）
- [ ] 統合テスト実行完了（全シナリオ通過）
- [ ] API ドキュメント（OpenAPI/Swagger）作成完了
- [ ] セキュリティテスト実行完了（XSS、SQLインジェクション対策確認）
- [ ] パフォーマンステスト実行完了（レスポンス時間300ms以下確認）
- [ ] ファビコン取得機能の動作確認完了
- [ ] ステージング環境でのE2Eテスト完了
- [ ] コードレビュー完了

---
**作成日**：2024-01-20  
**最終更新**：2024-01-20

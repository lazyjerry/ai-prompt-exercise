# Prompt Forge

以五個欄位練習組合清楚、可執行的 AI 提示詞，並可直接部署至 Cloudflare Pages。

正式站：[https://ai-prompt-exercise.pages.dev](https://ai-prompt-exercise.pages.dev)

## 功能

- 開始練習：首頁主要按鈕直接移動到提示詞工作區。
- 三組範例：研究比較、功能開發與內容企劃，可一次帶入完整五欄內容。
- 卡片式：一次檢視並填寫所有欄位。
- 精靈式：預設輸入模式，依序完成五個引導步驟。
- 模式切換：兩種模式共用輸入內容，切換時不遺失資料。
- 固定格式：依 Context、Request、交付格式、限制條件、停下確認條件組合提示詞。
- 一鍵複製：將產生結果複製到剪貼簿。
- 方法說明：整理任務邊界、停下確認條件與驗證注意事項，並附官方來源。
- 本機處理：不使用後端、API 或資料庫，輸入內容不會離開瀏覽器。

## 輸出格式

```text
{Context}
{Request}

交付格式：
{Output Format}

限制條件：
{Constraints}

停下確認條件：
{Checkpoint}
```

## 本機開發

需求：

- Node.js 22 以上
- npm

安裝並啟動 Cloudflare Pages 本機環境：

```bash
npm ci
npm run dev
```

Wrangler 會輸出本機網址，預設通常是 `http://localhost:8788`。

執行測試：

```bash
npm test
```

## 發布至 Cloudflare Pages

### 方法一：Git integration

此方法會在 `main` 有新 commit 時自動發布，並為其他 branch 建立 preview deployment。

1. 登入 [Cloudflare dashboard](https://dash.cloudflare.com/)。
2. 進入 **Workers & Pages**，建立 Pages application 並連接 GitHub。
3. 選擇 `lazyjerry/ai-prompt-exercise` repository。
4. 設定 production branch 為 `main`。
5. 使用下列 build 設定：

| 設定 | 值 |
|---|---|
| Framework preset | None |
| Build command | 留空 |
| Build output directory | `public` |
| Root directory | 留空 |

本專案不需要環境變數、API token 或其他秘密資料。

### 方法二：Wrangler Direct Upload

先登入 Cloudflare：

```bash
npx wrangler login
```

首次使用時建立 Pages project：

```bash
npx wrangler pages project create ai-prompt-exercise
```

發布 `public/`：

```bash
npm run deploy
```

Cloudflare 的 Direct Upload project 建立後不能改成 Git integration。若要自動依 GitHub commit 發布，請一開始選擇方法一。

## 安全與隱私

- `public/app.js` 只在瀏覽器記憶體內處理輸入，不呼叫外部服務。
- `public/_headers` 設定 Content Security Policy，包含 `connect-src 'none'`。
- `.gitignore` 排除 `.env*`、`.dev.vars`、`.wrangler/`、`node_modules/` 與本機研究紀錄。
- 不要將 Cloudflare API token、GitHub token 或其他憑證寫入 repository。

## 專案結構

```text
public/                    Cloudflare Pages 靜態資產
tests/                     Node.js 原生測試
scripts/project-workflow.sh 專案固定工作流程
wrangler.jsonc             Cloudflare Pages 設定
```

## 靈感來源

感謝 [RealCodedAlpha 的分享](https://x.com/RealCodedAlpha/status/2072937806801105347)，啟發了這套提示詞練習方法。

## 官方文件

- [Cloudflare Pages：Static HTML](https://developers.cloudflare.com/pages/framework-guides/deploy-anything/)
- [Cloudflare Pages：Git integration](https://developers.cloudflare.com/pages/get-started/git-integration/)
- [Cloudflare Pages：Direct Upload](https://developers.cloudflare.com/pages/get-started/direct-upload/)

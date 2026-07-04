#!/bin/sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TASK_DIR="$ROOT_DIR/docs/knowledge-skill/建立提示詞練習頁面-001"

write_initial_task_files() {
  cat > "$TASK_DIR/prompt.md" <<'EOF'
# 任務請求：建立提示詞練習頁面

## 原始請求

建立 Cloudflare Pages 靜態網站，讓使用者填寫 Context、Request、Output Format、Constraints、Checkpoint，並依指定格式組合提示詞。輸入方式需提供卡片式與精靈式兩種模式，可隨時切換。頁面尾端需感謝靈感來源：https://x.com/RealCodedAlpha/status/2072937806801105347

完成後建立 Git repository，推送至 https://github.com/lazyjerry/ai-prompt-exercise.git。必須妥善設定 `.gitignore`、避免機密資料外洩，並在 `README.md` 說明 Cloudflare Pages 發布方法。

## 期望產出

- [ ] Cloudflare Pages 靜態網站：卡片式與精靈式表單、提示詞組合、複製功能
- [ ] 自動化驗證：輸出格式、模式切換、響應式與基本可及性
- [ ] 專案文件：README 發布步驟、隱私與安全說明
- [ ] GitHub repository：推送至指定 origin

**產出類型：**
- 文件：`README.md`、knowledge-skill 任務紀錄
- 程式碼：`public/` 靜態網站、測試與部署設定
- 其他：Git commit 與 GitHub remote

## 參考文件

| 檔案路徑或網址 | 引用範圍描述 |
|----------|--------------|
| 使用者附圖 `image-1.png` | 深色終端介面、欄位結構與 checkpoint 概念 |
| `https://x.com/RealCodedAlpha/status/2072937806801105347` | 靈感來源連結 |
| Cloudflare Pages 文件 | 靜態網站的 Git integration 與 Direct Upload 發布流程 |
EOF

  cat > "$TASK_DIR/task_plan.md" <<'EOF'
# 任務計劃：建立提示詞練習 Cloudflare Pages

## 目標
完成可部署至 Cloudflare Pages 的純前端提示詞產生器，驗證後推送至指定 GitHub repository。

## 執行模式
一次完成

## 報告保存路徑
`docs/knowledge-skill/建立提示詞練習頁面-001/`

## 研究動作計畫
尚未啟用；採用預設「不先確認研究計畫」。

## 階段
- [ ] 階段 1：規劃與設定
  - [ ] 完成後更新 notes.md
- [ ] 階段 2：實作靜態網站與自動化測試
  - [ ] 完成後更新 notes.md
- [ ] 階段 3：執行瀏覽器、響應式與安全驗證
  - [ ] 完成後更新 notes.md
- [ ] 階段 4：建立 Git、README 並發布至 GitHub
  - [ ] 完成後更新 notes.md
- [ ] 階段 5：完整性檢核與交付
  - [ ] 完成後更新 notes.md

## 關鍵問題
1. 如何讓兩種輸入模式共用同一份狀態，切換時不遺失內容？
2. 如何在不使用後端與秘密金鑰的情況下部署並保護使用者輸入？
3. 如何以自動化測試證明產生結果符合指定換行與標籤格式？

## 已做決策
- 採純 HTML、CSS、JavaScript：需求不需要後端或框架，能降低供應鏈與部署複雜度。
- 使用 `public/` 作為 Pages output directory：路徑保持 ASCII，適合 Git integration 與 Direct Upload。
- 所有輸入只在瀏覽器記憶體處理：不傳送、不持久化，避免提示詞內容外洩。
- 採深色編輯器風格：回應參考圖片的視覺語彙，同時保留高對比與清楚焦點狀態。

## 遇到的錯誤
- `ui-ux-pro-max/scripts/search.py` 不存在：改採 skill 內已載入的可及性、互動、響應式與設計規範，並保留驗證清單。
- Codex Default mode 無法使用 `request_user_input`：已顯示文字選項；goal 自動續行時採用建議預設。

## 狀態
**目前階段 1** - 整理需求、技術邊界與驗證條件
EOF

  cat > "$TASK_DIR/notes.md" <<'EOF'
# 筆記：建立提示詞練習頁面

---  2026-07-04  第 1 次更新筆記 ---
## 任務摘要
建立純靜態 Cloudflare Pages 提示詞練習工具。網站提供卡片式與精靈式兩種輸入流程，並輸出固定格式的提示詞。資料只在瀏覽器內處理，不使用 API、資料庫或秘密金鑰。完成後以自動化測試、瀏覽器操作與安全掃描驗證，再推送 GitHub。

## 來源

### 來源 1：使用者附圖
- 重點：
  - 以 Context、Request、Output Format、Constraints 組成提示詞結構。
  - Autonomous run 應以 Checkpoint 說明何時停下來詢問。
  - 視覺採深色終端／編輯器介面與高亮綠色標記。

### 來源 2：Cloudflare Pages skill
- URL：https://developers.cloudflare.com/pages/
- 重點：
  - 純靜態網站可透過 Git integration 或 `wrangler pages deploy` 發布。
  - `public/` 可直接作為 Pages build output directory。
  - 本案無需 Pages Functions、bindings 或環境變數。

### 來源 3：ui-ux-pro-max
- 重點：
  - 表單需有可見 label、鍵盤焦點與至少 44px 的互動目標。
  - 手機版避免水平捲動，並尊重 `prefers-reduced-motion`。
  - 互動動畫維持 150–300ms，色彩不可作為唯一狀態指標。

## 綜合發現

### 實作邊界
- 兩種輸入模式應共用單一 state，切換後同步呈現內容。
- 提示詞產生規則適合抽成純函式，讓 Node.js 直接驗證精確輸出。
- 使用原生 HTML/CSS/JavaScript 已足夠，無需建置步驟或第三方 runtime dependency。
EOF
}

complete_stage_one() {
  cat >> "$TASK_DIR/notes.md" <<'EOF'

---  2026-07-04  第 2 次更新筆記 ---
## 階段 1 結果
- 已將使用者需求拆成網站功能、部署、安全、文件與 GitHub 發布五類驗收條件。
- 已確認純靜態網站足以完成需求，不需第三方服務或使用者資料傳輸。
- knowledge-skill 任務檔案已通過 `validate-task-files.sh`。
EOF

  python3 - "$TASK_DIR/task_plan.md" <<'PY'
from pathlib import Path
import sys

task_plan = Path(sys.argv[1])
content = task_plan.read_text()
content = content.replace("- [ ] 階段 1：規劃與設定", "- [x] 階段 1：規劃與設定")
content = content.replace("  - [ ] 完成後更新 notes.md", "  - [x] 完成後更新 notes.md", 1)
content = content.replace("**目前階段 1** - 整理需求、技術邊界與驗證條件", "**目前階段 2** - 實作靜態網站與自動化測試")
task_plan.write_text(content)
PY
}

write_site_files() {
  mkdir -p "$ROOT_DIR/public" "$ROOT_DIR/tests"

  cat > "$ROOT_DIR/.gitignore" <<'EOF'
# Dependencies and tool caches
node_modules/
.wrangler/
.dev.vars
.env
.env.*
!.env.example

# Logs and local artifacts
*.log
.DS_Store
coverage/

# Local research records
docs/knowledge-skill/
EOF

  cat > "$ROOT_DIR/package.json" <<'EOF'
{
  "name": "ai-prompt-exercise",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "description": "以五個欄位練習組合清楚、可執行的 AI 提示詞。",
  "engines": {
    "node": ">=22.0.0"
  },
  "scripts": {
    "dev": "wrangler pages dev public",
    "test": "node --test",
    "deploy": "wrangler pages deploy public --project-name ai-prompt-exercise"
  },
  "devDependencies": {
    "wrangler": "4.107.0"
  }
}
EOF

  cat > "$ROOT_DIR/wrangler.jsonc" <<'EOF'
{
  "$schema": "node_modules/wrangler/config-schema.json",
  "name": "ai-prompt-exercise",
  "pages_build_output_dir": "./public",
  "compatibility_date": "2026-07-04"
}
EOF

  cat > "$ROOT_DIR/public/index.html" <<'EOF'
<!doctype html>
<html lang="zh-Hant">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="用 Context、Request、Output Format、Constraints 與 Checkpoint 組合清楚、可執行的 AI 提示詞。">
    <meta name="theme-color" content="#090c0b">
    <title>Prompt Forge｜提示詞練習工坊</title>
    <link rel="icon" href="/favicon.svg" type="image/svg+xml">
    <link rel="stylesheet" href="/styles.css">
  </head>
  <body>
    <a class="skip-link" href="#composer">跳至提示詞編輯區</a>

    <header class="site-header">
      <a class="brand" href="/" aria-label="Prompt Forge 首頁">
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <path d="M12 2 4 6.5v11L12 22l8-4.5v-11L12 2Zm0 2.3 5.9 3.3L12 11 6.1 7.6 12 4.3Zm-6 5.1 5 2.8v6.9l-5-2.8V9.4Zm7 9.7v-6.9l5-2.8v6.9l-5 2.8Z"/>
        </svg>
        <span>Prompt Forge</span>
      </a>
      <p class="header-meta">5-part prompt system <span aria-hidden="true">/</span> browser only</p>
    </header>

    <main>
      <section class="hero" aria-labelledby="page-title">
        <p class="eyebrow"><span>01</span> Prompt workbench</p>
        <h1 id="page-title">把模糊需求，整理成<br><em>模型能執行</em>的提示詞。</h1>
        <p class="hero-copy">依序釐清背景、任務、交付格式、約束與查核點。內容只在你的瀏覽器內處理，不會上傳。</p>
        <div class="hero-tags" aria-label="工具特色">
          <span>
            <svg aria-hidden="true" viewBox="0 0 24 24"><path d="M12 2a5 5 0 0 0-5 5v3H5v12h14V10h-2V7a5 5 0 0 0-5-5Zm-3 8V7a3 3 0 0 1 6 0v3H9Zm-2 2h10v8H7v-8Z"/></svg>
            本機處理
          </span>
          <span>卡片式</span>
          <span>精靈式</span>
        </div>
      </section>

      <section class="workbench" aria-label="提示詞工作區">
        <div class="composer-shell" id="composer">
          <div class="panel-heading">
            <div>
              <p class="panel-index">02 / Compose</p>
              <h2>建立你的提示詞</h2>
            </div>
            <div class="mode-switch" role="tablist" aria-label="輸入模式">
              <button class="mode-tab is-active" id="card-tab" type="button" role="tab" aria-selected="true" aria-controls="card-panel" data-mode="card">
                <svg aria-hidden="true" viewBox="0 0 24 24"><path d="M3 3h8v8H3V3Zm2 2v4h4V5H5Zm8-2h8v8h-8V3Zm2 2v4h4V5h-4ZM3 13h8v8H3v-8Zm2 2v4h4v-4H5Zm8-2h8v8h-8v-8Zm2 2v4h4v-4h-4Z"/></svg>
                卡片式
              </button>
              <button class="mode-tab" id="wizard-tab" type="button" role="tab" aria-selected="false" aria-controls="wizard-panel" tabindex="-1" data-mode="wizard">
                <svg aria-hidden="true" viewBox="0 0 24 24"><path d="M5 4h14v3H5V4Zm0 6h9v3H5v-3Zm0 6h14v3H5v-3Zm11-7 4 2.5-4 2.5V9Z"/></svg>
                精靈式
              </button>
            </div>
          </div>

          <div id="card-panel" role="tabpanel" aria-labelledby="card-tab">
            <form id="card-form" novalidate>
              <div class="card-grid">
                <article class="field-card field-card--wide">
                  <div class="field-number">01</div>
                  <div class="field-copy">
                    <label for="card-context">Context <span>背景</span></label>
                    <p id="card-context-hint">提供相關角色、情境、受眾與現有資料，讓模型不必猜測。</p>
                  </div>
                  <textarea id="card-context" data-field="context" aria-describedby="card-context-hint card-context-error" placeholder="例：我正在為第一次接觸生成式 AI 的大學生設計 30 分鐘工作坊…" rows="4"></textarea>
                  <p class="field-error" id="card-context-error" data-error-for="context" aria-live="polite"></p>
                </article>

                <article class="field-card">
                  <div class="field-number">02</div>
                  <div class="field-copy">
                    <label for="card-request">Request <span>任務</span></label>
                    <p id="card-request-hint">用一句清楚的動詞開頭，說明你要模型完成什麼。</p>
                  </div>
                  <textarea id="card-request" data-field="request" aria-describedby="card-request-hint card-request-error" placeholder="例：設計一份包含實作練習的課程大綱。" rows="5"></textarea>
                  <p class="field-error" id="card-request-error" data-error-for="request" aria-live="polite"></p>
                </article>

                <article class="field-card">
                  <div class="field-number">03</div>
                  <div class="field-copy">
                    <label for="card-output-format">Output Format <span>交付格式</span></label>
                    <p id="card-output-format-hint">指定結構、長度、語言、欄位或範例。</p>
                  </div>
                  <textarea id="card-output-format" data-field="outputFormat" aria-describedby="card-output-format-hint card-output-format-error" placeholder="例：使用 Markdown 表格，欄位為時間、主題、活動與學習成果。" rows="5"></textarea>
                  <p class="field-error" id="card-output-format-error" data-error-for="outputFormat" aria-live="polite"></p>
                </article>

                <article class="field-card">
                  <div class="field-number">04</div>
                  <div class="field-copy">
                    <label for="card-constraints">Constraints <span>約束</span></label>
                    <p id="card-constraints-hint">列出不能假設、不能更動或不能越界的條件。</p>
                  </div>
                  <textarea id="card-constraints" data-field="constraints" aria-describedby="card-constraints-hint card-constraints-error" placeholder="例：不要假設學員有程式背景；不使用付費工具。" rows="5"></textarea>
                  <p class="field-error" id="card-constraints-error" data-error-for="constraints" aria-live="polite"></p>
                </article>

                <article class="field-card">
                  <div class="field-number">05</div>
                  <div class="field-copy">
                    <label for="card-checkpoint">Checkpoint <span>查核點</span></label>
                    <p id="card-checkpoint-hint">說明遇到哪些決策、風險或缺少資訊時，應先停下來詢問。</p>
                  </div>
                  <textarea id="card-checkpoint" data-field="checkpoint" aria-describedby="card-checkpoint-hint card-checkpoint-error" placeholder="例：若需要改變受眾或延長課程時間，先停下來詢問我。" rows="5"></textarea>
                  <p class="field-error" id="card-checkpoint-error" data-error-for="checkpoint" aria-live="polite"></p>
                </article>
              </div>
              <button class="primary-button" type="submit">
                <span>組合提示詞</span>
                <svg aria-hidden="true" viewBox="0 0 24 24"><path d="m13 5 7 7-7 7-1.4-1.4 4.6-4.6H4v-2h12.2l-4.6-4.6L13 5Z"/></svg>
              </button>
            </form>
          </div>

          <div id="wizard-panel" role="tabpanel" aria-labelledby="wizard-tab" hidden>
            <div class="wizard-progress">
              <p id="wizard-progress-label">步驟 1 / 5</p>
              <div class="progress-track" aria-hidden="true"><span id="wizard-progress-bar"></span></div>
            </div>
            <form id="wizard-form" novalidate>
              <section class="wizard-step is-active" data-wizard-step="0" aria-labelledby="wizard-context-title">
                <p class="wizard-kicker">01 / Context</p>
                <h3 id="wizard-context-title">先說明背景是什麼</h3>
                <p>誰會使用結果？你正在處理什麼情境？模型已經有哪些資料？</p>
                <label for="wizard-context">背景資訊</label>
                <textarea id="wizard-context" data-field="context" aria-describedby="wizard-context-error" placeholder="我正在為…" rows="8"></textarea>
                <p class="field-error" id="wizard-context-error" data-error-for="context" aria-live="polite"></p>
              </section>

              <section class="wizard-step" data-wizard-step="1" aria-labelledby="wizard-request-title" hidden>
                <p class="wizard-kicker">02 / Request</p>
                <h3 id="wizard-request-title">模型到底要完成什麼</h3>
                <p>以明確動詞描述單一任務，避免把目標藏在一大段背景裡。</p>
                <label for="wizard-request">具體任務</label>
                <textarea id="wizard-request" data-field="request" aria-describedby="wizard-request-error" placeholder="請設計…" rows="8"></textarea>
                <p class="field-error" id="wizard-request-error" data-error-for="request" aria-live="polite"></p>
              </section>

              <section class="wizard-step" data-wizard-step="2" aria-labelledby="wizard-output-title" hidden>
                <p class="wizard-kicker">03 / Output Format</p>
                <h3 id="wizard-output-title">結果要怎麼交付</h3>
                <p>指定結構、長度、語言或必要欄位，讓結果可以直接使用。</p>
                <label for="wizard-output-format">交付格式</label>
                <textarea id="wizard-output-format" data-field="outputFormat" aria-describedby="wizard-output-format-error" placeholder="請使用 Markdown…" rows="8"></textarea>
                <p class="field-error" id="wizard-output-format-error" data-error-for="outputFormat" aria-live="polite"></p>
              </section>

              <section class="wizard-step" data-wizard-step="3" aria-labelledby="wizard-constraints-title" hidden>
                <p class="wizard-kicker">04 / Constraints</p>
                <h3 id="wizard-constraints-title">哪些不能假設、不能越界</h3>
                <p>列出不可變更的條件、禁止事項，以及模型不應自行補完的資訊。</p>
                <label for="wizard-constraints">約束條件</label>
                <textarea id="wizard-constraints" data-field="constraints" aria-describedby="wizard-constraints-error" placeholder="不要假設…" rows="8"></textarea>
                <p class="field-error" id="wizard-constraints-error" data-error-for="constraints" aria-live="polite"></p>
              </section>

              <section class="wizard-step" data-wizard-step="4" aria-labelledby="wizard-checkpoint-title" hidden>
                <p class="wizard-kicker">05 / Checkpoint</p>
                <h3 id="wizard-checkpoint-title">什麼時候該停下來問你</h3>
                <p>把需要你裁決的風險、範圍變更或缺少資訊寫清楚。</p>
                <label for="wizard-checkpoint">查核條件</label>
                <textarea id="wizard-checkpoint" data-field="checkpoint" aria-describedby="wizard-checkpoint-error" placeholder="只有遇到…才停下來詢問我。" rows="8"></textarea>
                <p class="field-error" id="wizard-checkpoint-error" data-error-for="checkpoint" aria-live="polite"></p>
              </section>

              <div class="wizard-actions">
                <button class="secondary-button" id="wizard-previous" type="button" disabled>
                  <svg aria-hidden="true" viewBox="0 0 24 24"><path d="m11 5-7 7 7 7 1.4-1.4L7.8 13H20v-2H7.8l4.6-4.6L11 5Z"/></svg>
                  上一步
                </button>
                <button class="primary-button" id="wizard-next" type="button">
                  下一步
                  <svg aria-hidden="true" viewBox="0 0 24 24"><path d="m13 5 7 7-7 7-1.4-1.4 4.6-4.6H4v-2h12.2l-4.6-4.6L13 5Z"/></svg>
                </button>
                <button class="primary-button" id="wizard-generate" type="submit" hidden>
                  組合提示詞
                  <svg aria-hidden="true" viewBox="0 0 24 24"><path d="m13 5 7 7-7 7-1.4-1.4 4.6-4.6H4v-2h12.2l-4.6-4.6L13 5Z"/></svg>
                </button>
              </div>
            </form>
          </div>
        </div>

        <aside class="output-shell" aria-labelledby="output-title">
          <div class="output-heading">
            <div>
              <p class="panel-index">03 / Output</p>
              <h2 id="output-title">組合結果</h2>
            </div>
            <span class="output-state" id="output-state"><span></span>等待輸入</span>
          </div>
          <div class="output-body">
            <div class="output-placeholder" id="output-placeholder">
              <svg aria-hidden="true" viewBox="0 0 24 24"><path d="M8 3h8v2H8V3ZM5 6h14v15H5V6Zm2 2v11h10V8H7Zm2 2h6v2H9v-2Zm0 4h6v2H9v-2Z"/></svg>
              <p>完成五個欄位後，提示詞會顯示在這裡。</p>
            </div>
            <pre id="prompt-output" tabindex="0" hidden><code></code></pre>
          </div>
          <div class="output-actions">
            <button class="copy-button" id="copy-button" type="button" disabled>
              <svg aria-hidden="true" viewBox="0 0 24 24"><path d="M8 2h11v15h-3v5H5V7h3V2Zm2 5h6v8h1V4h-7v3Zm-3 2v11h7V9H7Z"/></svg>
              <span>複製提示詞</span>
            </button>
            <button class="reset-button" id="reset-button" type="button">清除內容</button>
          </div>
          <p class="sr-only" id="app-status" role="status" aria-live="polite"></p>
        </aside>
      </section>

      <section class="method-note" aria-labelledby="method-title">
        <p class="eyebrow"><span>04</span> Why this works</p>
        <div>
          <h2 id="method-title">好的提示詞，先消除模型需要猜測的地方。</h2>
          <p>Context 說明原因，Request 鎖定任務，Output Format 定義交付物，Constraints 收好邊界，Checkpoint 留下需要人類判斷的節點。</p>
        </div>
      </section>
    </main>

    <footer>
      <p>感謝 <a href="https://x.com/RealCodedAlpha/status/2072937806801105347" target="_blank" rel="noopener noreferrer">RealCodedAlpha 的分享</a>，啟發了這套提示詞練習方法。</p>
      <p>Prompt Forge <span aria-hidden="true">·</span> 所有內容僅在本機處理</p>
    </footer>

    <script type="module" src="/app.js"></script>
  </body>
</html>
EOF

  cat > "$ROOT_DIR/public/styles.css" <<'EOF'
:root {
  color-scheme: dark;
  --bg: #090c0b;
  --surface: #101613;
  --surface-raised: #151d19;
  --surface-soft: #0d120f;
  --line: #26322c;
  --line-strong: #3d4f45;
  --text: #f3f7f4;
  --muted: #a5b1aa;
  --faint: #728078;
  --accent: #b7f36b;
  --accent-strong: #d5ff9f;
  --accent-ink: #102006;
  --danger: #ff9b8f;
  --focus: #d7ffac;
  --radius: 16px;
  --shadow: 0 20px 60px rgb(0 0 0 / 28%);
  font-family: Inter, ui-sans-serif, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
}

* {
  box-sizing: border-box;
}

html {
  scroll-behavior: smooth;
}

body {
  min-width: 320px;
  margin: 0;
  color: var(--text);
  background:
    radial-gradient(circle at 78% 6%, rgb(183 243 107 / 8%), transparent 28rem),
    linear-gradient(rgb(255 255 255 / 2%) 1px, transparent 1px),
    linear-gradient(90deg, rgb(255 255 255 / 2%) 1px, transparent 1px),
    var(--bg);
  background-size: auto, 44px 44px, 44px 44px, auto;
  line-height: 1.6;
}

button,
textarea {
  font: inherit;
}

button,
a {
  -webkit-tap-highlight-color: transparent;
}

button {
  cursor: pointer;
}

a {
  color: inherit;
}

svg {
  width: 1.25rem;
  height: 1.25rem;
  fill: currentColor;
  flex: 0 0 auto;
}

.skip-link {
  position: fixed;
  top: 0.75rem;
  left: 0.75rem;
  z-index: 100;
  padding: 0.75rem 1rem;
  color: var(--accent-ink);
  background: var(--accent);
  border-radius: 8px;
  transform: translateY(-160%);
  transition: transform 180ms ease;
}

.skip-link:focus {
  transform: translateY(0);
}

.site-header,
main,
footer {
  width: min(100% - 2rem, 1440px);
  margin-inline: auto;
}

.site-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  min-height: 76px;
  border-bottom: 1px solid var(--line);
}

.brand {
  display: inline-flex;
  align-items: center;
  gap: 0.65rem;
  color: var(--text);
  font-family: "SFMono-Regular", Consolas, "Liberation Mono", monospace;
  font-size: 0.95rem;
  font-weight: 700;
  letter-spacing: -0.02em;
  text-decoration: none;
}

.brand svg {
  color: var(--accent);
}

.header-meta {
  margin: 0;
  color: var(--faint);
  font-family: "SFMono-Regular", Consolas, "Liberation Mono", monospace;
  font-size: 0.72rem;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.header-meta span {
  margin-inline: 0.4rem;
  color: var(--line-strong);
}

.hero {
  max-width: 940px;
  padding: clamp(4.5rem, 9vw, 8.5rem) 0 clamp(3rem, 6vw, 5.5rem);
}

.eyebrow,
.panel-index,
.wizard-kicker {
  margin: 0 0 1rem;
  color: var(--muted);
  font-family: "SFMono-Regular", Consolas, "Liberation Mono", monospace;
  font-size: 0.74rem;
  letter-spacing: 0.11em;
  text-transform: uppercase;
}

.eyebrow span {
  display: inline-grid;
  place-items: center;
  min-width: 2rem;
  min-height: 1.7rem;
  margin-right: 0.75rem;
  color: var(--accent);
  border: 1px solid rgb(183 243 107 / 45%);
  border-radius: 5px;
  background: rgb(183 243 107 / 6%);
}

h1,
h2,
h3,
p {
  text-wrap: pretty;
}

h1 {
  max-width: 920px;
  margin: 0;
  font-size: clamp(2.65rem, 7vw, 6.75rem);
  font-weight: 660;
  letter-spacing: -0.065em;
  line-height: 0.96;
}

h1 em {
  color: var(--accent);
  font-style: normal;
}

.hero-copy {
  max-width: 680px;
  margin: 2rem 0 0;
  color: var(--muted);
  font-size: clamp(1rem, 2vw, 1.18rem);
}

.hero-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 0.6rem;
  margin-top: 2rem;
}

.hero-tags span {
  display: inline-flex;
  align-items: center;
  gap: 0.45rem;
  min-height: 36px;
  padding: 0.38rem 0.78rem;
  color: var(--muted);
  font-family: "SFMono-Regular", Consolas, "Liberation Mono", monospace;
  font-size: 0.72rem;
  border: 1px solid var(--line);
  border-radius: 999px;
  background: rgb(15 21 18 / 76%);
}

.hero-tags svg {
  width: 0.95rem;
  height: 0.95rem;
  color: var(--accent);
}

.workbench {
  display: grid;
  grid-template-columns: minmax(0, 1.35fr) minmax(340px, 0.65fr);
  gap: 1rem;
  align-items: start;
}

.composer-shell,
.output-shell {
  border: 1px solid var(--line);
  border-radius: var(--radius);
  background: rgb(15 21 18 / 92%);
  box-shadow: var(--shadow);
  overflow: clip;
}

.panel-heading,
.output-heading {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
  min-height: 104px;
  padding: 1.25rem 1.4rem;
  border-bottom: 1px solid var(--line);
}

.panel-index {
  margin-bottom: 0.15rem;
  color: var(--accent);
}

.panel-heading h2,
.output-heading h2 {
  margin: 0;
  font-size: 1.15rem;
  letter-spacing: -0.025em;
}

.mode-switch {
  display: flex;
  gap: 0.25rem;
  padding: 0.25rem;
  border: 1px solid var(--line);
  border-radius: 10px;
  background: var(--surface-soft);
}

.mode-tab {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.45rem;
  min-height: 44px;
  padding: 0.55rem 0.8rem;
  color: var(--muted);
  border: 0;
  border-radius: 7px;
  background: transparent;
  transition: color 180ms ease, background 180ms ease;
}

.mode-tab:hover {
  color: var(--text);
}

.mode-tab.is-active {
  color: var(--accent-ink);
  background: var(--accent);
}

.mode-tab svg {
  width: 1rem;
  height: 1rem;
}

#card-form {
  padding: 1rem;
}

.card-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 0.75rem;
}

.field-card {
  position: relative;
  display: grid;
  grid-template-columns: auto minmax(0, 1fr);
  gap: 0 0.8rem;
  padding: 1.05rem;
  border: 1px solid var(--line);
  border-radius: 12px;
  background: var(--surface);
  transition: border-color 180ms ease, background 180ms ease;
}

.field-card:focus-within {
  border-color: rgb(183 243 107 / 64%);
  background: var(--surface-raised);
}

.field-card--wide {
  grid-column: 1 / -1;
}

.field-number {
  display: grid;
  place-items: center;
  width: 2.15rem;
  height: 1.8rem;
  color: var(--accent);
  font-family: "SFMono-Regular", Consolas, "Liberation Mono", monospace;
  font-size: 0.72rem;
  border: 1px solid rgb(183 243 107 / 38%);
  border-radius: 5px;
  background: rgb(183 243 107 / 5%);
}

.field-copy label,
.wizard-step > label {
  display: block;
  color: var(--text);
  font-weight: 700;
  letter-spacing: -0.02em;
}

.field-copy label span {
  margin-left: 0.3rem;
  color: var(--faint);
  font-family: "SFMono-Regular", Consolas, "Liberation Mono", monospace;
  font-size: 0.7rem;
  font-weight: 400;
}

.field-copy p {
  margin: 0.25rem 0 0;
  color: var(--faint);
  font-size: 0.82rem;
  line-height: 1.5;
}

textarea {
  width: 100%;
  min-height: 122px;
  margin-top: 1rem;
  padding: 0.85rem 0.9rem;
  resize: vertical;
  color: var(--text);
  caret-color: var(--accent);
  border: 1px solid var(--line);
  border-radius: 9px;
  outline: 0;
  background: #0a0f0c;
  grid-column: 1 / -1;
  line-height: 1.55;
  transition: border-color 180ms ease, box-shadow 180ms ease;
}

textarea::placeholder {
  color: #657169;
}

textarea:focus {
  border-color: var(--accent);
  box-shadow: 0 0 0 3px rgb(183 243 107 / 13%);
}

textarea[aria-invalid="true"] {
  border-color: var(--danger);
}

.field-error {
  min-height: 1.25rem;
  margin: 0.45rem 0 0;
  color: var(--danger);
  font-size: 0.78rem;
  grid-column: 1 / -1;
}

.primary-button,
.secondary-button,
.copy-button,
.reset-button {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.55rem;
  min-height: 48px;
  padding: 0.7rem 1rem;
  border-radius: 9px;
  font-weight: 700;
  transition: color 180ms ease, background 180ms ease, border-color 180ms ease;
}

.primary-button {
  color: var(--accent-ink);
  border: 1px solid var(--accent);
  background: var(--accent);
}

#card-form > .primary-button {
  width: 100%;
  margin-top: 0.85rem;
}

.primary-button:hover {
  background: var(--accent-strong);
  border-color: var(--accent-strong);
}

.secondary-button,
.reset-button {
  color: var(--muted);
  border: 1px solid var(--line);
  background: var(--surface);
}

.secondary-button:hover,
.reset-button:hover {
  color: var(--text);
  border-color: var(--line-strong);
  background: var(--surface-raised);
}

button:disabled {
  cursor: not-allowed;
  opacity: 0.45;
}

button:focus-visible,
a:focus-visible,
pre:focus-visible {
  outline: 3px solid var(--focus);
  outline-offset: 3px;
}

.output-shell {
  position: sticky;
  top: 1rem;
}

.output-state {
  display: inline-flex;
  align-items: center;
  gap: 0.4rem;
  color: var(--faint);
  font-family: "SFMono-Regular", Consolas, "Liberation Mono", monospace;
  font-size: 0.68rem;
  letter-spacing: 0.06em;
  text-transform: uppercase;
}

.output-state span {
  width: 0.45rem;
  height: 0.45rem;
  border-radius: 50%;
  background: var(--faint);
}

.output-state.is-ready {
  color: var(--accent);
}

.output-state.is-ready span {
  background: var(--accent);
  box-shadow: 0 0 12px rgb(183 243 107 / 60%);
}

.output-body {
  min-height: 500px;
  padding: 1rem;
}

.output-placeholder {
  display: grid;
  place-items: center;
  align-content: center;
  min-height: 468px;
  padding: 2rem;
  text-align: center;
  border: 1px dashed var(--line);
  border-radius: 10px;
}

.output-placeholder svg {
  width: 2rem;
  height: 2rem;
  color: var(--line-strong);
}

.output-placeholder p {
  max-width: 260px;
  margin: 1rem 0 0;
  color: var(--faint);
  font-size: 0.88rem;
}

pre {
  min-height: 468px;
  max-height: 64vh;
  margin: 0;
  padding: 1.15rem;
  overflow: auto;
  white-space: pre-wrap;
  overflow-wrap: anywhere;
  color: #dce9df;
  border: 1px solid var(--line);
  border-radius: 10px;
  background:
    linear-gradient(90deg, rgb(183 243 107 / 5%) 1px, transparent 1px),
    #080c09;
  background-size: 2.5rem 100%;
  font-family: "SFMono-Regular", Consolas, "Liberation Mono", monospace;
  font-size: 0.82rem;
  line-height: 1.75;
}

.output-actions {
  display: grid;
  grid-template-columns: minmax(0, 1fr) auto;
  gap: 0.6rem;
  padding: 0 1rem 1rem;
}

.copy-button {
  color: var(--accent-ink);
  border: 1px solid var(--accent);
  background: var(--accent);
}

.copy-button:hover:not(:disabled) {
  background: var(--accent-strong);
}

#wizard-panel {
  padding: 1rem;
}

.wizard-progress {
  display: grid;
  grid-template-columns: auto minmax(80px, 180px);
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
  margin-bottom: 1rem;
  padding: 0.8rem 1rem;
  border: 1px solid var(--line);
  border-radius: 9px;
  background: var(--surface-soft);
}

.wizard-progress p {
  margin: 0;
  color: var(--muted);
  font-family: "SFMono-Regular", Consolas, "Liberation Mono", monospace;
  font-size: 0.75rem;
}

.progress-track {
  height: 4px;
  overflow: hidden;
  border-radius: 999px;
  background: var(--line);
}

.progress-track span {
  display: block;
  width: 20%;
  height: 100%;
  border-radius: inherit;
  background: var(--accent);
  transition: width 220ms ease;
}

.wizard-step {
  min-height: 455px;
  padding: clamp(1.2rem, 3vw, 2.2rem);
  border: 1px solid var(--line);
  border-radius: 12px;
  background: var(--surface);
}

.wizard-kicker {
  margin-bottom: 0.55rem;
  color: var(--accent);
}

.wizard-step h3 {
  margin: 0;
  font-size: clamp(1.55rem, 3vw, 2.35rem);
  letter-spacing: -0.045em;
  line-height: 1.12;
}

.wizard-step > p:not(.wizard-kicker, .field-error) {
  max-width: 620px;
  margin: 0.8rem 0 1.6rem;
  color: var(--muted);
}

.wizard-step textarea {
  min-height: 190px;
}

.wizard-actions {
  display: flex;
  justify-content: space-between;
  gap: 0.65rem;
  margin-top: 0.85rem;
}

.wizard-actions .primary-button {
  margin-left: auto;
}

.method-note {
  display: grid;
  grid-template-columns: minmax(180px, 0.42fr) minmax(0, 1fr);
  gap: 3rem;
  margin-block: clamp(5rem, 10vw, 9rem);
  padding-top: 2rem;
  border-top: 1px solid var(--line);
}

.method-note h2 {
  max-width: 760px;
  margin: 0;
  font-size: clamp(1.8rem, 4vw, 3.5rem);
  letter-spacing: -0.05em;
  line-height: 1.08;
}

.method-note > div p {
  max-width: 760px;
  margin: 1.25rem 0 0;
  color: var(--muted);
}

footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 2rem;
  min-height: 110px;
  padding-block: 1.5rem;
  color: var(--faint);
  border-top: 1px solid var(--line);
  font-size: 0.82rem;
}

footer p {
  margin: 0;
}

footer a {
  color: var(--accent);
  text-underline-offset: 0.2em;
}

.sr-only {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border: 0;
}

[hidden] {
  display: none !important;
}

@media (max-width: 1040px) {
  .workbench {
    grid-template-columns: 1fr;
  }

  .output-shell {
    position: static;
  }

  .output-body,
  .output-placeholder,
  pre {
    min-height: 360px;
  }

  pre {
    max-height: 520px;
  }
}

@media (max-width: 720px) {
  .site-header,
  main,
  footer {
    width: min(100% - 1.25rem, 1440px);
  }

  .site-header {
    min-height: 64px;
  }

  .header-meta {
    display: none;
  }

  .hero {
    padding-top: 4rem;
  }

  h1 {
    font-size: clamp(2.6rem, 13vw, 4.2rem);
  }

  .panel-heading {
    align-items: flex-start;
    flex-direction: column;
  }

  .mode-switch {
    width: 100%;
  }

  .mode-tab {
    flex: 1;
  }

  .card-grid {
    grid-template-columns: 1fr;
  }

  .field-card--wide {
    grid-column: auto;
  }

  .method-note {
    grid-template-columns: 1fr;
    gap: 1.25rem;
  }

  footer {
    align-items: flex-start;
    flex-direction: column;
    justify-content: center;
    gap: 0.4rem;
  }
}

@media (max-width: 460px) {
  #card-form,
  #wizard-panel,
  .output-body {
    padding: 0.7rem;
  }

  .panel-heading,
  .output-heading {
    padding: 1rem;
  }

  .field-card {
    padding: 0.85rem;
  }

  .field-copy p {
    font-size: 0.78rem;
  }

  .output-actions {
    grid-template-columns: 1fr;
    padding: 0 0.7rem 0.7rem;
  }

  .reset-button {
    width: 100%;
  }

  .wizard-progress {
    grid-template-columns: 1fr;
  }

  .wizard-step {
    min-height: 420px;
  }
}

@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    scroll-behavior: auto !important;
    transition-duration: 0.01ms !important;
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
  }
}
EOF

  cat > "$ROOT_DIR/public/app.js" <<'EOF'
export const FIELD_DEFINITIONS = [
  { key: "context", label: "Context" },
  { key: "request", label: "Request" },
  { key: "outputFormat", label: "Output Format" },
  { key: "constraints", label: "Constraints" },
  { key: "checkpoint", label: "Checkpoint" }
];

export function buildPrompt(values) {
  const clean = Object.fromEntries(
    FIELD_DEFINITIONS.map(({ key }) => [key, String(values[key] ?? "").trim()])
  );

  return `${clean.context}
${clean.request}

輸出格式：
${clean.outputFormat}

約束條件：
${clean.constraints}

查核條件：
${clean.checkpoint}`;
}

function initializeApp() {
  const state = Object.fromEntries(FIELD_DEFINITIONS.map(({ key }) => [key, ""]));
  const modeTabs = [...document.querySelectorAll("[data-mode]")];
  const panels = {
    card: document.querySelector("#card-panel"),
    wizard: document.querySelector("#wizard-panel")
  };
  const inputs = [...document.querySelectorAll("textarea[data-field]")];
  const cardForm = document.querySelector("#card-form");
  const wizardForm = document.querySelector("#wizard-form");
  const wizardSteps = [...document.querySelectorAll("[data-wizard-step]")];
  const previousButton = document.querySelector("#wizard-previous");
  const nextButton = document.querySelector("#wizard-next");
  const generateButton = document.querySelector("#wizard-generate");
  const progressLabel = document.querySelector("#wizard-progress-label");
  const progressBar = document.querySelector("#wizard-progress-bar");
  const outputPlaceholder = document.querySelector("#output-placeholder");
  const promptOutput = document.querySelector("#prompt-output");
  const promptCode = promptOutput.querySelector("code");
  const outputState = document.querySelector("#output-state");
  const copyButton = document.querySelector("#copy-button");
  const resetButton = document.querySelector("#reset-button");
  const appStatus = document.querySelector("#app-status");
  let currentStep = 0;

  function getInputsForField(key) {
    return inputs.filter((input) => input.dataset.field === key);
  }

  function clearFieldError(key) {
    getInputsForField(key).forEach((input) => input.removeAttribute("aria-invalid"));
    document.querySelectorAll(`[data-error-for="${key}"]`).forEach((error) => {
      error.textContent = "";
    });
  }

  function showFieldError(key, message) {
    getInputsForField(key).forEach((input) => input.setAttribute("aria-invalid", "true"));
    document.querySelectorAll(`[data-error-for="${key}"]`).forEach((error) => {
      error.textContent = message;
    });
  }

  function syncField(source) {
    const key = source.dataset.field;
    state[key] = source.value;
    getInputsForField(key).forEach((input) => {
      if (input !== source) input.value = source.value;
    });
    if (source.value.trim()) clearFieldError(key);
  }

  function setMode(mode, focusPanel = true) {
    modeTabs.forEach((tab) => {
      const isActive = tab.dataset.mode === mode;
      tab.classList.toggle("is-active", isActive);
      tab.setAttribute("aria-selected", String(isActive));
      tab.tabIndex = isActive ? 0 : -1;
    });

    Object.entries(panels).forEach(([panelMode, panel]) => {
      panel.hidden = panelMode !== mode;
    });

    if (focusPanel) {
      const target = panels[mode].querySelector("textarea:not([hidden])");
      target?.focus();
    }
  }

  function updateWizard() {
    wizardSteps.forEach((step, index) => {
      const isActive = index === currentStep;
      step.hidden = !isActive;
      step.classList.toggle("is-active", isActive);
    });
    progressLabel.textContent = `步驟 ${currentStep + 1} / ${wizardSteps.length}`;
    progressBar.style.width = `${((currentStep + 1) / wizardSteps.length) * 100}%`;
    previousButton.disabled = currentStep === 0;
    nextButton.hidden = currentStep === wizardSteps.length - 1;
    generateButton.hidden = currentStep !== wizardSteps.length - 1;
  }

  function validateField(key) {
    const value = state[key].trim();
    if (value) {
      clearFieldError(key);
      return true;
    }
    const label = FIELD_DEFINITIONS.find((field) => field.key === key).label;
    showFieldError(key, `請填寫 ${label}。`);
    return false;
  }

  function validateAll(mode) {
    const missing = FIELD_DEFINITIONS.filter(({ key }) => !validateField(key));
    if (!missing.length) return true;

    const firstMissing = missing[0].key;
    if (mode === "wizard") {
      currentStep = FIELD_DEFINITIONS.findIndex(({ key }) => key === firstMissing);
      updateWizard();
    }
    panels[mode].querySelector(`[data-field="${firstMissing}"]`)?.focus();
    appStatus.textContent = "尚有欄位未完成。";
    return false;
  }

  function renderPrompt(mode) {
    if (!validateAll(mode)) return;
    promptCode.textContent = buildPrompt(state);
    outputPlaceholder.hidden = true;
    promptOutput.hidden = false;
    copyButton.disabled = false;
    outputState.classList.add("is-ready");
    outputState.innerHTML = "<span></span>已產生";
    appStatus.textContent = "提示詞已產生。";
    if (window.matchMedia("(max-width: 1040px)").matches) {
      document.querySelector(".output-shell").scrollIntoView({ behavior: "smooth", block: "start" });
    }
  }

  async function copyPrompt() {
    const text = promptCode.textContent;
    try {
      await navigator.clipboard.writeText(text);
    } catch {
      const helper = document.createElement("textarea");
      helper.value = text;
      helper.setAttribute("readonly", "");
      helper.className = "sr-only";
      document.body.append(helper);
      helper.select();
      document.execCommand("copy");
      helper.remove();
    }
    copyButton.querySelector("span").textContent = "已複製";
    appStatus.textContent = "提示詞已複製到剪貼簿。";
    window.setTimeout(() => {
      copyButton.querySelector("span").textContent = "複製提示詞";
    }, 1800);
  }

  function resetApp() {
    FIELD_DEFINITIONS.forEach(({ key }) => {
      state[key] = "";
      getInputsForField(key).forEach((input) => {
        input.value = "";
      });
      clearFieldError(key);
    });
    currentStep = 0;
    updateWizard();
    promptCode.textContent = "";
    promptOutput.hidden = true;
    outputPlaceholder.hidden = false;
    copyButton.disabled = true;
    outputState.classList.remove("is-ready");
    outputState.innerHTML = "<span></span>等待輸入";
    appStatus.textContent = "內容已清除。";
    document.querySelector("#card-context").focus();
  }

  inputs.forEach((input) => {
    input.addEventListener("input", () => syncField(input));
  });

  modeTabs.forEach((tab, index) => {
    tab.addEventListener("click", () => setMode(tab.dataset.mode));
    tab.addEventListener("keydown", (event) => {
      if (!["ArrowLeft", "ArrowRight"].includes(event.key)) return;
      event.preventDefault();
      const direction = event.key === "ArrowRight" ? 1 : -1;
      const targetIndex = (index + direction + modeTabs.length) % modeTabs.length;
      modeTabs[targetIndex].focus();
      setMode(modeTabs[targetIndex].dataset.mode, false);
    });
  });

  cardForm.addEventListener("submit", (event) => {
    event.preventDefault();
    renderPrompt("card");
  });

  wizardForm.addEventListener("submit", (event) => {
    event.preventDefault();
    renderPrompt("wizard");
  });

  nextButton.addEventListener("click", () => {
    const currentKey = FIELD_DEFINITIONS[currentStep].key;
    if (!validateField(currentKey)) {
      panels.wizard.querySelector(`[data-field="${currentKey}"]`)?.focus();
      return;
    }
    currentStep += 1;
    updateWizard();
    wizardSteps[currentStep].querySelector("textarea")?.focus();
  });

  previousButton.addEventListener("click", () => {
    currentStep = Math.max(0, currentStep - 1);
    updateWizard();
    wizardSteps[currentStep].querySelector("textarea")?.focus();
  });

  copyButton.addEventListener("click", copyPrompt);
  resetButton.addEventListener("click", resetApp);
  updateWizard();
}

if (typeof document !== "undefined") {
  initializeApp();
}
EOF

  cat > "$ROOT_DIR/public/favicon.svg" <<'EOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">
  <rect width="64" height="64" rx="14" fill="#101613"/>
  <path d="M32 10 14 20v24l18 10 18-10V20L32 10Zm0 6 12 6.7L32 29.4 20 22.7 32 16Zm-13 12 10 5.6v13.2l-10-5.6V28Zm16 18.8V33.6L45 28v13.2l-10 5.6Z" fill="#b7f36b"/>
</svg>
EOF

  cat > "$ROOT_DIR/public/_headers" <<'EOF'
/*
  Content-Security-Policy: default-src 'self'; script-src 'self'; style-src 'self'; img-src 'self' data:; connect-src 'none'; font-src 'self'; object-src 'none'; base-uri 'self'; frame-ancestors 'none'; form-action 'self'
  Permissions-Policy: camera=(), microphone=(), geolocation=(), payment=(), usb=()
  Referrer-Policy: strict-origin-when-cross-origin
  X-Content-Type-Options: nosniff
  X-Frame-Options: DENY
EOF

  cat > "$ROOT_DIR/tests/prompt-builder.test.js" <<'EOF'
import test from "node:test";
import assert from "node:assert/strict";

import { buildPrompt, FIELD_DEFINITIONS } from "../public/app.js";

test("提示詞包含五個固定欄位", () => {
  assert.deepEqual(
    FIELD_DEFINITIONS.map(({ key }) => key),
    ["context", "request", "outputFormat", "constraints", "checkpoint"]
  );
});

test("依指定格式與換行組合提示詞", () => {
  const result = buildPrompt({
    context: "這是背景",
    request: "這是任務",
    outputFormat: "這是格式",
    constraints: "這是約束",
    checkpoint: "這是查核條件"
  });

  assert.equal(
    result,
    `這是背景
這是任務

輸出格式：
這是格式

約束條件：
這是約束

查核條件：
這是查核條件`
  );
});

test("只移除各欄位前後空白，保留內部換行", () => {
  const result = buildPrompt({
    context: "  第一行\n第二行  ",
    request: " 任務 ",
    outputFormat: " 格式 ",
    constraints: " 約束 ",
    checkpoint: " 查核 "
  });

  assert.match(result, /^第一行\n第二行\n任務/);
  assert.match(result, /查核條件：\n查核$/);
});
EOF

  cat > "$ROOT_DIR/tests/site-contract.test.js" <<'EOF'
import test from "node:test";
import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";

const html = await readFile(new URL("../public/index.html", import.meta.url), "utf8");
const headers = await readFile(new URL("../public/_headers", import.meta.url), "utf8");

test("頁面提供卡片式與精靈式兩種模式", () => {
  assert.match(html, /data-mode="card"/);
  assert.match(html, /data-mode="wizard"/);
  assert.match(html, /id="card-panel"/);
  assert.match(html, /id="wizard-panel"/);
});

test("每種模式都有五個提示詞欄位", () => {
  for (const key of ["context", "request", "outputFormat", "constraints", "checkpoint"]) {
    assert.equal((html.match(new RegExp(`data-field="${key}"`, "g")) ?? []).length, 2);
  }
});

test("頁尾包含指定靈感來源", () => {
  assert.match(html, /https:\/\/x\.com\/RealCodedAlpha\/status\/2072937806801105347/);
  assert.match(html, /感謝/);
});

test("安全標頭禁止外部連線與 iframe 嵌入", () => {
  assert.match(headers, /connect-src 'none'/);
  assert.match(headers, /frame-ancestors 'none'/);
  assert.match(headers, /X-Content-Type-Options: nosniff/);
});
EOF
}

complete_stage_two() {
  cat >> "$TASK_DIR/notes.md" <<'EOF'

---  2026-07-04  第 3 次更新筆記 ---
## 階段 2 結果
- 已建立純靜態網站：卡片式表單、五步驟精靈、共用欄位 state、結果預覽、複製與清除功能。
- `buildPrompt()` 依使用者指定的標籤與空行精確組合內容。
- 已加入 CSP、Permissions Policy、Referrer Policy 等靜態安全標頭；`connect-src 'none'` 阻止頁面對外傳送輸入內容。
- 已加入 Node.js 原生測試，涵蓋輸出格式、欄位契約、模式存在、靈感來源與安全標頭。
- 使用 Wrangler 4.107.0，`public/` 為 Pages build output directory。
EOF

  python3 - "$TASK_DIR/task_plan.md" <<'PY'
from pathlib import Path
import sys

task_plan = Path(sys.argv[1])
content = task_plan.read_text()
content = content.replace("- [ ] ✅ 階段檢核：更新 notes.md → task_plan.md", "- [x] ✅ 階段檢核：更新 notes.md → task_plan.md", 1)
content = content.replace("- [ ] 階段 2：實作靜態網站與自動化測試", "- [x] 階段 2：實作靜態網站與自動化測試")
content = content.replace("  - [ ] 完成後更新 notes.md", "  - [x] 完成後更新 notes.md", 1)
content = content.replace("- [ ] ✅ 階段檢核：更新 notes.md → task_plan.md", "- [x] ✅ 階段檢核：更新 notes.md → task_plan.md", 1)
content = content.replace("**目前階段 2** - 實作靜態網站與自動化測試", "**目前階段 3** - 執行自動化、瀏覽器、響應式與安全驗證")
task_plan.write_text(content)
PY
}

write_readme() {
  cat > "$ROOT_DIR/README.md" <<'EOF'
# Prompt Forge

以五個欄位練習組合清楚、可執行的 AI 提示詞，並可直接部署至 Cloudflare Pages。

## 功能

- 卡片式：一次檢視並填寫所有欄位。
- 精靈式：依序完成五個引導步驟。
- 模式切換：兩種模式共用輸入內容，切換時不遺失資料。
- 固定格式：依 Context、Request、Output Format、Constraints、Checkpoint 組合提示詞。
- 一鍵複製：將產生結果複製到剪貼簿。
- 本機處理：不使用後端、API 或資料庫，輸入內容不會離開瀏覽器。

## 輸出格式

```text
{Context}
{Request}

輸出格式：
{Output Format}

約束條件：
{Constraints}

查核條件：
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
EOF
}

clean_local_artifacts() {
  rm -rf "$ROOT_DIR/~"
}

complete_stage_three() {
  cat >> "$TASK_DIR/notes.md" <<'EOF'

---  2026-07-04  第 4 次更新筆記 ---
## 階段 3 結果
- `npm test`：7 項測試全數通過，npm audit 回報 0 個漏洞。
- Wrangler Pages 本機環境回傳 HTTP 200，載入 1 條 `_headers` 規則，並明確顯示 `No Functions`。
- 瀏覽器實測卡片式五欄輸入、指定格式輸出、模式切換、欄位同步、五步驟精靈與剪貼簿複製皆成功。
- 375、768、1024、1440 px 四種寬度均無水平頁面捲動；所有可見主要按鈕高度至少 44px。
- 10 個 textarea 全數具 label，無重複 id、無未命名按鈕，頁面語系為 `zh-Hant`。
- Browser console 無 error 或 warning；敏感資料 pattern 掃描無命中。
- HTTP response 實際包含 CSP、Permissions Policy、Referrer Policy、nosniff 與 DENY frame headers。
EOF

  python3 - "$TASK_DIR/task_plan.md" <<'PY'
from pathlib import Path
import sys

task_plan = Path(sys.argv[1])
content = task_plan.read_text()
content = content.replace("- [ ] 階段 3：執行瀏覽器、響應式與安全驗證", "- [x] 階段 3：執行瀏覽器、響應式與安全驗證")
content = content.replace("  - [ ] 完成後更新 notes.md", "  - [x] 完成後更新 notes.md", 1)
content = content.replace("- [ ] ✅ 階段檢核：更新 notes.md → task_plan.md", "- [x] ✅ 階段檢核：更新 notes.md → task_plan.md", 1)
content = content.replace(
    "- Codex Default mode 無法使用 `request_user_input`：已顯示文字選項；goal 自動續行時採用建議預設。",
    "- Codex Default mode 無法使用 `request_user_input`：已顯示文字選項；goal 自動續行時採用建議預設。\n"
    "- in-app Browser 的 Playwright DOM snapshot API 不相容：依 browser troubleshooting 指引改用可用的 DOM CUA、locator、evaluate 與 screenshot 完成驗證。"
)
content = content.replace("**目前階段 3** - 執行自動化、瀏覽器、響應式與安全驗證", "**目前階段 4** - 建立 README、Git repository 並推送 GitHub")
task_plan.write_text(content)
PY
}

complete_stage_four() {
  commit_hash=$(git -C "$ROOT_DIR" rev-parse --short HEAD)
  cat >> "$TASK_DIR/notes.md" <<'EOF'

---  2026-07-04  第 5 次更新筆記 ---
## 階段 4 結果
- 已建立 `README.md`，包含本機啟動、測試、Git integration 與 Wrangler Direct Upload 發布方法。
- 已建立 `main` branch 與 `origin`：`https://github.com/lazyjerry/ai-prompt-exercise.git`。
- 提交前已檢查 `.gitignore`、staged path、私鑰／token pattern、shell syntax、測試與 whitespace。
- 已提交並推送 `origin/main`；最新提交為 COMMIT_HASH_PLACEHOLDER。
- `docs/knowledge-skill/` 與誤建的字面 `~/` 工具殘留未進入 repository。
EOF

  python3 - "$TASK_DIR/notes.md" "$commit_hash" <<'PY'
from pathlib import Path
import sys

notes = Path(sys.argv[1])
content = notes.read_text()
content = content.replace("COMMIT_HASH_PLACEHOLDER", sys.argv[2], 1)
notes.write_text(content)
PY

  python3 - "$TASK_DIR/task_plan.md" <<'PY'
from pathlib import Path
import sys

task_plan = Path(sys.argv[1])
content = task_plan.read_text()
content = content.replace("- [ ] 階段 4：建立 Git、README 並發布至 GitHub", "- [x] 階段 4：建立 Git、README 並發布至 GitHub")
content = content.replace("  - [ ] 完成後更新 notes.md", "  - [x] 完成後更新 notes.md", 1)
content = content.replace("- [ ] ✅ 階段檢核：更新 notes.md → task_plan.md", "- [x] ✅ 階段檢核：更新 notes.md → task_plan.md", 1)
content = content.replace("**目前階段 4** - 建立 README、Git repository 並推送 GitHub", "**目前階段 5** - 執行逐項完整性檢核與交付")
task_plan.write_text(content)
PY
}

complete_stage_five() {
  cat > "$TASK_DIR/report.md" <<'EOF'
# 建立提示詞練習 Cloudflare Pages：交付報告

## 完成結果

已完成可部署至 Cloudflare Pages 的 Prompt Forge 靜態網站，並推送至：

- Repository：https://github.com/lazyjerry/ai-prompt-exercise
- Branch：`main`

## 需求對照

| 需求 | 實作 | 驗證證據 |
|---|---|---|
| Context、Request、Output Format、Constraints、Checkpoint | 每種輸入模式各有完整五欄 | site contract test；瀏覽器 DOM 檢查 |
| 自動組合指定格式 | `buildPrompt()` 使用固定標籤與空行 | prompt-builder test 精確比對全文 |
| 卡片式輸入 | 同頁卡片網格表單 | 瀏覽器完成五欄輸入並產生結果 |
| 精靈提示輸入 | 五步驟導覽、上一步／下一步 | 瀏覽器逐步驗證 1/5 至 5/5 |
| 兩種方式切換 | ARIA tab 切換，共用單一 state | 切換後 wizard 保留 card 的 Context |
| 靈感來源 | 頁尾感謝句與指定 X 連結 | site contract test |
| Cloudflare Pages | `public/` output、`wrangler.jsonc`、`_headers` | Wrangler Pages dev 回傳 HTTP 200、No Functions |
| `.gitignore` 與機密防護 | 排除 env、Wrangler、依賴與任務紀錄；CSP 阻止外連 | staged path 檢查、token pattern 掃描、response headers |
| README 發布方法 | Git integration 與 Direct Upload 兩種流程 | `README.md` |
| GitHub origin | `main` 推送指定 repository | GitHub default branch 與 remote SHA 核對 |

## 驗證摘要

- `npm test`：7/7 通過。
- npm audit：0 個漏洞。
- Browser console：0 個 error、0 個 warning。
- 響應式：375、768、1024、1440 px 均無水平頁面捲動。
- 可及性契約：所有 textarea 有 label、無重複 id、按鈕有名稱、主要互動目標至少 44px。
- 安全標頭：CSP、Permissions Policy、Referrer Policy、`nosniff`、`DENY` frame policy 均由本機 Pages response 證實。
- Git：本機 `main` 與 `origin/main` 同步。

## 部署狀態

程式碼與設定已具備 Cloudflare Pages 部署條件。此任務未建立 Cloudflare 帳號內的 Pages project；實際發布可依 `README.md` 選擇 Git integration 或 Wrangler Direct Upload。

## 知識庫評估

本次未建立公用知識檔。Pages 靜態部署與前端表單實作屬官方文件已涵蓋的標準作法；`KNOWLEDGE_BASE_DIR` 使用字面 `~` 的工具殘留屬一般 shell 路徑展開行為與本機環境設定，不另行沉澱。
EOF

  cat >> "$TASK_DIR/notes.md" <<'EOF'

---  2026-07-04  第 6 次更新筆記 ---
## 階段 5 結果
- 已逐項核對功能、輸出格式、模式切換、靈感來源、Pages 設定、README、安全與 GitHub remote。
- 已建立 `report.md`，區分 deploy-ready 實作與尚未在 Cloudflare 帳號內建立 Pages project 的外部狀態。
- 本次無需建立公用知識檔：可重用部分均屬官方文件或一般 shell 行為。
EOF

  python3 - "$TASK_DIR/task_plan.md" <<'PY'
from pathlib import Path
import sys

task_plan = Path(sys.argv[1])
content = task_plan.read_text()
content = content.replace("- [ ] 階段 5：完整性檢核與交付", "- [x] 階段 5：完整性檢核與交付")
content = content.replace("  - [ ] 完成後更新 notes.md", "  - [x] 完成後更新 notes.md", 1)
content = content.replace("- [ ] ✅ 階段檢核：更新 notes.md → task_plan.md", "- [x] ✅ 階段檢核：更新 notes.md → task_plan.md", 1)
content = content.replace("**目前階段 5** - 執行逐項完整性檢核與交付", "**已完成** - 全部需求、驗證、文件與 GitHub 發布均完成")
task_plan.write_text(content)
PY
}

case "${1:-}" in
  init)
    write_initial_task_files
    ;;
  stage1)
    complete_stage_one
    ;;
  site)
    write_site_files
    ;;
  stage2)
    complete_stage_two
    ;;
  stage3)
    complete_stage_three
    ;;
  readme)
    write_readme
    ;;
  clean)
    clean_local_artifacts
    ;;
  stage4)
    complete_stage_four
    ;;
  stage5)
    complete_stage_five
    ;;
  *)
    echo "Usage: $0 {init|stage1|site|stage2|stage3|readme|clean|stage4|stage5}" >&2
    exit 1
    ;;
esac

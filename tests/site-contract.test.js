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

test("第一屏開始按鈕導向工作區", () => {
  assert.match(html, /class="start-button" href="#composer"/);
  assert.match(html, />\s*開始練習\s*</);
});

test("精靈式是預設模式並提供三個範例", () => {
  assert.match(html, /id="wizard-tab"[^>]*aria-selected="true"/);
  assert.match(html, /id="card-tab"[^>]*aria-selected="false"/);
  assert.match(html, /id="card-panel"[^>]*hidden/);
  assert.doesNotMatch(html, /id="wizard-panel"[^>]*hidden/);
  assert.equal((html.match(/data-example="/g) ?? []).length, 3);
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

test("04 長文包含任務邊界、checkpoint、注意事項與小字引用", () => {
  assert.match(html, /模型越能自主執行/);
  assert.match(html, /任務邊界決定 Agent 可以自主到哪裡/);
  assert.match(html, /Checkpoint 是停車線/);
  assert.match(html, /涉及不可逆或高風險操作/);
  assert.match(html, /任務範圍發生實質變化/);
  assert.match(html, /缺少只有使用者能提供的關鍵資訊/);
  assert.match(html, /class="source-citation"/);
  assert.match(html, /anthropic\.com\/engineering\/building-effective-agents/);
  assert.match(html, /openai\.com\/business\/guides-and-resources\/a-practical-guide-to-building-ai-agents/);
  assert.match(html, /airc\.nist\.gov\/airmf-resources\/airmf\/5-sec-core/);
});

test("安全標頭禁止外部連線與 iframe 嵌入", () => {
  assert.match(headers, /connect-src 'none'/);
  assert.match(headers, /frame-ancestors 'none'/);
  assert.match(headers, /X-Content-Type-Options: nosniff/);
});

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

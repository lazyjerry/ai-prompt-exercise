import test from "node:test";
import assert from "node:assert/strict";

import { buildPrompt, FIELD_DEFINITIONS, PROMPT_EXAMPLES } from "../public/app.js";

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
    checkpoint: "這是停下確認條件"
  });

  assert.equal(
    result,
    `這是背景
這是任務

交付格式：
這是格式

限制條件：
這是約束

停下確認條件：
這是停下確認條件`
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
  assert.match(result, /停下確認條件：\n查核$/);
});

test("三個範例都提供完整五欄內容", () => {
  assert.equal(Object.keys(PROMPT_EXAMPLES).length, 3);
  for (const example of Object.values(PROMPT_EXAMPLES)) {
    for (const { key } of FIELD_DEFINITIONS) {
      assert.ok(example[key].trim(), `${key} 不可為空`);
    }
  }
});

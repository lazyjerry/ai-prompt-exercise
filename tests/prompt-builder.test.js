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

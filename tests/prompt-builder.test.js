import test from "node:test";
import assert from "node:assert/strict";

import {
  buildPrompt,
  clearStoredValues,
  FIELD_DEFINITIONS,
  loadStoredValues,
  PROMPT_EXAMPLES,
  saveStoredValues,
  STORAGE_KEY
} from "../public/app.js";

function createMemoryStorage(initial = {}) {
  const store = { ...initial };
  return {
    getItem(key) {
      return Object.hasOwn(store, key) ? store[key] : null;
    },
    setItem(key, value) {
      store[key] = value;
    },
    removeItem(key) {
      delete store[key];
    },
    store
  };
}

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

test("可儲存並讀取 localStorage 中的五欄內容", () => {
  const storage = createMemoryStorage();
  saveStoredValues({ context: "背景", request: "任務", outputFormat: "格式" }, storage);

  assert.deepEqual(loadStoredValues(storage), {
    context: "背景",
    request: "任務",
    outputFormat: "格式",
    constraints: "",
    checkpoint: ""
  });
});

test("可清除 localStorage 中的暫存提示詞", () => {
  const storage = createMemoryStorage({ [STORAGE_KEY]: JSON.stringify({ context: "背景" }) });
  clearStoredValues(storage);

  assert.equal(storage.getItem(STORAGE_KEY), null);
});

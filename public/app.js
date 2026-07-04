export const FIELD_DEFINITIONS = [
  { key: "context", label: "Context" },
  { key: "request", label: "Request" },
  { key: "outputFormat", label: "交付格式" },
  { key: "constraints", label: "限制條件" },
  { key: "checkpoint", label: "停下確認條件" }
];

export const STORAGE_KEY = "prompt-forge:values:v1";

export const PROMPT_EXAMPLES = {
  research: {
    context: "我要為產品團隊整理近 12 個月的 AI Agent 安全實務，讀者具備基本技術背景，但沒有專職 AI 治理經驗。",
    request: "比較 Anthropic、OpenAI 與 NIST 對 human-in-the-loop、任務邊界與風險控制的主要建議。",
    outputFormat: "使用繁體中文 Markdown。先提供 150 字摘要，再以表格比較來源、核心觀點、適用情境與限制，最後列出可執行的檢查清單；每個主張附原始來源連結。",
    constraints: "只使用官方或第一方資料；不要把推論寫成已證實事實；不要引用超過 12 個月前的產品規格，除非標示日期。",
    checkpoint: "若官方來源互相衝突、找不到足以支持核心主張的資料，或需要擴大到付費資料庫，先停下來詢問我；其餘情況繼續完成並回報查證結果。"
  },
  development: {
    context: "我正在維護一個已上線的純前端 Cloudflare Pages 專案，現有測試與視覺風格必須保留。",
    request: "新增一個可套用範例的提示詞精靈，讓使用者能載入完整五欄內容後再逐步修改。",
    outputFormat: "提交最小範圍的 HTML、CSS、JavaScript 與測試修改；附上測試結果、瀏覽器驗證項目、Git diff 摘要與部署結果。",
    constraints: "不要新增框架或第三方 runtime dependency；不要重構無關程式碼；維持鍵盤操作、手機版與既有 Content Security Policy。",
    checkpoint: "只有在需要不可逆操作、修改需求範圍、取得缺少的憑證或現有測試無法判定預期行為時停下來詢問；其他問題先從 repo 與工具查證。"
  },
  content: {
    context: "我要為第一次使用 AI Agent 的台灣中小企業團隊撰寫一篇教學文章，讀者熟悉一般生成式 AI，但不懂 checkpoint 與任務邊界。",
    request: "撰寫一篇說明 Context、Request、Output Format、Constraints 與 Checkpoint 的實務教學。",
    outputFormat: "使用繁體中文與台灣用語，篇幅 1,200 至 1,500 字；包含開場、五部分解說、三個 checkpoint、錯誤示範、完成前檢查表與引用連結。",
    constraints: "語氣務實，不使用宣傳式形容詞；不要聲稱單一 prompt 能消除所有風險；未證實的來源必須明確標示。",
    checkpoint: "若目標受眾、發布平台或品牌語氣需要改變，先停下來詢問我；其餘編排與措辭可自行完成，最後列出仍需人工確認的事實。"
  }
};

export function buildPrompt(values) {
  const clean = Object.fromEntries(
    FIELD_DEFINITIONS.map(({ key }) => [key, String(values[key] ?? "").trim()])
  );

  return `${clean.context}
${clean.request}

交付格式：
${clean.outputFormat}

限制條件：
${clean.constraints}

停下確認條件：
${clean.checkpoint}`;
}

export function normalizeStoredValues(values = {}) {
  return Object.fromEntries(
    FIELD_DEFINITIONS.map(({ key }) => [key, String(values[key] ?? "")])
  );
}

export function loadStoredValues(storage = globalThis.localStorage) {
  try {
    const raw = storage?.getItem(STORAGE_KEY);
    if (!raw) return normalizeStoredValues();

    const parsed = JSON.parse(raw);
    if (!parsed || typeof parsed !== "object" || Array.isArray(parsed)) {
      return normalizeStoredValues();
    }

    return normalizeStoredValues(parsed);
  } catch {
    return normalizeStoredValues();
  }
}

export function saveStoredValues(values, storage = globalThis.localStorage) {
  try {
    storage?.setItem(STORAGE_KEY, JSON.stringify(normalizeStoredValues(values)));
  } catch {
    // localStorage may be unavailable in private browsing or strict privacy modes.
  }
}

export function clearStoredValues(storage = globalThis.localStorage) {
  try {
    storage?.removeItem(STORAGE_KEY);
  } catch {
    // localStorage may be unavailable in private browsing or strict privacy modes.
  }
}

function initializeApp() {
  const state = loadStoredValues();
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
  const examplePicker = document.querySelector("#example-picker");
  const exampleButtons = [...document.querySelectorAll("[data-example]")];
  let currentStep = 0;
  let activeMode = "wizard";

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
    saveStoredValues(state);
    exampleButtons.forEach((button) => button.setAttribute("aria-pressed", "false"));
    if (source.value.trim()) clearFieldError(key);
  }

  function setMode(mode, focusPanel = true) {
    activeMode = mode;
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

  function applyExample(exampleKey) {
    const example = PROMPT_EXAMPLES[exampleKey];
    if (!example) return;

    FIELD_DEFINITIONS.forEach(({ key }) => {
      state[key] = example[key];
      getInputsForField(key).forEach((input) => {
        input.value = example[key];
      });
      clearFieldError(key);
    });
    saveStoredValues(state);

    exampleButtons.forEach((button) => {
      button.setAttribute("aria-pressed", String(button.dataset.example === exampleKey));
    });
    currentStep = 0;
    updateWizard();
    setMode("wizard", false);
    examplePicker.open = false;
    appStatus.textContent = "範例已載入，可逐步修改。";
    document.querySelector("#wizard-context").focus();
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
    clearStoredValues();
    currentStep = 0;
    updateWizard();
    promptCode.textContent = "";
    promptOutput.hidden = true;
    outputPlaceholder.hidden = false;
    copyButton.disabled = true;
    outputState.classList.remove("is-ready");
    outputState.innerHTML = "<span></span>等待輸入";
    exampleButtons.forEach((button) => button.setAttribute("aria-pressed", "false"));
    appStatus.textContent = "內容已清除。";
    panels[activeMode].querySelector("textarea:not([hidden])")?.focus();
  }

  inputs.forEach((input) => {
    input.addEventListener("input", () => syncField(input));
  });

  FIELD_DEFINITIONS.forEach(({ key }) => {
    getInputsForField(key).forEach((input) => {
      input.value = state[key];
    });
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

  exampleButtons.forEach((button) => {
    button.addEventListener("click", () => applyExample(button.dataset.example));
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
  setMode("wizard", false);
  updateWizard();
}

if (typeof document !== "undefined") {
  initializeApp();
}

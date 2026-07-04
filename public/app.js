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

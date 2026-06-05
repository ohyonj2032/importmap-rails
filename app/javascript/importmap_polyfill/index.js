const ImportmapPolyfill = (() => {
  const isNativeImportmapSupported = (() => {
    try {
      const testScript = document.createElement("script");
      testScript.type = "importmap";
      return testScript.type === "importmap";
    } catch {
      return false;
    }
  })();

  const isDynamicImportmapSupported = (() => {
    if (!isNativeImportmapSupported) return false;
    const ua = navigator.userAgent;
    const safariMatch = ua.match(/Version\/(\d+)\./);
    if (safariMatch && parseInt(safariMatch[1], 10) < 16.4) {
      return false;
    }
    return true;
  })();

  const moduleShimLoaded = (() => {
    return typeof window.ShimImportmap !== "undefined";
  })();

  const polyfillModules = new Map();

  async function loadESModuleShim() {
    if (moduleShimLoaded) return;
    return new Promise((resolve, reject) => {
      const script = document.createElement("script");
      script.type = "module";
      script.src = "https://ga.jspm.io/npm:es-module-shims@1.10.0/dist/es-module-shims.js";
      script.async = true;
      script.onload = resolve;
      script.onerror = () => reject(new Error("Failed to load ES Module Shims polyfill"));
      document.head.appendChild(script);
    });
  }

  async function ensurePolyfill() {
    if (isDynamicImportmapSupported) return;
    await loadESModuleShim();
  }

  async function injectWithPolyfill(modules) {
    if (isDynamicImportmapSupported) {
      const DynamicImportmap = (await import("../dynamic_importmap/index.js")).default;
      return DynamicImportmap.inject(modules);
    }

    await ensurePolyfill();

    for (const [name, config] of Object.entries(modules)) {
      polyfillModules.set(name, config);
    }

    const importMap = {
      imports: {},
    };

    for (const [name, config] of polyfillModules.entries()) {
      importMap.imports[name] = config.url;
    }

    if (window.importShim) {
      window.importShim.addImportMap(importMap);
    } else {
      const existingScript = document.querySelector('script[type="importmap-shim"]');
      if (existingScript) existingScript.remove();

      const script = document.createElement("script");
      script.type = "importmap-shim";
      script.textContent = JSON.stringify(importMap);
      document.head.appendChild(script);
    }
  }

  return {
    isNativeImportmapSupported,
    isDynamicImportmapSupported,
    injectWithPolyfill,
    ensurePolyfill,
  };
})();

export default ImportmapPolyfill;

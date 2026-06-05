const DynamicImportmap = (() => {
  const injectedModules = new Set();
  let pendingInjection = null;

  function getExistingMap() {
    const existingScript = document.querySelector('script[type="importmap"]');
    if (!existingScript) return { imports: {}, integrity: {} };
    try {
      return JSON.parse(existingScript.textContent);
    } catch {
      return { imports: {}, integrity: {} };
    }
  }

  function mergeImportmaps(existing, incoming) {
    const merged = {
      imports: { ...existing.imports, ...incoming.imports },
    };
    if (existing.integrity || incoming.integrity) {
      merged.integrity = {
        ...(existing.integrity || {}),
        ...(incoming.integrity || {}),
      };
    }
    return merged;
  }

  function injectImportmapScript(mapJson) {
    const script = document.createElement("script");
    script.type = "importmap";
    script.textContent = JSON.stringify(mapJson, null, 0);
    document.head.appendChild(script);
  }

  async function inject(modules) {
    if (pendingInjection) {
      await pendingInjection;
    }

    const newModules = {};
    const newIntegrity = {};
    const modulesToFetch = [];

    for (const [name, config] of Object.entries(modules)) {
      if (injectedModules.has(name)) continue;
      injectedModules.add(name);
      newModules[name] = config.url;
      if (config.integrity) {
        newIntegrity[config.url] = config.integrity;
      }
      modulesToFetch.push(name);
    }

    if (modulesToFetch.length === 0) return;

    const incoming = { imports: newModules };
    if (Object.keys(newIntegrity).length > 0) {
      incoming.integrity = newIntegrity;
    }

    const existing = getExistingMap();
    const merged = mergeImportmaps(existing, incoming);

    const removeOld = document.querySelector('script[type="importmap"]');
    if (removeOld) removeOld.remove();

    injectImportmapScript(merged);

    await preloadModules(newModules, newIntegrity);
  }

  function preloadModules(modules, integrity) {
    const links = [];
    for (const [name, url] of Object.entries(modules)) {
      const link = document.createElement("link");
      link.rel = "modulepreload";
      link.href = url;
      if (integrity[url]) {
        link.integrity = integrity[url];
      }
      document.head.appendChild(link);
      links.push(
        new Promise((resolve) => {
          link.onload = resolve;
          link.onerror = resolve;
        })
      );
    }
    return Promise.all(links);
  }

  function lazyImport(moduleName, config) {
    return async () => {
      await inject({ [moduleName]: config });
      const module = await import(moduleName);
      return module;
    };
  }

  function isModuleInjected(name) {
    return injectedModules.has(name);
  }

  function reset() {
    injectedModules.clear();
  }

  return { inject, lazyImport, isModuleInjected, reset };
})();

export default DynamicImportmap;

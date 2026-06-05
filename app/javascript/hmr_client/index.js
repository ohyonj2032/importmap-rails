const HmrClient = (() => {
  const HMR_PORT = parseInt(document.querySelector('meta[name="hmr-port"]')?.content || "3099", 10);
  const HMR_ENABLED = document.querySelector('meta[name="hmr-enabled"]')?.content === "true";

  let eventSource = null;
  let reconnectAttempts = 0;
  const MAX_RECONNECT_ATTEMPTS = 10;
  const BASE_RECONNECT_DELAY = 1000;
  const moduleVersionMap = new Map();

  function connect() {
    if (!HMR_ENABLED) return;

    const url = `http://localhost:${HMR_PORT}`;
    eventSource = new EventSource(url);

    eventSource.onopen = () => {
      reconnectAttempts = 0;
      console.log("[HMR] Connected to esbuild HMR server");
    };

    eventSource.onmessage = (event) => {
      try {
        const data = JSON.parse(event.data);
        handleMessage(data);
      } catch (e) {
        console.error("[HMR] Failed to parse message:", e);
      }
    };

    eventSource.onerror = () => {
      eventSource.close();
      if (reconnectAttempts < MAX_RECONNECT_ATTEMPTS) {
        const delay = BASE_RECONNECT_DELAY * Math.pow(2, reconnectAttempts);
        reconnectAttempts++;
        console.log(`[HMR] Reconnecting in ${delay}ms (attempt ${reconnectAttempts})`);
        setTimeout(connect, delay);
      } else {
        console.warn("[HMR] Max reconnection attempts reached. Falling back to full page reload.");
      }
    };
  }

  function handleMessage(data) {
    switch (data.type) {
      case "connected":
        console.log(`[HMR] Connected, build version: ${data.version}`);
        break;
      case "update":
        handleUpdate(data);
        break;
    }
  }

  async function handleUpdate(data) {
    const changedFiles = data.files || [];
    const version = data.version;

    console.log(`[HMR] Build ${version} changed:`, changedFiles);

    for (const file of changedFiles) {
      moduleVersionMap.set(file, version);
    }

    const importmap = Rails?.application?.importmap;
    if (importmap) {
      importmap.cache_sweeper?.execute_if_updated?.();
    }

    await reloadModules(changedFiles, version);
  }

  async function reloadModules(files, version) {
    const cacheBust = `?v=${version}_${Date.now()}`;

    const modulesToReload = files.filter((file) => {
      return file.endsWith(".js");
    });

    if (modulesToReload.length === 0) {
      fullReload();
      return;
    }

    try {
      for (const moduleFile of modulesToReload) {
        const moduleName = moduleFile.replace(/\.js$/, "");
        try {
          const url = resolveModuleUrl(moduleName);
          if (url) {
            await import(url + cacheBust);
          }
        } catch (e) {
          console.warn(`[HMR] Failed to hot-reload ${moduleFile}:`, e.message);
        }
      }

      console.log(`[HMR] Modules reloaded successfully (v${version})`);
    } catch (e) {
      console.warn("[HMR] Hot reload failed, falling back to full page reload:", e);
      fullReload();
    }
  }

  function resolveModuleUrl(moduleName) {
    const scripts = document.querySelectorAll('script[type="importmap"]');
    for (const script of scripts) {
      try {
        const map = JSON.parse(script.textContent);
        if (map.imports && map.imports[moduleName]) {
          return map.imports[moduleName];
        }
      } catch {}
    }
    return null;
  }

  function fullReload() {
    window.location.reload();
  }

  function disconnect() {
    if (eventSource) {
      eventSource.close();
      eventSource = null;
    }
  }

  if (HMR_ENABLED && typeof EventSource !== "undefined") {
    if (document.readyState === "loading") {
      document.addEventListener("DOMContentLoaded", connect);
    } else {
      connect();
    }
  }

  return { connect, disconnect, fullReload };
})();

export default HmrClient;

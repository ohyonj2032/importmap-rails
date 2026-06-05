// Safari 15 SRI fallback: When es-module-shims fails to load a module due to SRI
// cache collision (TypeError: Load failed with no stack), this interceptor retries
// the fetch with cache: "reload" to bypass the poisoned preload cache.
//
// Root cause: Safari 15 natively preloads <link rel="modulepreload"> without SRI,
// then es-module-shims tries to validate the cached response against the importmap's
// SRI hash, causing a silent failure.

(function() {
  const isSafari15 = /^((?!chrome|android).)*safari/i.test(navigator.userAgent) &&
    /Version\/15\.\d+/.test(navigator.userAgent);

  if (!isSafari15) return;

  const originalImport = window.importShim || window.import;

  async function safari15SafeImport(modulePath, maxRetries = 2) {
    for (let attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        const fetchOptions = attempt > 0 ? { cache: "reload" } : {};
        return await (window.importShim || window.import)(modulePath, fetchOptions);
      } catch (error) {
        const isSriFailure = error instanceof TypeError &&
          error.message === "Load failed" &&
          !error.stack;

        if (!isSriFailure || attempt === maxRetries) {
          throw error;
        }

        console.warn(
          `[Safari 15 SRI Workaround] Retry ${attempt + 1}/${maxRetries} for ${modulePath} with cache:reload`
        );
      }
    }
  }

  // Patch React.lazy and other dynamic import wrappers
  const originalLazy = window.React?.lazy;
  if (originalLazy) {
    window.React.lazy = function(factory) {
      return originalLazy(async () => {
        const result = await factory();
        return result;
      });
    };
  }

  // Expose safe import helper for application code
  window.safari15SafeImport = safari15SafeImport;
})();

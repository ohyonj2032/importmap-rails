const DynamicSri = (() => {
  const SUPPORTED_ALGORITHMS = ["sha256", "sha384", "sha512"];
  const verifiedUrls = new Map();

  async function computeHash(algorithm, data) {
    const algoName = algorithm.toUpperCase();
    const buffer = typeof data === "string" ? new TextEncoder().encode(data) : data;
    const hashBuffer = await crypto.subtle.digest(algoName, buffer);
    const hashArray = Array.from(new Uint8Array(hashBuffer));
    const hashBase64 = btoa(String.fromCharCode(...hashArray));
    return `${algorithm}-${hashBase64}`;
  }

  async function verifyResponse(response, integrity) {
    if (!integrity) return true;

    const parsed = parseIntegrity(integrity);
    if (!parsed) {
      console.warn(`[DynamicSri] Invalid integrity format: ${integrity}`);
      return false;
    }

    const [algorithm, expectedDigest] = parsed;

    const cloned = response.clone();
    const buffer = await cloned.arrayBuffer();

    const computed = await computeHash(algorithm, buffer);
    const computedDigest = computed.split("-")[1];

    if (computedDigest !== expectedDigest) {
      console.error(
        `[DynamicSri] Integrity check FAILED for ${response.url}\n` +
        `  Expected: ${integrity}\n` +
        `  Computed: ${computed}`
      );
      return false;
    }

    verifiedUrls.set(response.url, { integrity, verified: true, timestamp: Date.now() });
    return true;
  }

  function parseIntegrity(integrity) {
    const match = integrity.match(/^(sha\d+)-([A-Za-z0-9+/=]+)$/);
    if (!match) return null;

    const algorithm = match[1];
    if (!SUPPORTED_ALGORITHMS.includes(algorithm)) return null;

    return [algorithm, match[2]];
  }

  async function fetchWithSri(url, integrity, options = {}) {
    const response = await fetch(url, {
      ...options,
      integrity: integrity || undefined,
    });

    if (!response.ok) {
      throw new Error(`[DynamicSri] Fetch failed: ${response.status} ${response.statusText} for ${url}`);
    }

    if (integrity && !isNativeSriSupported()) {
      const valid = await verifyResponse(response, integrity);
      if (!valid) {
        throw new Error(`[DynamicSri] Integrity verification failed for ${url}`);
      }
    }

    return response;
  }

  function isNativeSriSupported() {
    return typeof Response !== "undefined" && "integrity" in Response.prototype;
  }

  function isVerified(url) {
    return verifiedUrls.get(url)?.verified === true;
  }

  function createIntegrityPolicy(modules) {
    const policy = {};
    for (const [name, config] of Object.entries(modules)) {
      if (config.integrity) {
        policy[config.url] = config.integrity;
      }
    }
    return policy;
  }

  function installFetchInterceptor(modules) {
    const policy = createIntegrityPolicy(modules);
    if (Object.keys(policy).length === 0) return;

    const originalFetch = window.fetch;
    window.fetch = async function (input, init = {}) {
      const url = typeof input === "string" ? input : input.url;

      if (policy[url] && !init.integrity) {
        init.integrity = policy[url];
      }

      return originalFetch.call(this, input, init);
    };

    return () => {
      window.fetch = originalFetch;
    };
  }

  return {
    computeHash,
    verifyResponse,
    fetchWithSri,
    isVerified,
    parseIntegrity,
    createIntegrityPolicy,
    installFetchInterceptor,
    isNativeSriSupported,
  };
})();

export default DynamicSri;

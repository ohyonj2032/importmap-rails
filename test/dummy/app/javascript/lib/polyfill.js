const IMPORTMAP_SUPPORTED = HTMLScriptElement.supports
  ? HTMLScriptElement.supports("importmap")
  : false

function loadPolyfill() {
  if (IMPORTMAP_SUPPORTED) return Promise.resolve()

  const script = document.createElement("script")
  script.src = "https://ga.jspm.io/npm:es-module-shims@1.10.1/dist/es-module-shims.js"
  script.async = true

  return new Promise((resolve, reject) => {
    script.onload = resolve
    script.onerror = reject
    document.head.appendChild(script)
  })
}

function configureShim() {
  if (IMPORTMAP_SUPPORTED) return

  window.esmsInitOptions = {
    shimMode: true,
    polyfillEnable: ["css-modules", "json-modules"],
    onerror: (error) => {
      console.error("[ImportMap Shim] Module load error:", error)
      document.dispatchEvent(new CustomEvent("importmap:error", {
        detail: { error },
        bubbles: true
      }))
    },
    onpolyfill: () => {
      console.warn("[ImportMap Shim] Running in polyfill mode")
      document.documentElement.dataset.importmapPolyfill = "active"
    }
  }
}

function init() {
  configureShim()

  if (!IMPORTMAP_SUPPORTED) {
    return loadPolyfill().then(() => {
      document.documentElement.dataset.importmapSupport = "polyfill"
    })
  }

  document.documentElement.dataset.importmapSupport = "native"
  return Promise.resolve()
}

const ready = init()

export { IMPORTMAP_SUPPORTED, ready }

export default { IMPORTMAP_SUPPORTED, ready }

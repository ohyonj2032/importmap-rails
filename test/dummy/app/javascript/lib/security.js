const AUTO_NONCE_SELECTOR = "script[data-auto-nonce]:not([nonce]), style:not([nonce])"

function currentCspNonce() {
  return document.querySelector('meta[name="csp-nonce"]')?.content || document.querySelector("script[nonce]")?.nonce || ""
}

function applyCspNonce(element, nonce = currentCspNonce()) {
  if (!element || !nonce || !element.matches) {
    return element
  }

  const eligible = element.matches("style:not([nonce]), script[data-auto-nonce]:not([nonce])")

  if (!eligible) {
    return element
  }

  element.setAttribute("nonce", nonce)
  element.nonce = nonce
  return element
}

function observeDynamicElements(root = document.documentElement) {
  const nonce = currentCspNonce()

  if (!root || !nonce || !("MutationObserver" in window)) {
    return null
  }

  root.querySelectorAll?.(AUTO_NONCE_SELECTOR).forEach((element) => applyCspNonce(element, nonce))

  const observer = new MutationObserver((mutations) => {
    mutations.forEach(({ addedNodes }) => {
      addedNodes.forEach((node) => {
        if (!(node instanceof Element)) {
          return
        }

        if (node.matches(AUTO_NONCE_SELECTOR)) {
          applyCspNonce(node, nonce)
        }

        node.querySelectorAll?.(AUTO_NONCE_SELECTOR).forEach((element) => applyCspNonce(element, nonce))
      })
    })
  })

  observer.observe(root, { childList: true, subtree: true })
  return observer
}

function supportsImportMaps() {
  return typeof HTMLScriptElement !== "undefined" && typeof HTMLScriptElement.supports === "function" && HTMLScriptElement.supports("importmap")
}

export { applyCspNonce, currentCspNonce, observeDynamicElements, supportsImportMaps }

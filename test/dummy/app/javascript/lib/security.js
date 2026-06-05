function nonceMeta() {
  return document.head.querySelector("meta[name='csp-nonce']")
}

export function currentCspNonce() {
  return nonceMeta()?.content || ""
}

export function applyNonce(element) {
  if (!(element instanceof Element)) {
    return element
  }

  if (!element.matches("script, style")) {
    return element
  }

  const nonce = currentCspNonce()

  if (nonce && !element.nonce) {
    element.nonce = nonce
  }

  return element
}

export function observeDynamicElements() {
  if (!("MutationObserver" in window)) {
    return null
  }

  const observer = new MutationObserver((mutations) => {
    mutations.forEach(({ addedNodes }) => {
      addedNodes.forEach((node) => {
        if (!(node instanceof Element)) {
          return
        }

        applyNonce(node)
        node.querySelectorAll("script, style").forEach((child) => applyNonce(child))
      })
    })
  })

  observer.observe(document.documentElement, { childList: true, subtree: true })
  return observer
}

export function supportsImportMaps() {
  return HTMLScriptElement.supports?.("importmap") || false
}

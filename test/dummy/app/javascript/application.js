import "@hotwired/turbo-rails"
import dayjs from "dayjs"
import { application } from "controllers/application"
import { loadControllers } from "controllers"
import consumer, { ensureNotificationsSubscription } from "channels"
import { currentCspNonce, observeDynamicElements, supportsImportMaps } from "lib/security"

loadControllers(application)
observeDynamicElements()

const cableEnabled = "WebSocket" in window
const bootTimestamp = dayjs().toISOString()

document.documentElement.dataset.importmapLoadedAt = bootTimestamp
document.documentElement.dataset.importmapSupport = supportsImportMaps() ? "native" : "shim"

if (cableEnabled) {
  ensureNotificationsSubscription()
} else {
  document.documentElement.dataset.cableState = "unsupported"
}

document.addEventListener("turbo:load", () => {
  window.dispatchEvent(
    new CustomEvent("importmap:ready", {
      detail: {
        bootTimestamp,
        cableEnabled,
        cableState: document.documentElement.dataset.cableState || "connecting",
        nonce: currentCspNonce()
      }
    })
  )
})

window.Stimulus = application
window.ActionCable = consumer

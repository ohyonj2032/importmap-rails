import "@hotwired/turbo-rails"
import dayjs from "dayjs"
import md5 from "md5"
import { application } from "controllers/application"
import { loadControllers } from "controllers"
import consumer, { ensureNotificationsSubscription } from "channels"
import { currentCspNonce, observeDynamicElements, supportsImportMaps } from "lib/security"

const bootTimestamp = dayjs().toISOString()
const bootDigest = md5([bootTimestamp, document.baseURI, currentCspNonce()].filter(Boolean).join(":"))
const cableEnabled = "WebSocket" in window

loadControllers(application)
observeDynamicElements()

document.documentElement.dataset.importmapLoadedAt = bootTimestamp
document.documentElement.dataset.importmapBootDigest = bootDigest
document.documentElement.dataset.importmapSupport = supportsImportMaps() ? "native" : "shim"

if (cableEnabled) {
  ensureNotificationsSubscription()
} else {
  document.documentElement.dataset.cableState = "unsupported"
}

document.addEventListener("turbo:load", () => {
  document.documentElement.dataset.lastTurboLoadAt = dayjs().toISOString()

  window.dispatchEvent(
    new CustomEvent("importmap:ready", {
      detail: {
        bootDigest,
        bootTimestamp,
        cableEnabled,
        cableState: document.documentElement.dataset.cableState || "connecting",
        importmapSupport: document.documentElement.dataset.importmapSupport,
        noncePresent: Boolean(currentCspNonce())
      }
    })
  )
})

window.Stimulus = application
window.ActionCable = consumer

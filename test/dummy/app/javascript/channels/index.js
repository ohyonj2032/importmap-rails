import consumer from "channels/consumer"

let notificationsSubscription

function dispatch(name, detail = {}) {
  document.dispatchEvent(new CustomEvent(name, { detail }))
}

export function ensureNotificationsSubscription() {
  if (notificationsSubscription) {
    return notificationsSubscription
  }

  notificationsSubscription = consumer.subscriptions.create("ImportmapNotificationsChannel", {
    initialized() {
      document.documentElement.dataset.cableState = "initializing"
    },

    connected() {
      document.documentElement.dataset.cableState = "connected"
      dispatch("importmap:cable:connected", { connectedAt: new Date().toISOString() })
    },

    disconnected() {
      document.documentElement.dataset.cableState = "disconnected"
      dispatch("importmap:cable:disconnected", { disconnectedAt: new Date().toISOString() })
    },

    rejected() {
      document.documentElement.dataset.cableState = "rejected"
      dispatch("importmap:cable:rejected")
    },

    received(payload) {
      dispatch("importmap:notifications:received", payload)
    }
  })

  return notificationsSubscription
}

export default consumer

function dispatchNotification(detail = {}) {
  const payload = {
    type: "message",
    message: "Notification received",
    timestamp: new Date().toISOString(),
    ...detail
  }

  document.documentElement.dataset.cableState = payload.type
  document.dispatchEvent(new CustomEvent("importmap:notifications:received", { detail: payload }))
  return payload
}

export function createNotificationsSubscription(consumer) {
  if (!consumer || !consumer.subscriptions) {
    return null
  }

  return consumer.subscriptions.create(
    { channel: "NotificationsChannel" },
    {
      initialized() {
        document.documentElement.dataset.cableState = "initializing"
      },
      connected() {
        dispatchNotification({ type: "connected", message: "Action Cable connected" })
      },
      disconnected() {
        dispatchNotification({ type: "disconnected", message: "Action Cable disconnected" })
      },
      rejected() {
        dispatchNotification({ type: "rejected", message: "Action Cable subscription rejected" })
      },
      received(data) {
        dispatchNotification(data)
      },
      ping(message) {
        this.perform("ping", { message })
      }
    }
  )
}

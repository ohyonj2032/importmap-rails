import consumer from "channels/consumer"
import { createNotificationsSubscription } from "channels/notifications_channel"

let notificationsSubscription
let pingForwarderInstalled = false

function installPingForwarder() {
  if (pingForwarderInstalled) {
    return
  }

  document.addEventListener("importmap:notifications:ping", (event) => {
    const message = event.detail?.message || "Browser ping"
    notificationsSubscription?.ping(message)
  })

  pingForwarderInstalled = true
}

function ensureNotificationsSubscription() {
  if (notificationsSubscription) {
    return notificationsSubscription
  }

  notificationsSubscription = createNotificationsSubscription(consumer)
  installPingForwarder()
  return notificationsSubscription
}

export { consumer, ensureNotificationsSubscription }
export default consumer

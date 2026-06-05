import { cableManager } from "lib/cable"

const channels = {}

channels.appearance = cableManager.subscribe("AppearanceChannel", {
  received(data) {
    document.querySelectorAll(`[data-user-id="${data.user_id}"]`).forEach(element => {
      element.dataset.status = data.status
    })
  }
})

channels.notifications = cableManager.subscribe("NotificationsChannel", {
  received(data) {
    const event = new CustomEvent("cable:notification", {
      detail: data,
      bubbles: true
    })
    document.dispatchEvent(event)
  }
})

window.App = window.App || {}
window.App.cable = cableManager
window.App.channels = channels

export { channels }

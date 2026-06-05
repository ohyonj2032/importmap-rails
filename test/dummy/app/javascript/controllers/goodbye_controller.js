import { Controller } from "@hotwired/stimulus"
import dayjs from "dayjs"

export default class extends Controller {
  static targets = ["message", "status"]

  connect() {
    this.notificationHandler = this.handleNotification.bind(this)
    document.addEventListener("importmap:notifications:received", this.notificationHandler)

    this.render({
      type: document.documentElement.dataset.cableState || "connecting",
      message: "Stimulus controller connected",
      timestamp: dayjs().toISOString()
    })
  }

  disconnect() {
    document.removeEventListener("importmap:notifications:received", this.notificationHandler)
  }

  ping() {
    document.dispatchEvent(
      new CustomEvent("importmap:notifications:ping", {
        detail: {
          message: `Manual refresh ${this.element.id || "importmap-demo"}`,
          timestamp: dayjs().toISOString()
        }
      })
    )
  }

  handleNotification(event) {
    this.render(event.detail || {})
  }

  render({ type = "waiting", message = "Waiting for updates", timestamp = dayjs().toISOString() }) {
    this.element.dataset.connectionState = type

    if (this.hasStatusTarget) {
      this.statusTarget.textContent = type
    }

    if (this.hasMessageTarget) {
      this.messageTarget.textContent = `${message} · ${timestamp}`
    }
  }
}

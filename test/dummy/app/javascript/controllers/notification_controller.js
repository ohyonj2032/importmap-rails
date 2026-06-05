import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "count", "badge"]

  static values = {
    channel: String,
    roomId: String,
    autoScroll: { type: Boolean, default: true },
    maxItems: { type: Number, default: 50 }
  }

  connect() {
    this.subscription = null
    this.notifications = []
    this.subscribe()
  }

  disconnect() {
    this.unsubscribe()
  }

  subscribe() {
    if (!this.channelValue) return

    const channelConfig = {
      channel: this.channelValue
    }

    if (this.hasRoomIdValue) {
      channelConfig.room_id = this.roomIdValue
    }

    this.subscription = App.cable.subscriptions.create(channelConfig, {
      received: (data) => this.handleReceived(data),
      connected: () => this.handleConnected(),
      disconnected: () => this.handleDisconnected(),
      rejected: () => this.handleRejected()
    })
  }

  unsubscribe() {
    if (this.subscription) {
      this.subscription.unsubscribe()
      this.subscription = null
    }
  }

  handleReceived(data) {
    this.notifications.push(data)

    if (this.notifications.length > this.maxItemsValue) {
      this.notifications.shift()
    }

    this.renderNotification(data)
    this.updateCount()
    this.dispatch("notification", { detail: data, prefix: true })
  }

  handleConnected() {
    this.element.dataset.cableStatus = "connected"
    this.dispatch("connected", { prefix: true })
  }

  handleDisconnected() {
    this.element.dataset.cableStatus = "disconnected"
    this.dispatch("disconnected", { prefix: true })

    this.scheduleReconnect()
  }

  handleRejected() {
    this.element.dataset.cableStatus = "rejected"
    this.dispatch("rejected", { prefix: true })
  }

  renderNotification(data) {
    if (!this.hasContainerTarget) return

    const element = document.createElement("div")
    element.classList.add("notification-item")
    element.textContent = data.message || JSON.stringify(data)

    this.containerTarget.appendChild(element)

    if (this.autoScrollValue) {
      this.containerTarget.scrollTop = this.containerTarget.scrollHeight
    }
  }

  updateCount() {
    if (this.hasCountTarget) {
      this.countTarget.textContent = this.notifications.length
    }

    if (this.hasBadgeTarget) {
      this.badgeTarget.textContent = this.notifications.length
      this.badgeTarget.classList.toggle("hidden", this.notifications.length === 0)
    }
  }

  clear(event) {
    event.preventDefault()
    this.notifications = []

    if (this.hasContainerTarget) {
      this.containerTarget.innerHTML = ""
    }

    this.updateCount()
  }

  scheduleReconnect() {
    if (this.reconnectTimer) clearTimeout(this.reconnectTimer)

    this.reconnectTimer = setTimeout(() => {
      if (this.subscription) {
        this.subscription.consumer.connection.reopen()
      }
    }, 3000)
  }

  channelValueChanged() {
    this.unsubscribe()
    this.subscribe()
  }

  roomIdValueChanged() {
    this.unsubscribe()
    this.subscribe()
  }
}

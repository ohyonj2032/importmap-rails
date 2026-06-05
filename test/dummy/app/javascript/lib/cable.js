const retryDelays = [1000, 2000, 4000, 8000, 16000, 32000]
const MAX_RETRY_DELAY = 30000

class CableManager {
  constructor() {
    this.subscriptions = new Map()
    this.retryCount = 0
    this.connectionState = "disconnected"
    this.stateChangeCallbacks = {
      connected: [],
      disconnected: [],
      rejected: []
    }
  }

  get consumer() {
    if (!this._consumer) {
      this._consumer = this.createConsumer()
    }
    return this._consumer
  }

  createConsumer() {
    const cableUrl = this.resolveCableUrl()

    if (typeof ActionCable !== "undefined" && ActionCable.createConsumer) {
      return ActionCable.createConsumer(cableUrl)
    }

    return import("@rails/actioncable").then(module => {
      return module.createConsumer(cableUrl)
    })
  }

  resolveCableUrl() {
    const metaTag = document.querySelector('meta[name="action-cable-url"]')
    if (metaTag) return metaTag.content

    if (window.location.protocol === "https:") {
      return `wss://${window.location.host}/cable`
    }

    return `ws://${window.location.host}/cable`
  }

  subscribe(channelName, callbacks = {}) {
    const channelConfig = typeof channelName === "string"
      ? { channel: channelName }
      : channelName

    const wrappedCallbacks = {
      received: (data) => {
        this.handleReceived(channelName, data)
        if (callbacks.received) callbacks.received(data)
      },
      connected: () => {
        this.retryCount = 0
        this.setConnectionState("connected")
        if (callbacks.connected) callbacks.connected()
      },
      disconnected: (attemptedReconnect) => {
        this.setConnectionState("disconnected")
        if (callbacks.disconnected) callbacks.disconnected(attemptedReconnect)
        this.scheduleReconnect(channelName, callbacks)
      },
      rejected: () => {
        this.setConnectionState("rejected")
        if (callbacks.rejected) callbacks.rejected()
      }
    }

    const subscription = this.consumer.subscriptions.create(channelConfig, wrappedCallbacks)
    this.subscriptions.set(channelName, subscription)

    return subscription
  }

  unsubscribe(channelName) {
    const subscription = this.subscriptions.get(channelName)
    if (subscription) {
      subscription.unsubscribe()
      this.subscriptions.delete(channelName)
    }
  }

  unsubscribeAll() {
    this.subscriptions.forEach((subscription) => subscription.unsubscribe())
    this.subscriptions.clear()
  }

  send(channelName, data) {
    const subscription = this.subscriptions.get(channelName)
    if (subscription) {
      subscription.send(data)
    }
  }

  perform(channelName, action, data = {}) {
    const subscription = this.subscriptions.get(channelName)
    if (subscription) {
      subscription.perform(action, data)
    }
  }

  handleReceived(channelName, data) {
    if (this.isDevEnvironment()) {
      console.log(`[CableManager] Received on ${channelName}:`, data)
    }
  }

  scheduleReconnect(channelName, callbacks) {
    if (this.retryCount >= retryDelays.length) return

    const delay = Math.min(retryDelays[this.retryCount], MAX_RETRY_DELAY)
    this.retryCount++

    setTimeout(() => {
      if (this.connectionState === "disconnected") {
        this.subscribe(channelName, callbacks)
      }
    }, delay)
  }

  setConnectionState(state) {
    const previousState = this.connectionState
    this.connectionState = state

    if (previousState !== state && this.stateChangeCallbacks[state]) {
      this.stateChangeCallbacks[state].forEach(callback => callback(state))
    }

    document.documentElement.dataset.cableState = state
  }

  onStateChange(state, callback) {
    if (this.stateChangeCallbacks[state]) {
      this.stateChangeCallbacks[state].push(callback)
    }
  }

  isDevEnvironment() {
    return document.documentElement.dataset.environment === "development"
  }

  isSubscribed(channelName) {
    return this.subscriptions.has(channelName)
  }

  getSubscription(channelName) {
    return this.subscriptions.get(channelName)
  }
}

const cableManager = new CableManager()

function createCableSubscription(channelName, callbacks) {
  return cableManager.subscribe(channelName, callbacks)
}

function removeCableSubscription(channelName) {
  cableManager.unsubscribe(channelName)
}

function sendCableMessage(channelName, data) {
  cableManager.send(channelName, data)
}

function performCableAction(channelName, action, data) {
  cableManager.perform(channelName, action, data)
}

export {
  cableManager,
  createCableSubscription,
  removeCableSubscription,
  sendCableMessage,
  performCableAction
}

export default cableManager

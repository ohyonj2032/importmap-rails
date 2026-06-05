// Analytics module for tracking page views and events
// This module is conditionally preloaded based on the entry point

const analytics = {
  initialized: false,

  init() {
    if (this.initialized) return
    this.initialized = true
  },

  trackPageView(path) {
    if (!this.initialized) this.init()
    console.log("[Analytics] Page view:", path || window.location.pathname)
  },

  trackEvent(category, action, label) {
    if (!this.initialized) this.init()
    console.log("[Analytics] Event:", category, action, label)
  }
}

export default analytics
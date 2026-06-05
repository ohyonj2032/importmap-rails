// Configure importmap with external dependencies
import "@rails/ujs"
import "@rails/request.js"

// Turbo for SPA-like navigation and form submissions
import "@hotwired/turbo"
import "@hotwired/turbo-rails"

// Stimulus controller framework with lazy-loading support
import "@hotwired/stimulus"
import "@hotwired/stimulus-loading"

// Action Cable for WebSocket connections
import { createConsumer } from "@rails/actioncable"

// Register the Stimulus application and load all controllers
import { Application } from "@hotwired/stimulus"

const application = Application.start()
application.debug = !productionEnvironment()
application.warnings = !productionEnvironment()
application.handleError = (error, message, detail) => {
  if (!productionEnvironment()) {
    console.error("Stimulus Error:", message, detail)
    console.error(error)
  }
}

// Load controllers following the standard Stimulus index convention
import controllers from "controllers/index"
import specialControllers from "controllers/special_index"

// Register controllers from the index.js barrel file
controllers.forEach((controller) => {
  application.register(controller.identifier, controller.controller)
})

specialControllers.forEach((controller) => {
  application.register(controller.identifier, controller.controller)
})

// Load lazy controllers (loaded on demand)
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

// Import custom utilities
import "helpers/requests/index"
import "helpers/requests/special_index"

// Setup Action Cable consumer with CSP-compatible configuration
const consumer = createConsumer(getConsumerUrl())

function getConsumerUrl() {
  const cableUrlMeta = document.querySelector("meta[name='action-cable-url']")
  if (cableUrlMeta) return cableUrlMeta.content

  const metaCableUrl = document.querySelector("meta[name='cable-url']")
  if (metaCableUrl) return metaCableUrl.content

  const protocol = window.location.protocol === "https:" ? "wss:" : "ws:"
  return `${protocol}//${window.location.host}/cable`
}

function productionEnvironment() {
  const envMeta = document.querySelector("meta[name='environment']")
  return envMeta ? envMeta.content === "production" : false
}

// Global error boundary for module import failures
window.addEventListener("error", (event) => {
  if (event.target && event.target.tagName === "SCRIPT") {
    if (!productionEnvironment()) {
      console.warn("Module import error:", event.target.src || event.target)
    }
  }
})
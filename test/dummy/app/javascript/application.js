// Entry point for the build script in your package.json
// This file is automatically loaded by the import map.

// 1. Dependency resolution and core library imports
import "@hotwired/turbo-rails"

// 2. Stimulus setup for component controllers
import { Application } from "@hotwired/stimulus"
// Use eager loading for controllers in production/development as configured in importmap
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"

// 3. Action Cable setup for WebSockets
import { createConsumer } from "@rails/actioncable"

// Initialize Stimulus application
const application = Application.start()
// Configure Stimulus development experience
application.debug = false
window.Stimulus = application

// Eager load all controllers from the "controllers" under app/javascript/controllers
// In a real app, this integrates with importmap-rails stimulus loading
eagerLoadControllersFrom("controllers", application)

// Setup Action Cable consumer and attach to global window object
// This ensures WebSocket connection and event handling mechanism are ready
const consumer = createConsumer()
window.ActionCable = consumer

// Export for application-wide usage
export { application, consumer }

// Import all Action Cable channels
import "channels"

// Example of conditional loading for performance optimization
// e.g., Lazy loading lodash only when needed
document.addEventListener("turbo:load", () => {
  console.log("Application initialized successfully!")
  
  // Example: Lazy load lodash
  // import("lodash").then(_) => {
  //   console.log(_.capitalize("hello world from lodash!"))
  // })
})

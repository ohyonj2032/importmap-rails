import { Application } from "@hotwired/stimulus"

const application = Application.start()

application.debug = document.documentElement.hasAttribute("data-stimulus-debug")
application.handleError = (error, message, detail) => {
  window.dispatchEvent(
    new CustomEvent("stimulus:error", {
      detail: {
        error,
        message,
        identifier: detail?.identifier
      }
    })
  )

  throw error
}

export { application }

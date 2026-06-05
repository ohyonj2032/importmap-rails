import { Application } from "@hotwired/stimulus"
import HelloController from "controllers/hello_controller"
import GoodbyeController from "controllers/goodbye_controller"
import NotificationController from "controllers/notification_controller"

const application = Application.start()

application.register("hello", HelloController)
application.register("goodbye", GoodbyeController)
application.register("notification", NotificationController)

application.debug = document.documentElement.hasAttribute("data-controller-debug")

application.stimulusUseLogger = true

window.Stimulus = application

export { application }

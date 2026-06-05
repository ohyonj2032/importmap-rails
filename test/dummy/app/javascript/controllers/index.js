import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"

let controllersLoaded = false

function loadControllers(stimulus = application) {
  if (controllersLoaded) {
    return stimulus
  }

  eagerLoadControllersFrom("controllers", stimulus)
  controllersLoaded = true
  return stimulus
}

export { application, loadControllers }

import { application } from "controllers/application"
import GoodbyeController from "controllers/goodbye_controller"

export function loadControllers(stimulus = application) {
  stimulus.register("goodbye", GoodbyeController)
  return stimulus
}

// Stimulus controllers barrel file
// This file auto-registers controllers from the controllers directory
// Each controller is exported as a named module with its identifier

import goodbye_controller from "controllers/goodbye_controller"

const controllers = [
  { identifier: "goodbye", controller: goodbye_controller }
]

export default controllers
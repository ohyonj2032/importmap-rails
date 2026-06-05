import { createConsumer } from "@rails/actioncable"

function actionCableURL() {
  return document.querySelector('meta[name="action-cable-url"]')?.content
}

const consumer = createConsumer(actionCableURL())

export default consumer

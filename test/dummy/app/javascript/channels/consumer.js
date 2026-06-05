import { createConsumer } from "@rails/actioncable"

function cableURL() {
  const configuredURL = document.head.querySelector("meta[name='action-cable-url']")?.content

  if (configuredURL) {
    return configuredURL
  }

  const protocol = window.location.protocol === "https:" ? "wss" : "ws"
  return `${protocol}://${window.location.host}/cable`
}

export default createConsumer(cableURL())

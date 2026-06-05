import { consumer } from "../application"

consumer.subscriptions.create("ExampleChannel", {
  connected() {
    console.log("Connected to ExampleChannel via Action Cable!")
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
  }
})

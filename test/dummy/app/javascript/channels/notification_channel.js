// Example channel subscription
// This demonstrates how to subscribe to an Action Cable channel
// Each channel has its own subscription logic

import { getConsumer } from "channels/consumer"

export function subscribeToNotifications() {
  const consumer = getConsumer()

  return consumer.subscriptions.create(
    { channel: "NotificationsChannel" },
    {
      connected() {
        console.log("Connected to NotificationsChannel")
      },

      disconnected() {
        console.log("Disconnected from NotificationsChannel")
      },

      received(data) {
        console.log("Received data:", data)
      }
    }
  )
}

export function unsubscribeFromNotifications(subscription) {
  if (subscription) {
    subscription.unsubscribe()
  }
}
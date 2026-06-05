import { createConsumer } from "@rails/actioncable"

const consumer = createConsumer()

export default consumer

export const connectToChannel = (channelName, params = {}, handlers = {}) => {
  return consumer.subscriptions.create(
    { channel: channelName, ...params },
    {
      connected() {
        console.log(`Connected to ${channelName}`)
        if (handlers.connected) handlers.connected()
      },

      disconnected() {
        console.log(`Disconnected from ${channelName}`)
        if (handlers.disconnected) handlers.disconnected()
      },

      received(data) {
        console.log(`Received from ${channelName}:`, data)
        if (handlers.received) handlers.received(data)
      },

      rejected() {
        console.log(`Connection rejected for ${channelName}`)
        if (handlers.rejected) handlers.rejected()
      },

      ...handlers
    }
  )
}

export const disconnectAll = () => {
  consumer.subscriptions.subscriptions.forEach(subscription => {
    subscription.unsubscribe()
  })
}

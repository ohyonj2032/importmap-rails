import consumer from "./consumer"

export const ChatChannel = {
  subscribe(roomId, handlers = {}) {
    return consumer.subscriptions.create(
      { channel: "ChatChannel", room_id: roomId },
      {
        connected() {
          console.log(`Connected to chat room ${roomId}`)
          if (handlers.connected) handlers.connected()
        },

        disconnected() {
          console.log(`Disconnected from chat room ${roomId}`)
          if (handlers.disconnected) handlers.disconnected()
        },

        received(data) {
          console.log('Chat message received:', data)
          if (handlers.received) handlers.received(data)
        },

        speak(message) {
          this.perform('speak', { message: message })
        },

        typing(isTyping) {
          this.perform('typing', { is_typing: isTyping })
        },

        markAsRead(messageId) {
          this.perform('mark_as_read', { message_id: messageId })
        }
      }
    )
  }
}

export default ChatChannel

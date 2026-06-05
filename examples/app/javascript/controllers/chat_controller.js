import { Controller } from "@hotwired/stimulus"
import ChatChannel from "../channels/chat_channel"

export default class extends Controller {
  static targets = ["messages", "input", "form", "typing"]
  static values = { roomId: String, currentUserId: String }

  connect() {
    this.subscription = ChatChannel.subscribe(this.roomIdValue, {
      connected: () => this.handleConnected(),
      disconnected: () => this.handleDisconnected(),
      received: (data) => this.handleReceived(data)
    })
    
    this.typingTimeout = null
  }

  handleConnected() {
    console.log('Chat connected')
  }

  handleDisconnected() {
    console.log('Chat disconnected')
  }

  handleReceived(data) {
    if (data.type === 'message') {
      this.appendMessage(data)
    } else if (data.type === 'typing') {
      this.handleTyping(data)
    } else if (data.type === 'read') {
      this.markMessageAsRead(data.message_id)
    }
  }

  sendMessage(event) {
    event.preventDefault()
    const message = this.inputTarget.value.trim()
    
    if (message) {
      this.subscription.speak(message)
      this.inputTarget.value = ''
    }
  }

  handleTyping(event) {
    clearTimeout(this.typingTimeout)
    this.subscription.typing(true)
    
    this.typingTimeout = setTimeout(() => {
      this.subscription.typing(false)
    }, 2000)
  }

  appendMessage(data) {
    const messageElement = document.createElement('div')
    messageElement.className = `chat-message ${data.user_id === this.currentUserIdValue ? 'current-user' : 'other-user'}`
    messageElement.dataset.messageId = data.id
    messageElement.innerHTML = `
      <div class="message-header">
        <span class="username">${data.username}</span>
        <span class="timestamp">${new Date(data.created_at).toLocaleTimeString()}</span>
      </div>
      <div class="message-body">${data.body}</div>
    `
    
    this.messagesTarget.appendChild(messageElement)
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
  }

  handleTyping(data) {
    if (data.user_id !== this.currentUserIdValue) {
      if (data.is_typing) {
        this.typingTarget.textContent = `${data.username} 正在输入...`
        this.typingTarget.classList.remove('hidden')
      } else {
        this.typingTarget.classList.add('hidden')
      }
    }
  }

  markMessageAsRead(messageId) {
    const message = this.messagesTarget.querySelector(`[data-message-id="${messageId}"]`)
    if (message) {
      message.classList.add('read')
    }
  }

  disconnect() {
    if (this.subscription) {
      this.subscription.unsubscribe()
    }
    clearTimeout(this.typingTimeout)
  }
}

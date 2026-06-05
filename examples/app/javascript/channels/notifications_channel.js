import consumer from "./consumer"

consumer.subscriptions.create("NotificationsChannel", {
  connected() {
    console.log('Connected to NotificationsChannel')
    this.dispatch('connected')
  },

  disconnected() {
    console.log('Disconnected from NotificationsChannel')
    this.dispatch('disconnected')
  },

  received(data) {
    console.log('Received notification:', data)
    this.dispatch('received', { detail: data })
    this.displayNotification(data)
  },

  displayNotification(data) {
    const notification = this.createNotificationElement(data)
    this.addToNotificationContainer(notification)
    
    if (Notification.permission === 'granted') {
      new Notification(data.title || '新通知', {
        body: data.body,
        icon: data.icon || '/favicon.ico'
      })
    }
  },

  createNotificationElement(data) {
    const notification = document.createElement('div')
    notification.className = 'notification'
    notification.innerHTML = `
      <div class="notification-content">
        <h4>${data.title || '新通知'}</h4>
        <p>${data.body}</p>
      </div>
      <button class="notification-close">&times;</button>
    `
    
    const closeBtn = notification.querySelector('.notification-close')
    closeBtn.addEventListener('click', () => {
      notification.remove()
    })
    
    setTimeout(() => {
      notification.remove()
    }, data.duration || 5000)
    
    return notification
  },

  addToNotificationContainer(notification) {
    let container = document.getElementById('notifications-container')
    
    if (!container) {
      container = document.createElement('div')
      container.id = 'notifications-container'
      container.className = 'notifications-container'
      document.body.appendChild(container)
    }
    
    container.appendChild(notification)
  },

  requestNotificationPermission() {
    if ('Notification' in window) {
      Notification.requestPermission()
    }
  },

  dispatch(eventName, options = {}) {
    const event = new CustomEvent(`notifications:${eventName}`, {
      bubbles: true,
      cancelable: true,
      detail: options.detail
    })
    document.dispatchEvent(event)
  }
})

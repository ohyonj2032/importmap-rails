class NotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
  end

  def unsubscribed
    stop_all_streams
  end

  def mark_as_read(data)
    notification = Notification.find_by(id: data["notification_id"])
    return unless notification&.user == current_user

    notification.update(read: true)
    transmit(type: "read", notification_id: notification.id)
  end

  def fetch_unread
    notifications = Notification.where(user: current_user, read: false)
    transmit(type: "unread_count", count: notifications.count)
  end
end

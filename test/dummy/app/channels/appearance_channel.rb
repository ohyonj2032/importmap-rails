class AppearanceChannel < ApplicationCable::Channel
  def subscribed
    stream_from "appearance"
    current_user&.update(online: true)
    broadcast_online_status
  end

  def unsubscribed
    current_user&.update(online: false)
    broadcast_online_status
  end

  def appear
    broadcast_online_status
  end

  def away
    current_user&.update(online: false)
    broadcast_online_status
  end

  private

  def broadcast_online_status
    ActionCable.server.broadcast("appearance", {
      user_id: current_user&.id,
      status: current_user&.online? ? "online" : "offline",
      appeared_at: Time.current.iso8601
    })
  end
end

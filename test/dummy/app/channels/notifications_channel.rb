class NotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_from stream_name
    transmit payload(type: "connected", message: "Server subscription established")
  end

  def ping(data)
    transmit payload(type: "message", message: data["message"].presence || "Ping received")
  end

  private
    def stream_name
      "importmap_notifications"
    end

    def payload(type:, message:)
      {
        type: type,
        message: message,
        timestamp: Time.current.iso8601
      }
    end
end

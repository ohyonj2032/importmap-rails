class ImportmapNotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "importmap_notifications"
    transmit(
      "type" => "system",
      "message" => "Action Cable connected",
      "timestamp" => Time.current.iso8601
    )
  end

  def receive(data)
    ActionCable.server.broadcast(
      "importmap_notifications",
      "type" => data["type"].presence || "event",
      "message" => data["message"].presence || "Broadcast received",
      "timestamp" => Time.current.iso8601
    )
  end
end

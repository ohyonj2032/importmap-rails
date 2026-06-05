class ApplicationController < ActionController::Base
  stale_when_importmap_changes

  private

  def action_cable_with_token_url
    config = Rails.application.config.action_cable
    config.url || "/cable"
  end
end

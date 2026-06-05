require_relative "boot"

require "logger"
require "rails"
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"
require "action_cable/engine"
begin
  require "sprockets/railtie"
rescue LoadError
end
require "active_storage/engine"

Bundler.require(*Rails.groups)
require "importmap-rails"

module Dummy
  class Application < Rails::Application
    config.load_defaults Rails::VERSION::STRING.to_f
  end
end

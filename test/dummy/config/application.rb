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
  # This is safe to ignore: it's expected that sprockets-rails won't be
  # available when we're testing against an application that uses rails 7 with
  # an alternative asset pipeline (e.g. propshaft).
end
require "active_storage/engine"

Bundler.require(*Rails.groups)
require "importmap-rails"

module Dummy
  class Application < Rails::Application
    config.load_defaults Rails::VERSION::STRING.to_f
  end
end

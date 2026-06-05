require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true
  config.importmap.sweep_cache = false
  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?
  config.public_file_server.headers = {
    "Cache-Control" => "public, max-age=#{1.year.to_i}, immutable"
  }
  config.assets.compile = false
  config.active_storage.service = :local
  config.log_level = :info
  config.log_tags = [:request_id]
  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify
  config.active_support.disallowed_deprecation = :log
  config.active_support.disallowed_deprecation_warnings = []
  config.log_formatter = ::Logger::Formatter.new

  if config.respond_to?(:action_view) && config.action_view.respond_to?(:preload_links_header=)
    config.action_view.preload_links_header = true
  end

  if ENV["ACTION_CABLE_URL"].present?
    config.action_cable.url = ENV["ACTION_CABLE_URL"]
  elsif ENV["APP_ORIGIN"].present?
    config.action_cable.url = "#{ENV["APP_ORIGIN"].sub(/\Ahttp/, "ws")}/cable"
  end

  if ENV["APP_ORIGIN"].present?
    config.action_cable.allowed_request_origins = [ENV["APP_ORIGIN"]]
  end

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger = ActiveSupport::TaggedLogging.new(logger)
  end

  config.active_record.dump_schema_after_migration = false
end

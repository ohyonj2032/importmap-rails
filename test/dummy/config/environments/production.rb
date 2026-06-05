require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.cache_classes = true

  config.eager_load = true

  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  config.assets.compile = false

  config.assets.integrity_hash_algorithm = "sha384"

  config.asset_host = ENV.fetch("ASSET_HOST", nil)

  config.importmap.sweep_cache = false

  config.action_cable.mount_path = "/cable"
  config.action_cable.url = ENV.fetch("ACTION_CABLE_URL", "wss://#{ENV.fetch('APPLICATION_HOST', 'localhost')}/cable")
  config.action_cable.allowed_request_origins = ENV.fetch("ACTION_CABLE_ALLOWED_ORIGINS", "").split(",").presence

  config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'

  config.active_storage.service = :local

  config.force_ssl = true

  config.log_level = :info

  config.log_tags = [ :request_id ]

  config.cache_store = :mem_cache_store

  config.i18n.fallbacks = true

  config.active_support.deprecation = :notify

  config.active_support.disallowed_deprecation = :log

  config.active_support.disallowed_deprecation_warnings = []

  config.log_formatter = ::Logger::Formatter.new

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  config.active_record.dump_schema_after_migration = false

  config.public_file_server.headers = {
    'Cache-Control' => "public, max-age=#{1.year.to_i}, immutable",
    'X-Content-Type-Options' => 'nosniff'
  }

  config.ssl_options = {
    hsts: { subdomains: true, preload: true, expires: 1.year }
  }
end

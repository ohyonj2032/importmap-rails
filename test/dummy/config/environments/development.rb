require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.cache_classes = false
  config.eager_load = false
  config.consider_all_requests_local = true
  config.importmap.sweep_cache = true

  if Rails.root.join("tmp", "caching-dev.txt").exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true
    config.cache_store = :memory_store
    config.public_file_server.headers = {
      "Cache-Control" => "public, max-age=#{1.hour.to_i}, must-revalidate"
    }
  else
    config.action_controller.perform_caching = false
    config.cache_store = :null_store
    config.public_file_server.headers = {
      "Cache-Control" => "no-store"
    }
  end

  config.active_storage.service = :local
  config.active_support.deprecation = :log
  config.active_support.disallowed_deprecation = :raise
  config.active_support.disallowed_deprecation_warnings = []
  config.active_record.migration_error = :page_load
  config.active_record.verbose_query_logs = true
  config.assets.debug = true
  config.assets.quiet = true

  if config.respond_to?(:action_view) && config.action_view.respond_to?(:preload_links_header=)
    config.action_view.preload_links_header = true
  end

  config.action_cable.allowed_request_origins = [
    /http:\/\/localhost:\d+/,
    /http:\/\/127\.0\.0\.1:\d+/,
    /https:\/\/localhost:\d+/,
    /https:\/\/127\.0\.0\.1:\d+/
  ]
end

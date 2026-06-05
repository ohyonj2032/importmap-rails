require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.cache_classes = false

  config.eager_load = false

  config.consider_all_requests_local = true

  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  config.active_storage.service = :local

  config.active_support.deprecation = :log

  config.active_support.disallowed_deprecation = :raise

  config.active_support.disallowed_deprecation_warnings = []

  config.active_record.migration_error = :page_load

  config.active_record.verbose_query_logs = true

  config.assets.debug = true

  config.assets.quiet = true

  config.assets.integrity_hash_algorithm = "sha384"

  config.importmap.sweep_cache = true
  config.importmap.cache_sweepers << Rails.root.join("app/javascript")
  config.importmap.cache_sweepers << Rails.root.join("app/components")
  config.importmap.cache_sweepers << Rails.root.join("vendor/javascript")

  config.action_cable.disable_request_forgery_protection = true

  config.action_cable.allowed_request_origins = [/http:\/\/localhost:\d+/]

  config.public_file_server.headers = {
    'Cache-Control' => "public, max-age=0, must-revalidate",
    'X-Content-Type-Options' => 'nosniff'
  }
end

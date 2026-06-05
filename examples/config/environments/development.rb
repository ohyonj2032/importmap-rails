# frozen_string_literal: true

# Development environment configuration for importmap-rails

Rails.application.configure do
  # Configure importmap cache sweeping
  config.importmap.sweep_cache = true
  
  # Add additional cache sweepers for external JavaScript directories
  # config.importmap.cache_sweepers << Rails.root.join("lib/javascript")
  
  # Configure asset integrity (disabled in development for faster reloads)
  config.assets.integrity_hash_algorithm = 'sha384'
  
  # Enable debug mode for JavaScript assets
  config.assets.debug = true
  
  # Disable asset digests in development for easier debugging
  config.assets.digest = false
  
  # Configure cache headers for JavaScript files in development
  config.public_file_server.headers = {
    'Cache-Control' => 'no-cache, no-store, must-revalidate',
    'Pragma' => 'no-cache',
    'Expires' => '0'
  }
end

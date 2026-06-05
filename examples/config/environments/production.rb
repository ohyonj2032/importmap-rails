# frozen_string_literal: true

# Production environment configuration for importmap-rails

Rails.application.configure do
  # Configure importmap (cache sweeping disabled in production)
  config.importmap.sweep_cache = false
  
  # Configure asset integrity for production security
  config.assets.integrity_hash_algorithm = 'sha384'
  
  # Disable debug mode
  config.assets.debug = false
  
  # Enable asset digests for cache busting
  config.assets.digest = true
  
  # Compress JavaScript assets
  config.assets.js_compressor = :terser
  
  # Configure aggressive caching for JavaScript files
  config.public_file_server.headers = {
    'Cache-Control' => 'public, max-age=31536000, immutable',
    'Access-Control-Allow-Origin' => '*'
  }
  
  # Enable gzip compression
  config.middleware.use Rack::Deflater
  
  # Configure Content Security Policy (CSP) for importmaps
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.script_src  :self, 
                       'https://cdn.jsdelivr.net',
                       'https://ga.jspm.io',
                       :unsafe_inline,
                       :nonce
    policy.style_src   :self, :unsafe_inline
    policy.img_src     :self, :data, 'https://*'
    policy.connect_src :self, 
                       'wss://*', 
                       'ws://*',
                       'https://cdn.jsdelivr.net',
                       'https://ga.jspm.io'
    policy.font_src    :self, :data
    policy.object_src  :none
    policy.frame_src   :none
    policy.form_action :self
    policy.base_uri    :self
  end
  
  # Generate nonce for CSP
  config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
  config.content_security_policy_nonce_directives = %w(script-src)
end

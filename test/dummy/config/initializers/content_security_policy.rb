# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy
# For further information see the following documentation
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy

Rails.application.config.content_security_policy do |policy|
  policy.default_src :self, :https
  policy.font_src    :self, :https, :data
  policy.img_src     :self, :https, :data
  policy.object_src  :none
  
  # Allow script execution from self and configured CDNs for importmap-rails
  policy.script_src  :self, :https, "https://ga.jspm.io", "https://cdn.jsdelivr.net", "https://unpkg.com"
  
  # Allow style loading from self and https
  policy.style_src   :self, :https

  # Allow Action Cable websocket connections
  policy.connect_src :self, :https, "ws://localhost:*", "ws://127.0.0.1:*", "wss://*"

  # Specify URI for violation reports
  # policy.report_uri "/csp-violation-report-endpoint"
end

# If you are using UJS then enable automatic nonce generation
# Rails.application.config.content_security_policy_nonce_generator = -> request { SecureRandom.base64(16) }

# Enable automatic nonce generation for the importmap and modulepreloads tags
Rails.application.config.content_security_policy_nonce_generator = -> request { request.session.id.to_s.presence || SecureRandom.base64(16) }
Rails.application.config.content_security_policy_nonce_directives = %w(script-src)

# Report CSP violations to a specified URI
# For further information see the following documentation:
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy-Report-Only
# Rails.application.config.content_security_policy_report_only = true

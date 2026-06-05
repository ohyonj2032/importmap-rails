# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy
# For further information see the following documentation
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy

Rails.application.config.content_security_policy do |policy|
  policy.default_src :self, :https
  policy.font_src    :self, :https, :data
  policy.img_src     :self, :https, :data, :blob
  policy.object_src  :none

  # Allow JavaScript from self, CDN sources, and importmap sources
  policy.script_src  :self, :https, :unsafe_inline,
    "https://cdn.skypack.dev",
    "https://ga.jspm.io",
    "https://cdn.jsdelivr.net",
    "https://unpkg.com"

  policy.style_src   :self, :https, :unsafe_inline

  # Allow WebSocket connections for Action Cable
  if Rails.env.development? || Rails.env.test?
    policy.connect_src :self, :https, "ws://localhost:3000", "wss://localhost:3000",
      "ws://127.0.0.1:3000", "wss://127.0.0.1:3000",
      "http://localhost:*", "https://localhost:*"
  else
    policy.connect_src :self, :https, :wss
  end

  # Allow fonts from CDNs
  policy.font_src :self, :https, :data, "https://fonts.gstatic.com",
    "https://cdn.jsdelivr.net"

  # Allow media from self and CDN
  policy.media_src :self, :https, :data

  # Allow frames from self only (prevents clickjacking)
  policy.frame_src :self

  # Allow form actions to self only
  policy.form_action :self

  # Allow worker scripts for Web Workers
  policy.worker_src :self, :blob

  # Specify URI for violation reports
  # policy.report_uri "/csp-violation-report-endpoint"
end

# Enable automatic nonce generation for inline scripts
# This provides a secure way to allow inline scripts (like importmap)
Rails.application.config.content_security_policy_nonce_generator = -> request {
  SecureRandom.base64(16)
}

# Set the nonce to script-src and style-src directives
# This allows importmap inline scripts to pass CSP validation
Rails.application.config.content_security_policy_nonce_directives = %w(script-src style-src)

# Report CSP violations to a specified URI
# For further information see the following documentation:
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy-Report-Only
# In development, use report-only mode to test CSP without blocking
if Rails.env.development? || Rails.env.test?
  Rails.application.config.content_security_policy_report_only = true
else
  Rails.application.config.content_security_policy_report_only = false
end
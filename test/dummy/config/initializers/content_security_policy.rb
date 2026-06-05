require "securerandom"

Rails.application.config.content_security_policy do |policy|
  policy.default_src :self, :https
  policy.base_uri :self
  policy.font_src :self, :https, :data
  policy.img_src :self, :https, :data, :blob
  policy.object_src :none
  policy.script_src :self, :https
  policy.style_src :self, :https
  policy.connect_src :self, :https, :ws, :wss
  policy.frame_ancestors :none
end

Rails.application.config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s.presence || SecureRandom.base64(16) }
Rails.application.config.content_security_policy_nonce_directives = %w(script-src style-src)

Rails.application.config.content_security_policy do |policy|
  policy.default_src :self, :https

  policy.script_src  :self, :https,
    "https://ga.jspm.io",
    "https://cdn.skypack.dev",
    "https://esm.sh"

  policy.style_src   :self, :https, :unsafe_inline

  policy.img_src     :self, :https, :data

  policy.font_src    :self, :https, :data

  policy.connect_src :self, :https, "ws://localhost:3000", "wss://localhost:3000",
    "https://ga.jspm.io"

  policy.object_src  :none

  policy.frame_ancestors :none

  policy.base_uri     :self

  policy.form_action  :self

  policy.frame_src    :self, :https

  policy.manifest_src :self
end

Rails.application.config.content_security_policy_nonce_generator = -> request { SecureRandom.base64(16) }

Rails.application.config.content_security_policy_nonce_directives = %w(script-src style-src)

if Rails.env.production?
  Rails.application.config.content_security_policy_report_only = false
else
  Rails.application.config.content_security_policy_report_only = true
end

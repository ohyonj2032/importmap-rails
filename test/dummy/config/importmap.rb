# Enable Subresource Integrity (SRI) for enhanced security
enable_integrity!

# Map local JavaScript modules
pin "application", preload: true
pin_all_from "app/javascript/controllers", under: "controllers", preload: true
pin "channels", to: "channels/index.js", preload: false
pin_all_from "app/javascript/channels", under: "channels", preload: false

# Map npm packages using CDN
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin "@rails/actioncable", to: "actioncable.esm.js", preload: true

# Example: CDN reference with specific Subresource Integrity (SRI) and lazy loading
pin "lodash", to: "https://ga.jspm.io/npm:lodash@4.17.21/lodash.js", preload: false, integrity: "sha384-PkIkha4kVPRlGtFantHjuv+Y9mRefUHpLFQbgOYUjzy247kvi16kLR7wWnsAmqZF"

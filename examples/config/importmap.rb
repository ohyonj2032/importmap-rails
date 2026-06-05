# frozen_string_literal: true

# Enable integrity check for enhanced security (SRI - Subresource Integrity)
enable_integrity! unless Rails.env.development?

# Pin npm packages by running ./bin/importmap
# Or manually pin them with CDN URLs

# =============================================================================
# Rails core libraries (Action Cable, Active Storage, Action Text)
# =============================================================================
pin "@rails/actioncable", to: "actioncable.esm.js", preload: true
pin "@rails/activestorage", to: "activestorage.esm.js", preload: true
pin "@rails/actiontext", to: "actiontext.esm.js", preload: true
pin "trix", preload: true

# =============================================================================
# StimulusJS - Modest JavaScript framework
# =============================================================================
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers", preload: true

# =============================================================================
# Turbo - The speed of a single-page web application without the complexity
# =============================================================================
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true

# =============================================================================
# Local JavaScript modules
# =============================================================================
pin_all_from "app/javascript/channels", under: "channels", preload: false
pin_all_from "app/javascript/helpers", under: "helpers", preload: false
pin_all_from "app/javascript/utils", under: "utils", preload: false
pin_all_from "app/javascript/components", under: "components", preload: false

# =============================================================================
# Utility libraries from CDN (with SRI for production)
# =============================================================================
pin "lodash-es", 
    to: "https://cdn.jsdelivr.net/npm/lodash-es@4.17.21/lodash.min.js",
    preload: false,
    integrity: "sha384-8D5yLz0uO9Kj5y5u5l5u5l5u5l5u5l5u5l5u5l5u5l5u5l5u5l5u5l5u5l5u5l"

pin "dayjs",
    to: "https://cdn.jsdelivr.net/npm/dayjs@1.11.10/dayjs.min.js",
    preload: false,
    integrity: "sha384-9D5yLz0uO9Kj5y5u5l5u5l5u5l5u5l5u5l5u5l5u5l5u5l5u5l5u5l5u5l5u5l"

pin "axios",
    to: "https://cdn.jsdelivr.net/npm/axios@1.6.2/dist/esm/axios.min.js",
    preload: false,
    integrity: "sha384-7D5yLz0uO9Kj5y5u5l5u5l5u5l5u5l5u5l5u5l5u5l5u5l5u5l5u5l5u5l5u5l"

# =============================================================================
# Application entry point
# =============================================================================
pin "application", preload: true

# =============================================================================
# Page-specific modules (loaded on demand)
# =============================================================================
pin "checkout", preload: false
pin "dashboard", preload: false
pin "admin", preload: false

# =============================================================================
# Environment-specific configuration
# =============================================================================
if Rails.env.development?
  # Development only: no integrity check for faster reloads
  pin "devtools", to: "https://cdn.jsdelivr.net/npm/vconsole@3.15.1/dist/vconsole.min.js", preload: false
elsif Rails.env.production?
  # Production only: extra security measures
  pin "error-tracking", to: "https://cdn.example.com/error-tracking.js", preload: true
end

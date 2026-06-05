# Pin npm packages by running ./bin/importmap

# Enable Subresource Integrity (SRI) for all local assets
# This automatically calculates integrity hashes for local files
enable_integrity!

# Entry point for the application
pin "application", preload: true

# Core Rails JavaScript libraries
pin "@rails/actioncable", to: "https://ga.jspm.io/npm:@rails/actioncable@7.1.3/app/assets/javascripts/actioncable.esm.js", integrity: "sha384-...", preload: true
pin "@rails/activestorage", to: "https://ga.jspm.io/npm:@rails/activestorage@7.1.3/app/assets/javascripts/activestorage.esm.js", integrity: "sha384-...", preload: true
pin "@rails/ujs", to: "https://ga.jspm.io/npm:@rails/ujs@7.1.3/lib/assets/javascripts/rails-ujs.esm.js", integrity: "sha384-...", preload: true
pin "@rails/request.js", to: "https://ga.jspm.io/npm:@rails/request.js@0.0.9/src/index.js", integrity: "sha384-...", preload: false

# Turbo
pin "@hotwired/turbo", to: "https://ga.jspm.io/npm:@hotwired/turbo@8.0.4/dist/turbo.esm.js", integrity: "sha384-...", preload: true
pin "@hotwired/turbo-rails", to: "https://ga.jspm.io/npm:@hotwired/turbo-rails@8.0.4/app/javascript/turbo/index.js", integrity: "sha384-...", preload: true

# Stimulus
pin "@hotwired/stimulus", to: "https://ga.jspm.io/npm:@hotwired/stimulus@3.2.2/dist/stimulus.js", integrity: "sha384-...", preload: true
pin "@hotwired/stimulus-loading", to: "https://ga.jspm.io/npm:@hotwired/stimulus-loading@1.0.1/stimulus-loading.js", integrity: "sha384-...", preload: true

# Map all local controller directories for Stimulus
pin_all_from "app/javascript/controllers", under: "controllers", preload: ["application"]
pin_all_from "app/javascript/controllers/utilities", under: "controllers/utilities", preload: ["application"]

# Support for component-based controllers (lookbook/component library pattern)
pin_all_from "app/components", under: "controllers", to: "app/components", preload: ["application"]

# Map custom utility directories
pin_all_from "app/javascript/helpers", under: "helpers", preload: false
pin_all_from "app/javascript/services", under: "services", preload: false
pin_all_from "app/javascript/utils", under: "utils", preload: false
pin_all_from "app/javascript/channels", under: "channels", preload: ["application"]

# Map vendor directory for manually vendored packages
pin_all_from "vendor/javascript", under: nil, preload: false

# Common utility libraries (example CDN pins with SRI)
pin "lodash-es", to: "https://ga.jspm.io/npm:lodash-es@4.17.21/lodash.js", integrity: "sha384-...", preload: false
pin "axios", to: "https://ga.jspm.io/npm:axios@1.6.8/dist/esm/axios.js", integrity: "sha384-...", preload: false
pin "date-fns", to: "https://ga.jspm.io/npm:date-fns@2.30.0/dist/esm/index.js", integrity: "sha384-...", preload: false

# Example: domain-specific packages with conditional preloading
# These will only be preloaded when on specific entry points
pin "admin/application", preload: "admin", integrity: true
pin "checkout/application", preload: ["checkout", "payment"], integrity: true

# Example: disable integrity for certain external CDNs that don't provide it
pin "some-third-party", to: "https://example.com/script.js", integrity: false, preload: false

# Local custom JavaScript files
pin "rich_text", preload: true
pin "analytics", preload: "application", integrity: true

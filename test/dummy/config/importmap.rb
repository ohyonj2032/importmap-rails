enable_integrity!

pin "application", preload: true

pin_all_from "app/javascript/controllers", under: "controllers", preload: true

pin_all_from "app/javascript/lib", under: "lib", preload: true

pin_all_from "app/javascript/channels", under: "channels", preload: true

pin_all_from "app/components", under: "controllers", to: "", preload: true

pin "@hotwired/stimulus", to: "https://ga.jspm.io/npm:@hotwired/stimulus@3.2.2/dist/stimulus.js", preload: true
pin "@hotwired/turbo-rails", to: "https://ga.jspm.io/npm:@hotwired/turbo-rails@8.0.12/dist/turbo.min.js", preload: true

pin "debounce", to: "https://ga.jspm.io/npm:debounce@2.2.0/index.js", preload: false

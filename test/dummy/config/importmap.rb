enable_integrity!

pin "application", preload: false
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: ["application"]
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: ["application"]
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: ["application"]
pin "dayjs", to: "https://ga.jspm.io/npm:dayjs@1.11.13/dayjs.min.js", preload: ["application"], integrity: false
pin "md5", to: "https://ga.jspm.io/npm:md5@2.3.0/md5.js", preload: false, integrity: false

if Gem::Version.new(Rails.version) >= Gem::Version.new("7.0.0")
  pin "@rails/actioncable", to: "actioncable.esm.js", preload: ["application"]
end

pin_all_from "app/javascript/controllers", under: "controllers", preload: ["application"], integrity: true
pin_all_from "app/javascript/channels", under: "channels", preload: ["application"], integrity: true
pin_all_from "app/javascript/lib", under: "lib", preload: ["application"], integrity: true

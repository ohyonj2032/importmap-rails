enable_integrity!

pin_all_from "app/javascript", under: "controllers"
pin_all_from "app/components", under: "components"
pin_all_from "lib/assets/javascripts", under: "lib"

pin "application", preload: true
pin "rich_text", preload: true
pin "md5", to: "https://cdnjs.cloudflare.com/ajax/libs/blueimp-md5/2.19.0/js/md5.min.js", preload: true
pin "react", to: "https://cdnjs.cloudflare.com/ajax/libs/react/18.2.0/umd/react.production.min.js", preload: true
pin "react-dom", to: "https://cdnjs.cloudflare.com/ajax/libs/react-dom/18.2.0/umd/react-dom.production.min.js", preload: true
pin "@hotwired/stimulus", to: "https://cdnjs.cloudflare.com/ajax/libs/stimulus/3.2.2/stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "https://cdnjs.cloudflare.com/ajax/libs/stimulus-loading/1.0.1/index.min.js", preload: true

resolve_alias "controllers", to: "app/javascript/controllers"
resolve_alias "components", to: "app/components"
resolve_alias "lib", to: "lib/assets/javascripts"

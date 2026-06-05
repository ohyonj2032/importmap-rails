enable_integrity!

pin "application"

pin "react", to: "https://cdnjs.cloudflare.com/ajax/libs/react/18.3.1/umd/react.production.min.js", preload: true
pin "react-dom", to: "https://cdnjs.cloudflare.com/ajax/libs/react-dom/18.3.1/umd/react-dom.production.min.js", preload: true
pin "react/jsx-runtime", to: "https://cdnjs.cloudflare.com/ajax/libs/react/18.3.1/umd/react-jsx-runtime.production.min.js", preload: true

pin "scheduler", to: "https://cdnjs.cloudflare.com/ajax/libs/react/18.3.1/umd/react.production.min.js"

pin_all_from "app/javascript/controllers", under: "controllers", preload: false
pin_all_from "app/javascript/helpers", under: "helpers", preload: false
pin_all_from "app/assets/javascripts", under: "lib", preload: false

pin "md5", to: "https://cdnjs.cloudflare.com/ajax/libs/blueimp-md5/2.19.0/js/md5.min.js", preload: false
pin "not_there", to: "nowhere.js", preload: false, integrity: false
pin "rich_text", preload: true
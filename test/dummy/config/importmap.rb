enable_integrity!

pin_all_from "app/assets/javascripts"
pin_all_from "app/assets/builds", under: "builds", preload: false

pin "application", to: "builds/application.js", preload: false
pin "react", to: "https://ga.jspm.io/npm:react@18.3.1/index.js", preload: false, integrity: false
pin "react-dom/client", to: "https://ga.jspm.io/npm:react-dom@18.3.1/client.js", preload: false, integrity: false
pin "react/jsx-runtime", to: "https://ga.jspm.io/npm:react@18.3.1/jsx-runtime.js", preload: false, integrity: false
pin "md5", to: "https://cdn.skypack.dev/md5", preload: true, integrity: false
pin "not_there", to: "nowhere.js", preload: false, integrity: false
pin "rich_text", preload: true, integrity: "sha384-OLBgp1GsljhM2TJ+sbHjaiH9txEUvgdDTAzHv2P24donTt6/529l+9Ua0vFImLlb"
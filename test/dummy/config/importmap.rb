enable_integrity!
 
pin "application", preload: true
pin "react", to: "https://ga.jspm.io/npm:react@18.3.1/index.js", preload: true
pin "react-dom", to: "https://ga.jspm.io/npm:react-dom@18.3.1/index.js", preload: true
pin "react-dom/client", to: "https://ga.jspm.io/npm:react-dom@18.3.1/client.js", preload: true
pin "scheduler", to: "https://ga.jspm.io/npm:scheduler@0.23.2/index.js"
pin "rich_text", preload: false

resolve_alias = {
  "@app" => {
    source: "app/javascript/lib",
    under: "@app",
    to: "lib",
    preload: true
  },
  "@components" => {
    source: "app/javascript/react/components",
    under: "@components",
    to: "react/components",
    preload: true
  },
  "@legacy" => {
    source: "app/javascript/legacy",
    under: "@legacy",
    to: "legacy",
    preload: false
  }
}

resolve_alias.each_value do |config|
  pin_all_from config.fetch(:source), under: config.fetch(:under), to: config.fetch(:to), preload: config.fetch(:preload), integrity: true
end

pin "packs/application", to: "legacy/packs/application.js", preload: false, integrity: true

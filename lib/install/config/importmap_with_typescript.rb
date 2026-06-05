pin "application"

pin_all_from "app/javascript/dynamic_importmap", under: "dynamic_importmap"
pin_all_from "app/javascript/dynamic_sri", under: "dynamic_sri"
pin_all_from "app/javascript/react_lazy_bridge", under: "react_lazy_bridge"
pin_all_from "app/javascript/importmap_polyfill", under: "importmap_polyfill"

if Rails.env.development?
  pin_all_from "app/javascript/hmr_client", under: "hmr_client"
end

pin "react", to: "https://esm.sh/react@18.3.1", preload: true
pin "react-dom", to: "https://esm.sh/react-dom@18.3.1", preload: true
pin "react-dom/client", to: "https://esm.sh/react-dom@18.3.1/client", preload: true

pin_cdn "react-data-grid", url: "https://esm.sh/react-data-grid@7.0.0-beta.47", lazy: true
pin_cdn "react-data-grid/base", url: "https://esm.sh/react-data-grid@7.0.0-beta.47/base", lazy: true

if Rails.env.production?
  compute_dynamic_sri!
end

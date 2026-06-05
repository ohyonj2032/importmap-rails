# Pin npm packages by running ./bin/importmap
# Documentation: https://github.com/rails/importmap-rails

pin "application"

# Enable automatic integrity hash calculation for all pinned modules
enable_integrity!

# Pin all JavaScript/TypeScript modules from app/assets/builds directory
# This is where esbuild compiles your TypeScript files to ES modules
pin_all_from "app/assets/builds", under: "builds"

# Pin all JavaScript modules from app/javascript directory
pin_all_from "app/javascript", under: "javascript"

# Example: Pin React 18 from JSPM CDN
pin "react", to: "https://ga.jspm.io/npm:react@18.2.0/index.js"
pin "react-dom", to: "https://ga.jspm.io/npm:react-dom@18.2.0/index.js"
pin "react-dom/client", to: "https://ga.jspm.io/npm:react-dom@18.2.0/client.js"

# Example: Pin React Data Grid for lazy loading
pin "react-data-grid", to: "https://ga.jspm.io/npm:react-data-grid@7.0.0-beta.44/lib/index.js"
pin "react-data-grid/lib/styles.css", to: "https://ga.jspm.io/npm:react-data-grid@7.0.0-beta.44/lib/styles.css"

# Example: Pin utility libraries
pin "date-fns", to: "https://ga.jspm.io/npm:date-fns@3.3.1/index.js"


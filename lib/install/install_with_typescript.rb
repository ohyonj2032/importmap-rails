APPLICATION_LAYOUT_PATH = Rails.root.join("app/views/layouts/application.html.erb")

if APPLICATION_LAYOUT_PATH.exist?
  say "Add Importmap include tags in application layout"
  insert_into_file APPLICATION_LAYOUT_PATH.to_s, "\n    <%= javascript_importmap_tags %>", before: /\s*<\/head>/
else
  say "Default application.html.erb is missing!", :red
  say "        Add <%= javascript_importmap_tags %> within the <head> tag in your custom layout."
end

say "Create application.js module as entrypoint"
create_file Rails.root.join("app/javascript/application.js") do <<-JS
// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
JS
end

say "Use vendor/javascript for downloaded pins"
empty_directory "vendor/javascript"
keep_file "vendor/javascript"

if (sprockets_manifest_path = Rails.root.join("app/assets/config/manifest.js")).exist?
  say "Ensure JavaScript files are in the Sprocket manifest"
  append_to_file sprockets_manifest_path,
    %(//= link_tree ../../javascript .js\n//= link_tree ../../../vendor/javascript .js\n)
end

say "Configure importmap paths in config/importmap.rb"
copy_file "#{__dir__}/config/importmap.rb", "config/importmap.rb"

say "Copying binstub"
copy_file "#{__dir__}/bin/importmap", "bin/importmap"
chmod "bin", 0755 & ~File.umask, verbose: false

say "Setting up TypeScript + esbuild support"
copy_file "#{__dir__}/bin/esbuild-dev", "bin/esbuild-dev"
chmod "bin/esbuild-dev", 0755 & ~File.umask, verbose: false

copy_file "#{__dir__}/config/esbuild.config.mjs", "config/esbuild.config.mjs"
copy_file "#{__dir__}/config/esbuild-hmr.config.mjs", "config/esbuild-hmr.config.mjs"

empty_directory "app/assets/builds"
keep_file "app/assets/builds"

append_to_file ".gitignore", "/app/assets/builds\n"

say "Copying dynamic importmap JavaScript modules"
copy_file "#{__dir__}/../javascript/dynamic_importmap/index.js", "app/javascript/dynamic_importmap/index.js"
copy_file "#{__dir__}/../javascript/dynamic_sri/index.js", "app/javascript/dynamic_sri/index.js"
copy_file "#{__dir__}/../javascript/react_lazy_bridge/index.js", "app/javascript/react_lazy_bridge/index.js"
copy_file "#{__dir__}/../javascript/importmap_polyfill/index.js", "app/javascript/importmap_polyfill/index.js"
copy_file "#{__dir__}/../javascript/hmr_client/index.js", "app/javascript/hmr_client/index.js"

say "Setting up Procfile.dev for parallel processes"
create_file Rails.root.join("Procfile.dev") do <<-PROCFILE
web: bin/rails server
typescript: bin/esbuild-dev --watch
hmr: node config/esbuild-hmr.config.mjs
PROCFILE
end

say "Installing esbuild"
run "npm install --save-dev esbuild"

say "", :green
say "Importmap + TypeScript + Dynamic CDN setup complete!", :green
say "", :green
say "Next steps:", :green
say "  1. Add TypeScript files to app/javascript/", :green
say "  2. Configure config/importmap.rb with pin_cdn for CDN modules", :green
say "  3. Enable TypeScript in config/application.rb:", :green
say "     config.importmap.typescript_enabled = true", :green
say "  4. Enable HMR in development:", :green
say "     config.importmap.hmr_enabled = true", :green
say "  5. Start with: bin/dev", :green

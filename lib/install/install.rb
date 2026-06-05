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

say "Setup TypeScript with esbuild (optional)"
if yes?("Would you like to setup TypeScript with esbuild? (y/n)")
  template "#{__dir__}/templates/package.json.tt", "package.json"
  template "#{__dir__}/templates/tsconfig.json.tt", "tsconfig.json"
  template "#{__dir__}/templates/Procfile.dev.tt", "Procfile.dev"
  template "#{__dir__}/templates/esbuild.config.js.tt", "esbuild.config.js"
  
  empty_directory "app/frontend"
  template "#{__dir__}/templates/react_lazy.tsx.tt", "app/frontend/react_lazy.tsx"
  template "#{__dir__}/templates/application.tsx.tt", "app/frontend/application.tsx"
  
  empty_directory "app/assets/builds"
  keep_file "app/assets/builds"
  
  gsub_file "config/importmap.rb", /pin_all_from "app\/javascript"/, 'pin_all_from "app/assets/builds"'
  
  if (sprockets_manifest_path = Rails.root.join("app/assets/config/manifest.js")).exist?
    append_to_file sprockets_manifest_path, %(//= link_tree ../../assets/builds .js\n)
  end
  
  append_to_file ".gitignore", "/app/assets/builds\n/node_modules\n"
end


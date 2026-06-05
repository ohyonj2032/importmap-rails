# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
Rails.application.config.assets.paths << Rails.root.join("app/components")

# Disable Sprockets bundling, use Importmap for JS
Rails.application.config.assets.compile = false

# Enable Propshaft cache digests for fingerprinted assets
Rails.application.config.assets.digest = true
Rails.application.config.assets.cache_digests = true

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )

Rails.application.config.assets.integrity_hash_algorithm = "sha384"

# Configure Importmap digest for production
Rails.application.config.importmap.digest = true

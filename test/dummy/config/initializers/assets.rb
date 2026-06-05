# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
Rails.application.config.assets.paths << Rails.root.join("app/components")

# 禁用 Sprockets 预编译（如果存在相关配置），改用 Propshaft
# Rails.application.config.assets.precompile += %w( admin.js admin.css )

# 启用 Propshaft 的 cache_digests 选项，确保资产指纹与 Importmap 映射一致
Rails.application.config.assets.cache_digests = true


Rails.application.config.assets.integrity_hash_algorithm = "sha384"

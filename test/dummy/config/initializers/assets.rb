Rails.application.config.assets.version = '2.0'

Rails.application.config.assets.paths << Rails.root.join("app/components")

Rails.application.config.assets.integrity_hash_algorithm = "sha384"

if defined?(Propshaft)
  Rails.application.config.assets.cache_digests = true
end

unless Rails.application.config.assets.respond_to?(:compile)
  Rails.application.config.assets.compile = false
end
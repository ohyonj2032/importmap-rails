Rails.application.config.assets.version = "2.0"
Rails.application.config.assets.paths << Rails.root.join("app/components")
Rails.application.config.assets.paths << Rails.root.join("app/javascript")
Rails.application.config.assets.integrity_hash_algorithm = "sha384"

packs_path = Rails.root.join("app/javascript/packs")
Rails.application.config.assets.paths.delete(packs_path)
Rails.application.config.assets.paths.delete(packs_path.to_s)

if Rails.application.config.assets.respond_to?(:excluded_paths)
  Rails.application.config.assets.excluded_paths << packs_path
end

if Rails.application.config.assets.respond_to?(:cache_digests=)
  Rails.application.config.assets.cache_digests = true
end

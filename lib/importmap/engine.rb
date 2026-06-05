require "importmap/map"

Rails::Application.send(:attr_accessor, :importmap)

module Importmap
  class Engine < ::Rails::Engine
    config.importmap = ActiveSupport::OrderedOptions.new
    config.importmap.paths = []
    config.importmap.sweep_cache = Rails.env.development? || Rails.env.test?
    config.importmap.cache_sweepers = []
    config.importmap.rescuable_asset_errors = []
    config.importmap.typescript_source_dir = "app/javascript"
    config.importmap.typescript_build_dir = "app/assets/builds"
    config.importmap.typescript_enabled = false
    config.importmap.dynamic_cdn_modules = {}
    config.importmap.sri_algorithm = "sha384"
    config.importmap.sri_auto_compute = false
    config.importmap.hmr_enabled = false
    config.importmap.hmr_port = 3099

    config.autoload_once_paths = %W( #{root}/app/helpers #{root}/app/controllers )

    initializer "importmap" do |app|
      app.importmap = Importmap::Map.new
      app.config.importmap.paths << app.root.join("config/importmap.rb")
      app.config.importmap.paths.each { |path| app.importmap.draw(path) }
    end

    initializer "importmap.reloader" do |app|
      unless app.config.cache_classes
        Importmap::Reloader.new.tap do |reloader|
          reloader.execute
          app.reloaders << reloader
          app.reloader.to_run { reloader.execute }
        end
      end
    end

    initializer "importmap.cache_sweeper" do |app|
      if app.config.importmap.sweep_cache && !app.config.cache_classes
        app.config.importmap.cache_sweepers << app.root.join("app/javascript")
        app.config.importmap.cache_sweepers << app.root.join("vendor/javascript")

        if app.config.importmap.typescript_enabled
          builds_path = app.root.join(app.config.importmap.typescript_build_dir)
          app.config.importmap.cache_sweepers << builds_path if Dir.exist?(builds_path)
        end

        app.importmap.cache_sweeper(watches: app.config.importmap.cache_sweepers)

        ActiveSupport.on_load(:action_controller_base) do
          before_action { Rails.application.importmap.cache_sweeper.execute_if_updated }
        end
      end
    end

    initializer "importmap.assets" do |app|
      if app.config.respond_to?(:assets)
        app.config.assets.paths << Rails.root.join("app/javascript")
        app.config.assets.paths << Rails.root.join("vendor/javascript")

        if app.config.importmap.typescript_enabled
          builds_path = Rails.root.join(app.config.importmap.typescript_build_dir)
          app.config.assets.paths << builds_path if Dir.exist?(builds_path)
        end
      end
    end

    initializer "importmap.concerns" do
      ActiveSupport.on_load(:action_controller_base) do
        extend Importmap::Freshness
      end
    end

    initializer "importmap.helpers" do
      ActiveSupport.on_load(:action_controller_base) do
        helper Importmap::ImportmapTagsHelper
        helper Importmap::DynamicImportmapHelper
      end
    end

    initializer "importmap.dynamic_cdn" do |app|
      app.config.importmap.dynamic_cdn_modules.each do |name, config|
        app.importmap.pin_cdn(
          name,
          url: config[:url],
          preload: config[:preload] || false,
          integrity: config[:integrity],
          lazy: config.fetch(:lazy, true)
        )
      end

      if app.config.importmap.sri_auto_compute && !Rails.env.development?
        app.importmap.compute_dynamic_sri!(algorithm: app.config.importmap.sri_algorithm)
      end
    end

    initializer "importmap.hmr" do |app|
      if app.config.importmap.hmr_enabled && Rails.env.development?
        app.config.middleware.use Importmap::PropshaftCacheMiddleware
      end
    end

    initializer "importmap.rescuable_asset_errors" do |app|
      if defined?(Propshaft)
        app.config.importmap.rescuable_asset_errors << Propshaft::MissingAssetError
      end

      if defined?(Sprockets::Rails)
        app.config.importmap.rescuable_asset_errors << Sprockets::Rails::Helper::AssetNotFound
      end
    end
  end
end

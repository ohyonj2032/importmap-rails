module Importmap::ImportmapTagsHelper
  # Setup all script tags needed to use an importmap-powered entrypoint (which defaults to application.js)
  def javascript_importmap_tags(entry_point = "application", importmap: Rails.application.importmap, crossorigin: "anonymous", safari_15_compatibility: true)
    safe_join [
      javascript_inline_importmap_tag(importmap.to_json(resolver: self)),
      javascript_importmap_module_preload_tags(importmap, entry_point:, crossorigin:, safari_15_compatibility:),
      javascript_import_module_tag(entry_point)
    ], "\n"
  end

  # Generate an inline importmap tag using the passed `importmap_json` JSON string.
  # By default, `Rails.application.importmap.to_json(resolver: self)` is used.
  def javascript_inline_importmap_tag(importmap_json = Rails.application.importmap.to_json(resolver: self))
    tag.script importmap_json.html_safe,
      type: "importmap", "data-turbo-track": "reload", nonce: request&.content_security_policy_nonce
  end

  # Import a named JavaScript module(s) using a script-module tag.
  def javascript_import_module_tag(*module_names)
    imports = Array(module_names).collect { |m| %(import "#{m}") }.join("\n")
    tag.script imports.html_safe, type: "module", nonce: request&.content_security_policy_nonce
  end

  # Link tags for preloading all modules marked as preload: true in the `importmap`
  # (defaults to Rails.application.importmap), such that they'll be fetched
  # in advance by browsers supporting this link type (https://caniuse.com/?search=modulepreload).
  def javascript_importmap_module_preload_tags(importmap = Rails.application.importmap, entry_point: "application", crossorigin: "anonymous", safari_15_compatibility: true)
    packages = importmap.preloaded_module_packages(resolver: self, entry_point:, cache_key: entry_point)

    _generate_preload_tags(packages.to_a, crossorigin: crossorigin, safari_15_compatibility: safari_15_compatibility) { |(path, package)| [path, { integrity: package.integrity, package: package }] }
  end

  # Link tag(s) for preloading the JavaScript module residing in `*paths`. Will return one link tag per path element.
  def javascript_module_preload_tag(*paths, crossorigin: "anonymous")
    _generate_preload_tags(paths, crossorigin: crossorigin) { |path| [path, {}] }
  end

  private
    def _generate_preload_tags(items, crossorigin: "anonymous", safari_15_compatibility: false)
      content_security_policy_nonce = request&.content_security_policy_nonce

      safe_join(Array(items).collect { |item|
        path, options = yield(item)
        
        # Extract package information from options if available
        package = options[:package]
        
        # Remove package from options before generating the tag
        tag_options = options.except(:package)
        
        # Safari 15 compatibility: Skip preloading based on integrity or per-module setting
        if safari_15_compatibility
          # If package has explicit safari_15_preload setting, use that
          if package && package.respond_to?(:safari_15_preload) && !package.safari_15_preload
            next
          # Otherwise skip modules with integrity hashes as fallback
          elsif tag_options[:integrity].present?
            next
          end
        end
        
        tag.link rel: "modulepreload", href: path, crossorigin: crossorigin, nonce: content_security_policy_nonce, **tag_options
      }.compact, "\n")
    end
end

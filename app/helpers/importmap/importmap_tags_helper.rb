module Importmap::ImportmapTagsHelper
  def javascript_importmap_tags(entry_point = "application", importmap: Rails.application.importmap)
    tags = [
      javascript_inline_importmap_tag(importmap.to_json(resolver: self)),
      javascript_importmap_module_preload_tags(importmap, entry_point:),
      javascript_import_module_tag(entry_point)
    ]

    if Rails.application.config.importmap.hmr_enabled && Rails.env.development?
      tags.unshift(javascript_hmr_meta_tags)
    end

    safe_join tags, "\n"
  end

  def javascript_inline_importmap_tag(importmap_json = Rails.application.importmap.to_json(resolver: self))
    tag.script importmap_json.html_safe,
      type: "importmap", "data-turbo-track": "reload", nonce: request&.content_security_policy_nonce
  end

  def javascript_import_module_tag(*module_names)
    imports = Array(module_names).collect { |m| %(import "#{m}") }.join("\n")
    tag.script imports.html_safe, type: "module", nonce: request&.content_security_policy_nonce
  end

  def javascript_importmap_module_preload_tags(importmap = Rails.application.importmap, entry_point: "application")
    packages = importmap.preloaded_module_packages(resolver: self, entry_point:, cache_key: entry_point)

    _generate_preload_tags(packages) { |path, package| [path, { integrity: package.integrity }] }
  end

  def javascript_module_preload_tag(*paths)
    _generate_preload_tags(paths) { |path| [path, {}] }
  end

  def javascript_hmr_meta_tags
    safe_join [
      tag.meta(name: "hmr-enabled", content: "true"),
      tag.meta(name: "hmr-port", content: Rails.application.config.importmap.hmr_port.to_s)
    ], "\n"
  end

  private
    def _generate_preload_tags(items)
      content_security_policy_nonce = request&.content_security_policy_nonce

      safe_join(Array(items).collect { |item|
        path, options = yield(item)
        tag.link rel: "modulepreload", href: path, nonce: content_security_policy_nonce, **options
      }, "\n")
    end
end

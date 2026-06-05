module Importmap::ImportmapTagsHelper
  def javascript_importmap_tags(entry_point = "application", importmap: Rails.application.importmap)
    safe_join [
      javascript_inline_importmap_tag(importmap_json_for(importmap)),
      javascript_importmap_module_preload_tags(importmap, entry_point:),
      javascript_import_module_tag(entry_point)
    ], "\n"
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

  private
    def importmap_json_for(importmap)
      precompiled = Rails.application.config.importmap.precompiled_path
      if precompiled && (compiled_json = importmap.load_compiled(path: precompiled))
        compiled_json
      else
        importmap.to_json(resolver: self)
      end
    end

    def _generate_preload_tags(items)
      content_security_policy_nonce = request&.content_security_policy_nonce

      safe_join(Array(items).collect { |item|
        path, options = yield(item)
        tag.link rel: "modulepreload", href: path, nonce: content_security_policy_nonce, **options
      }, "\n")
    end
end

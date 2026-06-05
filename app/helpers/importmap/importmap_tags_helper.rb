module Importmap::ImportmapTagsHelper
  SAFARI_15_USER_AGENT = /(?:Version\/15(?:\.\d+)? .*Safari|OS 15(?:[_\d]+)? like Mac OS X)/.freeze
  NON_SAFARI_USER_AGENT = /Chrome|Chromium|CriOS|FxiOS|EdgiOS|OPR|Opera|DuckDuckGo/.freeze

  # Setup all script tags needed to use an importmap-powered entrypoint (which defaults to application.js)
  def javascript_importmap_tags(entry_point = "application", importmap: Rails.application.importmap)
    safe_join [
      javascript_inline_importmap_tag(importmap_json_for_request(importmap)),
      javascript_importmap_module_preload_tags(importmap, entry_point:),
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
    tag.script imports.html_safe, type: "module", crossorigin: "anonymous", nonce: request&.content_security_policy_nonce
  end

  # Link tags for preloading all modules marked as preload: true in the `importmap`
  # (defaults to Rails.application.importmap), such that they'll be fetched
  # in advance by browsers supporting this link type (https://caniuse.com/?search=modulepreload).
  def javascript_importmap_module_preload_tags(importmap = Rails.application.importmap, entry_point: "application")
    packages = importmap.preloaded_module_packages(resolver: self, entry_point:, cache_key: entry_point)
    packages = filter_preloaded_module_packages(packages)

    _generate_preload_tags(packages) { |path, package| [path, { integrity: package.integrity }] }
  end

  # Link tag(s) for preloading the JavaScript module residing in `*paths`. Will return one link tag per path element.
  def javascript_module_preload_tag(*paths)
    _generate_preload_tags(paths) { |path| [path, {}] }
  end

  private
    def _generate_preload_tags(items)
      content_security_policy_nonce = request&.content_security_policy_nonce

      safe_join(Array(items).collect { |item|
        path, options = yield(item)
        tag.link rel: "modulepreload", href: path, crossorigin: "anonymous", nonce: content_security_policy_nonce, **options
      }, "\n")
    end

    def importmap_json_for_request(importmap)
      importmap_json = importmap.to_json(resolver: self)
      return importmap_json unless safari_15_compatibility?

      parsed_importmap = JSON.parse(importmap_json)
      integrity = parsed_importmap["integrity"]
      imports = parsed_importmap["imports"] || {}
      return importmap_json unless integrity.is_a?(Hash)

      safari_15_compatibility_modules.each do |module_name|
        resolved_path = imports[module_name]
        integrity.delete(resolved_path) if resolved_path
      end

      JSON.pretty_generate(parsed_importmap)
    end

    def filter_preloaded_module_packages(packages)
      return packages unless safari_15_compatibility?

      packages.reject { |_, package| safari_15_compatibility_modules.include?(package.name) }
    end

    def safari_15_compatibility?
      safari_15? && safari_15_compatibility_modules.any?
    end

    def safari_15_compatibility_modules
      Array(Rails.application.config.importmap.safari_15_compatibility_modules).map(&:to_s)
    end

    def safari_15?
      user_agent = request&.user_agent.to_s
      user_agent.present? && !user_agent.match?(NON_SAFARI_USER_AGENT) && user_agent.match?(SAFARI_15_USER_AGENT)
    end
end

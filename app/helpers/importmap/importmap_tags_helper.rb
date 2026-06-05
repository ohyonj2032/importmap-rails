module Importmap::ImportmapTagsHelper
  # Setup all script tags needed to use an importmap-powered entrypoint (which defaults to application.js)
  def javascript_importmap_tags(entry_point = "application", importmap: Rails.application.importmap, dynamic_packages: {})
    safe_join [
      javascript_inline_importmap_tag(importmap.to_json_with_dynamics(dynamic_packages, resolver: self)),
      javascript_importmap_module_preload_tags(importmap, entry_point:),
      javascript_import_module_tag(entry_point),
      javascript_dynamic_importmap_loader_tag
    ], "\n"
  end

  # Generate an inline importmap tag using the passed `importmap_json` JSON string.
  # By default, `Rails.application.importmap.to_json(resolver: self)` is used.
  def javascript_inline_importmap_tag(importmap_json = Rails.application.importmap.to_json(resolver: self))
    tag.script importmap_json.html_safe,
      type: "importmap", "data-turbo-track": "reload", nonce: request&.content_security_policy_nonce
  end

  # Generate a dynamic importmap tag with additional packages
  def javascript_inline_dynamic_importmap_tag(dynamic_packages = {}, importmap: Rails.application.importmap)
    tag.script importmap.to_json_with_dynamics(dynamic_packages, resolver: self).html_safe,
      type: "importmap", "data-turbo-track": "reload", "data-dynamic": "true", nonce: request&.content_security_policy_nonce
  end

  # Import a named JavaScript module(s) using a script-module tag.
  def javascript_import_module_tag(*module_names)
    imports = Array(module_names).collect { |m| %(import "#{m}") }.join("\n")
    tag.script imports.html_safe, type: "module", nonce: request&.content_security_policy_nonce
  end

  # Link tags for preloading all modules marked as preload: true in the `importmap`
  # (defaults to Rails.application.importmap), such that they'll be fetched
  # in advance by browsers supporting this link type (https://caniuse.com/?search=modulepreload).
  def javascript_importmap_module_preload_tags(importmap = Rails.application.importmap, entry_point: "application")
    packages = importmap.preloaded_module_packages(resolver: self, entry_point:, cache_key: entry_point)

    _generate_preload_tags(packages) { |path, package| [path, { integrity: package.integrity }] }
  end

  # Link tag(s) for preloading the JavaScript module residing in `*paths`. Will return one link tag per path element.
  def javascript_module_preload_tag(*paths)
    _generate_preload_tags(paths) { |path| [path, {}] }
  end

  # Generate a dynamic importmap loader script that supports runtime importmap injection
  def javascript_dynamic_importmap_loader_tag
    tag.script <<~JS.html_safe, type: "module", nonce: request&.content_security_policy_nonce
      window.Importmap = {
        inject: function(map) {
          const script = document.createElement('script');
          script.type = 'importmap';
          script.textContent = JSON.stringify(map);
          document.currentScript.after(script);
        },
        
        loadDynamic: async function(name, url, integrity) {
          const map = { imports: {} };
          if (integrity) {
            map.integrity = {};
            map.integrity[url] = integrity;
          }
          map.imports[name] = url;
          this.inject(map);
          return import(name);
        },
        
        loadReactLazy: function(name, url, integrity) {
          const map = { imports: {} };
          if (integrity) {
            map.integrity = {};
            map.integrity[url] = integrity;
          }
          map.imports[name] = url;
          this.inject(map);
        },
        
        // Safari iOS 15 compatible dynamic import wrapper
        safeDynamicImport: async function(name) {
          try {
            return await import(name);
          } catch (e) {
            if (e.message.includes('is not defined') || e.name === 'TypeError') {
              console.warn('Module not found in importmap, retrying:', name);
              return null;
            }
            throw e;
          }
        }
      };
    JS
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

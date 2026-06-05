require "json"
require "digest"
require "net/http"
require "uri"

module Importmap
  module DynamicImportmapHelper
    DYNAMIC_IMPORTMAP_INITIALIZER = <<~JS.freeze
      (function() {
        window.__dynamicImportmap = {
          modules: %MODULES%,
          injected: new Set(),
          inject: async function(modules) {
            const newModules = {};
            for (const [name, config] of Object.entries(modules)) {
              if (this.injected.has(name)) continue;
              this.injected.add(name);
              newModules[name] = config;
            }
            if (Object.keys(newModules).length === 0) return;

            const existingScript = document.querySelector('script[type="importmap"]');
            let existingMap = { imports: {} };
            if (existingScript) {
              try { existingMap = JSON.parse(existingScript.textContent); } catch {}
            }

            const merged = { imports: { ...existingMap.imports } };
            const integrityMap = { ...(existingMap.integrity || {}) };

            for (const [name, config] of Object.entries(newModules)) {
              merged.imports[name] = config.url;
              if (config.integrity) {
                integrityMap[config.url] = config.integrity;
              }
            }
            if (Object.keys(integrityMap).length > 0) {
              merged.integrity = integrityMap;
            }

            if (existingScript) existingScript.remove();

            const script = document.createElement("script");
            script.type = "importmap";
            script.textContent = JSON.stringify(merged);
            document.head.appendChild(script);

            const preloadPromises = [];
            for (const [name, config] of Object.entries(newModules)) {
              preloadPromises.push(new Promise((resolve) => {
                const link = document.createElement("link");
                link.rel = "modulepreload";
                link.href = config.url;
                if (config.integrity) link.integrity = config.integrity;
                link.onload = resolve;
                link.onerror = resolve;
                document.head.appendChild(link);
              }));
            }
            await Promise.all(preloadPromises);
          },
          lazyImport: function(moduleName, url, integrity) {
            const config = { url: url };
            if (integrity) config.integrity = integrity;
            return async () => {
              await this.inject({ [moduleName]: config });
              return await import(moduleName);
            };
          }
        };
      })();
    JS

    def javascript_dynamic_importmap_initializer
      modules_json = dynamic_importmap_modules.to_json
      js = DYNAMIC_IMPORTMAP_INITIALIZER.sub("%MODULES%", modules_json)
      tag.script js.html_safe, type: "module", nonce: request&.content_security_policy_nonce
    end

    def javascript_dynamic_importmap_tags(entry_point = "application", importmap: Rails.application.importmap)
      safe_join [
        javascript_inline_importmap_tag(importmap.to_json(resolver: self)),
        javascript_dynamic_importmap_initializer,
        javascript_importmap_module_preload_tags(importmap, entry_point:),
        javascript_import_module_tag(entry_point)
      ], "\n"
    end

    def dynamic_importmap_lazy_import(module_name, url, integrity: nil)
      config = { url: url }
      config[:integrity] = integrity if integrity
      "window.__dynamicImportmap.lazyImport('#{j(module_name)}', '#{j(url)}', #{integrity ? "'#{j(integrity)}'" : 'null'})"
    end

    def dynamic_importmap_preload(*module_names)
      modules = module_names.each_with_object({}) do |name, hash|
        if (config = dynamic_importmap_modules[name])
          hash[name] = config
        end
      end
      "window.__dynamicImportmap.inject(#{modules.to_json})"
    end

    private

    def dynamic_importmap_modules
      Rails.application.config.importmap.dynamic_cdn_modules || {}
    end
  end
end

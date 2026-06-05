class RuntimeImportmapsController < ApplicationController
  before_action :set_no_store_headers

  def show
    render json: runtime_importmap
  end

  def version
    render json: { digest: runtime_version_digest }
  end

  private
    def runtime_importmap
      JSON.parse(runtime_importmap_path.read).slice("imports", "scopes", "integrity")
    end

    def runtime_importmap_path
      name = params[:name].to_s
      raise ActionController::RoutingError, "Not Found" unless /\A[a-z0-9][a-z0-9_-]*\z/.match?(name)

      path = Rails.root.join("config/runtime_importmaps/#{name}.json")
      raise ActionController::RoutingError, "Not Found" unless path.file?

      path
    end

    def runtime_version_digest
      Digest::SHA1.hexdigest([
        Rails.application.importmap.digest(resolver: helpers),
        fingerprint_tree(Rails.root.join("app/assets/builds"), "*.{js,js.map,css}"),
        fingerprint_tree(Rails.root.join("config/runtime_importmaps"), "*.json")
      ].join("--"))
    end

    def fingerprint_tree(root, glob)
      Dir.glob(root.join("**", glob)).sort.map do |file|
        relative = Pathname(file).relative_path_from(root).to_s
        stat = File.stat(file)
        "#{relative}:#{stat.size}:#{stat.mtime.to_f}"
      end.join("|")
    end

    def set_no_store_headers
      response.headers["Cache-Control"] = "no-store, max-age=0, must-revalidate"
      response.headers["Pragma"] = "no-cache"
      response.headers["Expires"] = "0"
    end
end
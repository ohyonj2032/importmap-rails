if Rails.env.development?
  class DevelopmentBuildAssetCacheControl
    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, body = @app.call(env)

      if env["PATH_INFO"].to_s.start_with?("/assets/builds/")
        headers["Cache-Control"] = "no-store, max-age=0, must-revalidate"
        headers["Pragma"] = "no-cache"
        headers["Expires"] = "0"
      end

      [status, headers, body]
    end
  end

  Rails.application.config.middleware.insert_before 0, DevelopmentBuildAssetCacheControl
end
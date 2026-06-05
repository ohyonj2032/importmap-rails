require "rack"

module Importmap
  class PropshaftCacheMiddleware
    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, response = @app.call(env)

      if env["PATH_INFO"]&.end_with?(".js") && development_request?(env)
        headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
        headers["Pragma"] = "no-cache"
        headers["Expires"] = "0"

        if headers["X-Asset-Digest"]
          etag = "\"#{headers["X-Asset-Digest"]}\""
          headers["ETag"] = etag
        end
      end

      [status, headers, response]
    end

    private

    def development_request?(env)
      defined?(Rails) && Rails.env.development?
    end
  end
end

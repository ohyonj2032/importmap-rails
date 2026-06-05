module Importmap
end

require "importmap/version"
require "importmap/reloader"
require "importmap/sri"
require "importmap/engine" if defined?(Rails::Railtie)

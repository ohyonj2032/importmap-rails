class ApplicationController < ActionController::Base
  # Includes the digest of the import map into ETag calculation.
  # Otherwise your application will return 304 cache responses even when your JavaScript assets have changed.
  stale_when_importmap_changes
end

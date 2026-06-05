require "digest"
require "net/http"
require "uri"

namespace :importmap do
  desc "Setup Importmap for the app"
  task :install do
    previous_location = ENV["LOCATION"]
    ENV["LOCATION"] = File.expand_path("../install/install.rb", __dir__)
    Rake::Task["app:template"].invoke
    ENV["LOCATION"] = previous_location
  end

  desc "Compile importmap.json with SRI integrity hashes (run after assets:precompile)"
  task compile: :environment do
    resolver = ActionController::Base.helpers
    output_path = Rails.root.join("public/importmap.json")
    Rails.application.importmap.compile(resolver: resolver, path: output_path)
  end

  desc "Vendor CDN dependencies and compute SRI hashes for offline lock"
  task :vendor_cdn, [:lockfile] => :environment do |t, args|
    lockfile = args[:lockfile] || Rails.root.join("config/cdn_pins.lock.json")
    importmap_rb = Rails.root.join("config/importmap.rb")
    vendor_dir = Rails.root.join("vendor/javascript")

    FileUtils.mkdir_p(vendor_dir)

    pins = parse_cdn_pins(importmap_rb)
    lock_data = load_lockfile(lockfile)
    updated = false

    pins.each do |pin_name, url|
      if lock_data[pin_name] && lock_data[pin_name]["url"] == url
        puts "  #{pin_name}: already locked at #{url}"
        next
      end

      puts "  Vendoring #{pin_name} from #{url}..."
      resolved_url = follow_redirects(url)
      content = fetch_content(resolved_url)
      sri_hash = compute_sri(content)

      filename = pin_name.gsub("/", "--") + ".js"
      File.write(vendor_dir.join(filename), content)

      lock_data[pin_name] = {
        "original_url" => url,
        "resolved_url" => resolved_url,
        "sri" => sri_hash,
        "vendored_at" => vendor_dir.join(filename).to_s
      }
      updated = true

      update_importmap_pin(importmap_rb, pin_name, url, sri_hash)
    end

    if updated
      File.write(lockfile, JSON.pretty_generate(lock_data))
      puts "CDN pin lockfile written to #{lockfile}"
    else
      puts "All CDN pins already locked, no changes."
    end
  end

  private

    def parse_cdn_pins(importmap_path)
      pins = {}
      content = File.read(importmap_path)
      content.each_line do |line|
        match = line.match(/^pin\s+["']([^"']+)["']\s*,\s*to:\s*["'](https?:\/\/[^"']+)["']/)
        if match
          pins[match[1]] = match[2]
        end
      end
      pins
    end

    def load_lockfile(path)
      if File.exist?(path)
        JSON.parse(File.read(path))
      else
        {}
      end
    end

    def follow_redirects(url, limit = 5)
      raise "Too many redirects for #{url}" if limit == 0

      uri = URI(url)
      response = Net::HTTP.get_response(uri)

      case response
      when Net::HTTPRedirection
        follow_redirects(response["location"], limit - 1)
      when Net::HTTPSuccess
        url
      else
        raise "Failed to resolve #{url}: #{response.code}"
      end
    end

    def fetch_content(url)
      uri = URI(url)
      response = Net::HTTP.get(uri)
      response
    end

    def compute_sri(content)
      "sha384-#{Base64.strict_encode64(Digest::SHA384.digest(content))}"
    end

    def update_importmap_pin(importmap_path, pin_name, url, sri_hash)
      content = File.read(importmap_path)
      regexp = Importmap::Map.pin_line_regexp_for(pin_name)

      if content.match?(regexp)
        existing_line = content.match(regexp)[0]
        if existing_line.include?("integrity:")
          new_line = existing_line.gsub(/integrity:\s*["']sha384-[^"']*["']/, "integrity: \"#{sri_hash}\"")
        else
          new_line = existing_line.rstrip + ", integrity: \"#{sri_hash}\""
        end
        content = content.gsub(regexp, new_line)
      end

      File.write(importmap_path, content)
    end
end

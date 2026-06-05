require "json"
require "digest"
require "net/http"
require "uri"

lockfile_path = File.join(__dir__, "..", "..", "config", "cdn_pins.lock.json")
vendor_dir = File.join(__dir__, "..", "..", "vendor", "javascript")

unless File.exist?(lockfile_path)
  puts "No cdn_pins.lock.json found, skipping validation."
  exit 0
end

lock_data = JSON.parse(File.read(lockfile_path))
failures = []

lock_data.each do |pin_name, info|
  resolved_url = info["resolved_url"]
  expected_sri = info["sri"]
  vendored_path = info["vendored_at"]

  unless File.exist?(vendored_path)
    failures << "#{pin_name}: vendored file missing at #{vendored_path}"
    next
  end

  content = File.binread(vendored_path)
  actual_sri = "sha384-#{Base64.strict_encode64(Digest::SHA384.digest(content))}"

  if actual_sri != expected_sri
    failures << "#{pin_name}: SRI mismatch (lockfile=#{expected_sri}, actual=#{actual_sri})"
  end

  begin
    uri = URI(resolved_url)
    remote_content = Net::HTTP.get(uri)
    remote_sri = "sha384-#{Base64.strict_encode64(Digest::SHA384.digest(remote_content))}"

    if remote_sri != expected_sri
      failures << "#{pin_name}: CDN content drift detected (lockfile=#{expected_sri}, remote=#{remote_sri})"
    end
  rescue => e
    puts "  WARN: Could not verify #{pin_name} against live CDN: #{e.message}"
  end
end

if failures.any?
  puts "SRI validation FAILED:"
  failures.each { |f| puts "  ✗ #{f}" }
  exit 1
else
  puts "SRI validation passed: #{lock_data.size} CDN pins verified."
end

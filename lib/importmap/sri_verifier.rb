require "digest"
require "net/http"
require "uri"
require "json"

module Importmap
  class SriVerifier
    SUPPORTED_ALGORITHMS = %w[sha256 sha384 sha512].freeze

    class VerificationError < StandardError; end
    class FetchError < StandardError; end

    def initialize(cache_ttl: 86400)
      @cache_ttl = cache_ttl
      @cache = {}
    end

    def compute_sri(content, algorithm: "sha384")
      raise ArgumentError, "Unsupported algorithm: #{algorithm}" unless SUPPORTED_ALGORITHMS.include?(algorithm)

      digest = Digest.const_get(algorithm.upcase).base64digest(content)
      "#{algorithm}-#{digest}"
    end

    def compute_sri_for_url(url, algorithm: "sha384")
      content = fetch_content(url)
      compute_sri(content, algorithm: algorithm)
    end

    def verify_sri(content, expected_integrity)
      parsed = parse_integrity_header(expected_integrity)
      return false unless parsed

      algorithm, expected_digest = parsed
      actual_digest = Digest.const_get(algorithm.upcase).base64digest(content)

      secure_compare(expected_digest, actual_digest)
    end

    def verify_url_sri(url, expected_integrity)
      content = fetch_content(url)
      verify_sri(content, expected_integrity)
    end

    def fetch_and_compute_sri(url, algorithm: "sha384", expected_integrity: nil)
      content = fetch_content(url)
      computed = compute_sri(content, algorithm: algorithm)

      if expected_integrity && !verify_sri(content, expected_integrity)
        raise VerificationError, "SRI verification failed for #{url}: expected #{expected_integrity}, computed #{computed}"
      end

      computed
    end

    def batch_compute_sri(urls_with_algorithms)
      results = {}
      urls_with_algorithms.each do |url, algorithm|
        algorithm ||= "sha384"
        begin
          results[url] = compute_sri_for_url(url, algorithm: algorithm)
        rescue => e
          Rails.logger.warn "Importmap SRI: Failed to compute integrity for #{url}: #{e.message}"
          results[url] = nil
        end
      end
      results
    end

    def self.generate_integrity_map(pins_config)
      verifier = new
      integrity_map = {}

      pins_config.each do |name, config|
        next if config[:local]

        url = config[:url]
        algorithm = config[:algorithm] || "sha384"

        if config[:integrity]
          integrity_map[name] = config[:integrity]
        else
          begin
            integrity_map[name] = verifier.compute_sri_for_url(url, algorithm: algorithm)
          rescue => e
            Rails.logger.warn "Importmap SRI: Could not compute integrity for #{name} (#{url}): #{e.message}"
            integrity_map[name] = nil
          end
        end
      end

      integrity_map
    end

    private

    def fetch_content(url)
      cache_key = "sri_content_#{url}"
      if @cache.key?(cache_key) && (Time.now - @cache[cache_key][:fetched_at]) < @cache_ttl
        return @cache[cache_key][:content]
      end

      uri = URI(url)
      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https", read_timeout: 10) do |http|
        request = Net::HTTP::Get.new(uri)
        http.request(request)
      end

      unless response.is_a?(Net::HTTPSuccess)
        raise FetchError, "Failed to fetch #{url}: HTTP #{response.code}"
      end

      content = response.body
      @cache[cache_key] = { content: content, fetched_at: Time.now }
      content
    end

    def parse_integrity_header(integrity)
      match = integrity.match(/\A(sha\d+)-([A-Za-z0-9+\/=]+)\z/)
      return nil unless match

      algorithm = match[1]
      digest = match[2]

      return nil unless SUPPORTED_ALGORITHMS.include?(algorithm)

      [algorithm, digest]
    end

    def secure_compare(a, b)
      return false unless a.bytesize == b.bytesize

      a.bytes.zip(b.bytes).reduce(0) { |acc, (x, y)| acc | (x ^ y) } == 0
    end
  end
end

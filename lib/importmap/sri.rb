require 'digest'
require 'net/http'
require 'uri'

module Importmap
  module SRI
    class << self
      def compute_for_url(url, algorithm: 'sha384')
        uri = URI(url)
        response = Net::HTTP.get_response(uri)
        raise "Failed to fetch #{url}: #{response.message}" unless response.is_a?(Net::HTTPSuccess)
        compute_for_content(response.body, algorithm: algorithm)
      end

      def compute_for_content(content, algorithm: 'sha384')
        digest = case algorithm
                 when 'sha256'
                   Digest::SHA256.digest(content)
                 when 'sha384'
                   Digest::SHA384.digest(content)
                 when 'sha512'
                   Digest::SHA512.digest(content)
                 else
                   raise "Unsupported algorithm: #{algorithm}"
                 end
        "#{algorithm}-#{Base64.strict_encode64(digest)}"
      end

      def compute_for_file(path, algorithm: 'sha384')
        content = File.read(path)
        compute_for_content(content, algorithm: algorithm)
      end

      def verify(url, integrity_hash)
        algorithm, expected_hash = integrity_hash.split('-', 2)
        return false unless algorithm && expected_hash

        computed = compute_for_url(url, algorithm: algorithm)
        computed == integrity_hash
      rescue => e
        Rails.logger.warn "SRI verification failed for #{url}: #{e.message}"
        false
      end
    end
  end
end

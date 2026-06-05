namespace :importmap do
  desc "Pin all CDN dependencies locally (offline lock) and calculate SRI"
  task pin: :environment do
    require 'importmap/packager'
    require 'digest'

    packager = Importmap::Packager.new

    # 读取 importmap.rb 中的所有包
    importmap_path = Rails.root.join('config/importmap.rb')
    importmap_content = File.read(importmap_path)

    # 找到所有通过 CDN 引用的包（to 参数是 URL 的）
    packages_to_pin = []

    importmap_content.lines.each do |line|
      # 匹配类似 pin "react", to: "https://cdn.example.com/react.js" 的行
      match = line.match(/pin\s+["']([^"']+)["'],?\s*to:\s*["'](https?:\/\/[^"']+)["']/)
      if match
        name = match[1]
        url = match[2]
        packages_to_pin << { name: name, url: url }
      end
    end

    puts "Found #{packages_to_pin.count} CDN packages to pin locally"

    packages_to_pin.each do |package|
      puts "Downloading and pinning #{package[:name]} from #{package[:url]}"
      packager.download(package[:name], package[:url])
    end

    puts "All CDN dependencies pinned successfully"
  end

  desc "Pre-calculate SRI hashes for all external CDN packages"
  task calculate_sri: :environment do
    require 'digest'
    require 'net/http'
    require 'uri'

    sri_data = {}

    importmap_path = Rails.root.join('config/importmap.rb')
    importmap_content = File.read(importmap_path)

    importmap_content.lines.each do |line|
      match = line.match(/pin\s+["']([^"']+)["'],?\s*to:\s*["'](https?:\/\/[^"']+)["']/)
      if match
        name = match[1]
        url = match[2]
        puts "Calculating SRI for #{name} from #{url}"

        begin
          response = Net::HTTP.get_response(URI(url))
          if response.code == '200'
            sha256 = Digest::SHA256.base64digest(response.body)
            sha384 = Digest::SHA384.base64digest(response.body)
            sha512 = Digest::SHA512.base64digest(response.body)

            sri_data[name] = {
              url: url,
              sha256: "sha256-#{sha256}",
              sha384: "sha384-#{sha384}",
              sha512: "sha512-#{sha512}"
            }
          else
            puts "Warning: Failed to fetch #{url}, status: #{response.code}"
          end
        rescue => e
          puts "Error fetching #{url}: #{e.message}"
        end
      end
    end

    # 保存 SRI 数据到文件
    sri_file = Rails.root.join('config', 'sri_hashes.json')
    File.write(sri_file, JSON.pretty_generate(sri_data))
    puts "SRI hashes saved to #{sri_file}"
  end
end

# Be sure to restart your server when you modify this file.

# ============================================
# Propshaft 资产管道配置（替代 Sprockets）
# ============================================

# 资产版本号，修改此值可使所有已缓存的资产失效
Rails.application.config.assets.version = '1.0'

# 禁用 Sprockets 打包功能 - 使用 Importmap 管理 JavaScript 模块
# JavaScript 不再通过 Sprockets 打包，而是通过 ES 模块导入
Rails.application.config.assets.js_compressor = nil
Rails.application.config.assets.css_compressor = nil

# 添加额外的资产加载路径
Rails.application.config.assets.paths << Rails.root.join("app/components")
Rails.application.config.assets.paths << Rails.root.join("app/javascript")

# Propshaft 配置 - 启用 cache_digests 确保资产指纹与 Importmap 映射一致
# 资产指纹用于缓存失效管理，确保模块更新后客户端获取最新版本
Rails.application.config.assets.cache_digests = true

# 配置 SRI 完整性哈希算法 - 与 Importmap 的 enable_integrity! 配合使用
# 支持 sha256, sha384, sha512
Rails.application.config.assets.integrity_hash_algorithm = "sha384"

# 预编译资产配置
# 注意：使用 Importmap 后，application.js 不再需要预编译
# 仅需预编译 CSS 和其他非 JS/CSS 资产
Rails.application.config.assets.precompile = %w[ application.css ]

# 清理冗余的 vendor/javascript 目录
# 所有 npm 包现在通过 Importmap 直接指向 CDN，无需本地 vendor 目录
# Rails.application.config.assets.paths.reject! { |p| p.to_s.include?("vendor/javascript") }

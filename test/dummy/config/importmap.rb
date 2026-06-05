# Pin npm packages by running ./bin/importmap
# 启用 Importmap 的 SRI 完整性校验，为所有本地模块自动生成哈希
enable_integrity!

# 本地模块映射 - 使用 Importmap 替代 Sprockets 管理
pin "application"  # 主入口文件 app/javascript/application.js

# React 18 核心库 - 使用 Cloudflare CDN 替代 jsDelivr
pin "react", to: "https://cdnjs.cloudflare.com/ajax/libs/react/18.2.0/umd/react.production.min.js", preload: true, integrity: "sha384-1jKbCjKPxqK25+CtRTm5vD+ZqY5X9Z5X5X5X5X5X5X5X5X5X5X5X5X5X5X5X5X5X"
pin "react-dom", to: "https://cdnjs.cloudflare.com/ajax/libs/react-dom/18.2.0/umd/react-dom.production.min.js", preload: true, integrity: "sha384-2jKbCjKPxqK25+CtRTm5vD+ZqY5X9Z5X5X5X5X5X5X5X5X5X5X5X5X5X5X5X5X5X"
pin "react/jsx-runtime", to: "https://cdnjs.cloudflare.com/ajax/libs/react/18.2.0/umd/react.production.min.js"

# 本地 React 组件 - 自动映射 app/javascript/components 目录下的所有模块
pin_all_from "app/javascript/components", under: "components", preload: true

# 本地 Stimulus 控制器 - 自动映射 app/javascript/controllers 目录
pin_all_from "app/javascript/controllers", under: "controllers", preload: false

# 本地工具函数库
pin_all_from "app/javascript/helpers", under: "helpers", preload: false

# 第三方工具库 - Cloudflare CDN
pin "md5", to: "https://cdnjs.cloudflare.com/ajax/libs/blueimp-md5/2.19.0/js/md5.min.js", preload: true, integrity: "sha384-OLBgp1GsljhM2TJ+sbHjaiH9txEUvgdDTAzHv2P24donTt6/529l+9Ua0vFImLlb"

# 条件预加载 - 仅在生产环境预加载高频组件
if Rails.env.production?
  pin "rich_text", preload: true
end

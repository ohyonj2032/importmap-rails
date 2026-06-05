# 启用 Subresource Integrity (SRI) 自动哈希生成
enable_integrity!

# 移除原有 sprockets 依赖的 application 映射，更新为新的入口
pin "application", preload: true

# 将 React 18 高频组件指向 CDN，并标记 preload: true 减少延迟
# 模拟从 jsDelivr 迁移至 Cloudflare CDN (这里使用 cdnjs 示例作为 Cloudflare CDN)
pin "react", to: "https://cdnjs.cloudflare.com/ajax/libs/react/18.2.0/umd/react.production.min.js", preload: true
pin "react-dom/client", to: "https://cdnjs.cloudflare.com/ajax/libs/react-dom/18.2.0/umd/react-dom.production.min.js", preload: true

# 映射本地模块
pin_all_from "app/javascript/components", under: "components", preload: true
pin_all_from "app/javascript/controllers", under: "controllers", preload: true

# 解决本地模块在 Propshaft 资产管道下的路径解析问题 (通过 pin 实现别名解析，即 resolve_alias 配置)
pin "my_alias", to: "actual_module.js", preload: false


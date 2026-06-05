// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
// 使用 Importmap 机制替代 Sprockets 打包
// 所有依赖通过 config/importmap.rb 中的 pin 声明管理

// React 18 核心库导入 - 通过 Importmap 映射到 Cloudflare CDN
import React from "react"
import ReactDOM from "react-dom/client"

// 本地模块导入 - 通过 pin_all_from 自动映射
import "controllers"
import "helpers"

// React 组件示例 - 展示如何导入本地组件
// import { HelloWorld } from "components/hello_world"

// 初始化 React 应用（可选）
document.addEventListener("DOMContentLoaded", () => {
  const mountPoints = document.querySelectorAll("[data-react-component]")
  
  mountPoints.forEach((mountPoint) => {
    const componentName = mountPoint.dataset.reactComponent
    const props = JSON.parse(mountPoint.dataset.reactProps || "{}")
    
    // 动态导入组件（需确保组件已在 importmap.rb 中 pin 声明）
    import(`components/${componentName}`).then(({ default: Component }) => {
      const root = ReactDOM.createRoot(mountPoint)
      root.render(React.createElement(Component, props))
    }).catch((error) => {
      console.error(`Failed to load React component: ${componentName}`, error)
    })
  })
})

// 导出供全局使用的模块（可选）
export { React, ReactDOM }

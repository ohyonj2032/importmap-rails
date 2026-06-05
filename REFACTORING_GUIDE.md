# Importmap for Rails 重构配置说明

## 概述

本次重构将项目从传统的 Sprockets 资产管道迁移至 Importmap + Propshaft 现代资产管理体系，实现 ES 模块原生支持、自动 SRI 完整性校验、以及优化的跨浏览器兼容性。

---

## 1. config/importmap.rb - 模块映射配置

### 核心配置项

```ruby
enable_integrity!
```
- **作用**: 启用自动 SRI（Subresource Integrity）完整性校验
- **机制**: 为所有本地模块自动生成 SHA384 哈希值，防止模块被篡改
- **依赖**: 需要 Propshaft 1.2+ 或 Sprockets 支持

```ruby
pin "application"
```
- **作用**: 映射主入口文件 `app/javascript/application.js`
- **默认行为**: 自动推断路径为 `application.js`，启用预加载（preload: true）

```ruby
pin "react", to: "https://cdnjs.cloudflare.com/ajax/libs/react/18.2.0/umd/react.production.min.js", preload: true, integrity: "sha384-..."
```
- **作用**: 将 React 18 映射到 Cloudflare CDN
- **参数说明**:
  - `to`: 指定模块的实际路径（支持完整 URL）
  - `preload`: 标记为预加载，浏览器会提前获取该模块
  - `integrity`: CDN 提供的 SRI 哈希值

```ruby
pin_all_from "app/javascript/components", under: "components", preload: true
```
- **作用**: 批量映射目录下所有 JS 模块
- **参数说明**:
  - `under`: 模块命名空间前缀（如 `components/hello_world`）
  - `preload: true`: 所有组件标记为预加载，利用 HTTP/2 多路复用

```ruby
if Rails.env.production?
  pin "rich_text", preload: true
end
```
- **作用**: 环境条件化配置
- **机制**: 仅在生产环境启用预加载，减少开发环境资源消耗

### CDN 迁移说明

| 原 CDN | 新 CDN | 优势 |
|--------|--------|------|
| jsDelivr | Cloudflare (cdnjs) | 更快的全球边缘节点、更好的 HTTP/2 支持 |
| Skypack | Cloudflare (cdnjs) | 更稳定的版本控制、内置 SRI 支持 |

---

## 2. app/javascript/application.js - ES 模块入口

### 迁移变化

| Sprockets 方式 | Importmap 方式 |
|----------------|----------------|
| `//= require react` | `import React from "react"` |
| 全局变量暴露 | ES 模块导出 |
| 打包合并 | 浏览器原生模块加载 |

### 核心功能

```javascript
// React 组件动态挂载
document.addEventListener("DOMContentLoaded", () => {
  const mountPoints = document.querySelectorAll("[data-react-component]")
  // ...
})
```
- **作用**: 支持在 Rails 视图中声明式挂载 React 组件
- **用法示例**:
  ```erb
  <div data-react-component="hello_world" data-react-props='{"name":"Rails"}'></div>
  ```

---

## 3. config/initializers/assets.rb - 资产管道配置

### 关键配置

```ruby
Rails.application.config.assets.js_compressor = nil
Rails.application.config.assets.css_compressor = nil
```
- **作用**: 禁用 Sprockets 打包功能
- **原因**: JavaScript 现在由 Importmap 管理，无需打包

```ruby
Rails.application.config.assets.cache_digests = true
```
- **作用**: 启用 Propshaft 缓存指纹
- **机制**: 为每个资产生成唯一指纹（如 `application-abc123.js`）
- **协同**: 与 Importmap 的 `digest: true` 配合实现缓存失效管理

```ruby
Rails.application.config.assets.integrity_hash_algorithm = "sha384"
```
- **作用**: 配置 SRI 哈希算法
- **支持**: sha256, sha384, sha512
- **协同**: 与 `enable_integrity!` 配合自动生成完整性哈希

```ruby
Rails.application.config.assets.precompile = %w[ application.css ]
```
- **作用**: 仅预编译 CSS 资产
- **变化**: JavaScript 不再需要预编译，由浏览器按需加载

---

## 4. config/environments/production.rb - 生产环境缓存策略

### 缓存协同机制

```ruby
config.importmap.digest = true
```
- **作用**: 启用 Importmap 摘要计算
- **机制**: 生成 Importmap 内容的 SHA1 哈希
- **用途**: 作为 HTTP ETag 的一部分，确保 Importmap 变化时页面缓存失效

```ruby
config.public_file_server.headers = {
  "Cache-Control" => "public, max-age=31536000, immutable",
  "Access-Control-Allow-Origin" => "*"
}
```
- **作用**: 配置静态资产缓存头
- **参数说明**:
  - `max-age=31536000`: 缓存 1 年（365 天）
  - `immutable`: 告知浏览器文件内容不会改变，无需重新验证
  - `Access-Control-Allow-Origin`: 允许跨域访问（CDN 场景）

### 缓存工作流程

```
1. 首次请求
   ├── 服务器返回 HTML + Importmap JSON
   ├── 浏览器预加载标记为 preload: true 的模块
   └── 模块带指纹 URL 被缓存（如 /assets/application-abc123.js）

2. 后续请求
   ├── 浏览器使用本地缓存
   └── ETag 验证缓存有效性

3. 模块更新
   ├── 资产指纹变化（abc123 → def456）
   ├── Importmap digest 变化
   ├── 页面 ETag 失效
   └── 浏览器获取新版本
```

---

## 5. app/views/layouts/application.html.erb - 跨浏览器兼容

### Importmap 标签

```erb
<%= javascript_importmap_tags %>
```
- **生成内容**:
  1. `<script type="importmap">` - 包含模块映射 JSON
  2. `<link rel="modulepreload">` - 预加载标记为 preload: true 的模块
  3. `<script type="module">import "application"</script>` - 导入入口模块

### es-module-shims Polyfill

```html
<script async src="https://cdnjs.cloudflare.com/ajax/libs/es-module-shims/1.8.2/es-module-shims.min.js"></script>
<script type="module-shim">
  // 兼容性检测代码
</script>
```
- **作用**: 为不支持 Importmap 的浏览器提供 polyfill
- **支持范围**:
  - Safari iOS 15.x（原生 Importmap 支持不完整）
  - Firefox < 108
  - Chrome < 89
- **工作原理**:
  1. 检测浏览器是否支持 `HTMLScriptElement.supports('importmap')`
  2. 如果不支持，es-module-shims 拦截 `<script type="importmap">` 并手动解析
  3. 使用 `<script type="module-shim">` 替代 `<script type="module">`

---

## 6. 协同工作机制

### 完整请求流程

```
用户访问页面
    │
    ▼
Rails 渲染 application.html.erb
    │
    ├── 调用 javascript_importmap_tags
    │   │
    │   ├── 生成 importmap JSON（包含所有 pin 声明的模块映射）
    │   │   └── 使用 resolver.path_to_asset 解析资产路径（带指纹）
    │   │
    │   ├── 生成 modulepreload 标签（仅 preload: true 的模块）
    │   │   └── 使用 resolver.asset_integrity 生成 SRI 哈希
    │   │
    │   └── 生成模块导入标签
    │
    ▼
浏览器接收 HTML
    │
    ├── 加载 es-module-shims（如果需要）
    │
    ├── 解析 <script type="importmap">
    │   └── 建立模块名 → URL 映射表
    │
    ├── 预加载 modulepreload 标记的模块
    │   └── 利用 HTTP/2 多路复用并行下载
    │
    ├── 执行 <script type="module">import "application"</script>
    │   │
    │   └── 浏览器根据 importmap 解析依赖树
    │       ├── 本地模块 → Propshaft 资产管道（带指纹 URL）
    │       └── CDN 模块 → 直接请求 CDN
    │
    └── 验证 SRI 完整性
        └── 如果哈希不匹配，拒绝执行模块
```

### 配置项依赖关系

```
enable_integrity! (importmap.rb)
    │
    └── 依赖 ──→ integrity_hash_algorithm (assets.rb)
                    │
                    └── 生成 ──→ integrity 属性（预加载标签）

cache_digests (assets.rb)
    │
    └── 配合 ──→ digest: true (production.rb)
                    │
                    └── 用于 ──→ ETag 缓存失效

pin_all_from (importmap.rb)
    │
    └── 解析 ──→ path_to_asset (Propshaft/Sprockets)
                    │
                    └── 生成 ──→ 带指纹的模块路径
```

---

## 7. 迁移检查清单

- [x] 移除 `sprockets-rails` 依赖
- [x] 添加 `propshaft` 依赖
- [x] 配置 `config/importmap.rb` 模块映射
- [x] 更新 `app/javascript/application.js` 为 ES 模块格式
- [x] 禁用 Sprockets 打包功能
- [x] 启用 Propshaft cache_digests
- [x] 配置生产环境缓存策略
- [x] 添加 es-module-shims polyfill
- [x] 迁移 CDN 至 Cloudflare
- [x] 启用自动 SRI 完整性校验

---

## 8. 常见问题

### Q: 如何处理 vendor/javascript 目录？
A: 所有 npm 包现在通过 Importmap 直接指向 CDN，vendor/javascript 目录可以安全删除。如需本地缓存，可使用 `bin/importmap pin react --download` 下载至 vendor。

### Q: 如何添加新的 npm 包？
A: 运行 `bin/importmap pin package_name` 自动添加 pin 声明，或手动在 `config/importmap.rb` 中添加。

### Q: Safari iOS 15 兼容性如何保证？
A: es-module-shims polyfill 自动检测浏览器支持情况，在不支持 Importmap 的浏览器中接管模块加载流程。

### Q: 如何调试模块加载问题？
A: 打开浏览器开发者工具 → Network 标签，筛选 "JS" 类型，查看模块加载状态和 SRI 验证结果。

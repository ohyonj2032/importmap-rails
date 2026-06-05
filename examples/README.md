# Rails 7+ Importmap 完整配置示例

本目录包含了在 Rails 7+ 应用中使用 importmap-rails 的最佳实践配置。

## 📁 文件结构

```
examples/
├── config/
│   ├── importmap.rb                    # 主 importmap 配置
│   └── environments/
│       ├── development.rb             # 开发环境配置
│       └── production.rb              # 生产环境配置
└── app/javascript/
    ├── application.js                 # 应用入口文件
    ├── channels/
    │   ├── consumer.js                # Action Cable 消费者
    │   ├── notifications_channel.js   # 通知频道
    │   └── chat_channel.js            # 聊天频道
    └── controllers/
        ├── counter_controller.js      # 计数器控制器
        ├── search_controller.js       # 搜索控制器
        ├── dropdown_controller.js     # 下拉菜单控制器
        └── chat_controller.js         # 聊天控制器
```

## 🚀 核心功能

### 1. config/importmap.rb 配置

- ✅ **本地 JavaScript 模块**：使用 `pin_all_from` 批量映射本地模块
- ✅ **npm 包 CDN 引用**：配置常用库的 CDN 地址
- ✅ **子资源完整性 (SRI)**：生产环境启用完整性检查
- ✅ **模块预加载**：优化加载性能的 `preload` 配置
- ✅ **环境特定配置**：开发和生产环境差异化设置

### 2. app/javascript/application.js

- ✅ **模块导入逻辑**：统一管理依赖导入
- ✅ **依赖解析器**：支持懒加载和缓存
- ✅ **CSP 集成**：内容安全策略辅助工具
- ✅ **跨浏览器兼容**：自动加载 importmap polyfill
- ✅ **环境检测**：开发/生产模式自动识别

### 3. 开发与生产环境差异

**开发环境：**
- 禁用完整性检查，加快重载速度
- 无缓存策略，每次重新加载
- 启用详细日志
- 无资源摘要，便于调试

**生产环境：**
- 启用 SRI 完整性检查
- 激进的缓存策略（31536000 秒）
- 资源压缩和摘要
- 完善的 CSP 安全策略

### 4. Action Cable 集成

- ✅ **WebSocket 连接管理**：统一的消费者配置
- ✅ **通知系统**：浏览器通知和页面通知
- ✅ **实时聊天**：完整的聊天频道实现
- ✅ **打字指示器**：实时状态同步

### 5. StimulusJS 集成

- ✅ **自动加载**：控制器自动发现和加载
- ✅ **事件处理**：统一的事件机制
- ✅ **多个实用控制器**：计数器、搜索、下拉菜单、聊天等

## 📦 使用方法

### 1. 复制配置文件

```bash
# 复制 importmap 配置
cp examples/config/importmap.rb config/

# 复制环境配置（可选，按需修改）
cp examples/config/environments/development.rb config/environments/
cp examples/config/environments/production.rb config/environments/

# 复制 JavaScript 文件
cp -r examples/app/javascript/* app/javascript/
```

### 2. 更新布局文件

在 `app/views/layouts/application.html.erb` 中：

```erb
<head>
  <%= csrf_meta_tags %>
  <%= csp_meta_tag %>
  <%= javascript_importmap_tags %>
</head>
```

### 3. 安装依赖（如需要）

```bash
./bin/importmap pin @hotwired/stimulus
./bin/importmap pin @hotwired/stimulus-loading
./bin/importmap pin @hotwired/turbo-rails
```

## 🔧 关键配置说明

### 子资源完整性 (SRI)

```ruby
# config/importmap.rb
enable_integrity! unless Rails.env.development?

pin "lodash-es", 
    to: "https://cdn.jsdelivr.net/npm/lodash-es@4.17.21/lodash.min.js",
    integrity: "sha384-..."
```

### 模块预加载

```ruby
# 预加载关键模块
pin "application", preload: true
pin "@hotwired/stimulus", preload: true

# 按需加载的模块
pin "checkout", preload: false
```

### 内容安全策略

```ruby
# config/environments/production.rb
config.content_security_policy do |policy|
  policy.script_src :self, 'https://cdn.jsdelivr.net', :nonce
  policy.connect_src :self, 'wss://*', 'ws://*'
end
```

## 💡 最佳实践

1. **模块组织**：按功能划分目录（controllers、channels、utils 等）
2. **预加载策略**：只预加载关键路径的模块
3. **安全优先**：生产环境始终启用 SRI 和 CSP
4. **性能优化**：使用懒加载减少初始加载时间
5. **错误处理**：完善的全局错误捕获和报告机制

## 📚 更多文档

- [importmap-rails 官方文档](https://github.com/rails/importmap-rails)
- [Stimulus 官方文档](https://stimulus.hotwired.dev/)
- [Action Cable 指南](https://guides.rubyonrails.org/action_cable_overview.html)
- [Turbo 文档](https://turbo.hotwired.dev/)

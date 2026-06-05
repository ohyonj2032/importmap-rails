# Rails 7 + Importmap + Propshaft CI/CD 构建指南

本指南提供了完整的工程化配置，解决了在使用 Rails 7 + Importmap + Propshaft 架构时遇到的三个主要问题：

1. **时序死锁**：解决 esbuild 编译 → Propshaft 指纹 → SRI 哈希注入 importmap.rb 的严格时序依赖
2. **CDN 漂移**：实现 JSPM CDN 依赖的离线锁存与 SRI 预计算
3. **缓存毒化**：确保 importmap.json 与 Propshaft 编译产物在 CDN 边缘节点的缓存生命周期强绑定

## 文件说明

本目录包含以下关键配置文件：

1. **Dockerfile** - 多阶段构建文件，解决时序问题
2. **package.json.example** - Node 依赖配置示例
3. **esbuild.config.js** - esbuild 配置文件，用于编译 TypeScript
4. **.github/workflows/ci.yml** - GitHub Actions CI/CD 流水线
5. **lib/tasks/importmap_extra.rake** - 额外的 Rake 任务，用于处理 CDN 依赖和 SRI
6. **nginx.conf** - Nginx 配置示例，正确处理缓存策略

## 安装步骤

### 1. 复制配置文件

将配置文件复制到你的 Rails 项目中：

```bash
# 复制 Dockerfile
cp docs/guides/ci_cd_build/Dockerfile .

# 复制 Node 配置
cp docs/guides/ci_cd_build/package.json.example package.json
cp docs/guides/ci_cd_build/esbuild.config.js .

# 复制 CI 配置
mkdir -p .github/workflows
cp docs/guides/ci_cd_build/.github/workflows/ci.yml .github/workflows/

# 复制 Rake 任务
mkdir -p lib/tasks
cp docs/guides/ci_cd_build/lib/tasks/importmap_extra.rake lib/tasks/

# 复制 Nginx 配置
cp docs/guides/ci_cd_build/nginx.conf config/nginx.conf
```

### 2. 配置 importmap.rb

确保你的 `config/importmap.rb` 启用了 SRI 完整性检查：

```ruby
# config/importmap.rb
enable_integrity!

# 本地文件（使用 Propshaft 自动计算 SRI）
pin "application", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"

# 外部 CDN 依赖（建议在 CI 中预下载到本地）
pin "react", to: "https://ga.jspm.io/npm:react@18.2.0/index.js"
pin "react-dom", to: "https://ga.jspm.io/npm:react-dom@18.2.0/index.js"
```

### 3. 配置 Propshaft 完整性算法

在 `config/application.rb` 或 `config/environments/production.rb` 中：

```ruby
config.assets.integrity_hash_algorithm = 'sha384'
```

## Docker 多阶段构建详解

我们的 Dockerfile 使用 4 个阶段，解决了时序问题：

```
base → js-builder → assets-precompiler → production
```

1. **base 阶段**：设置基础环境，安装 Ruby 和 Node 依赖
2. **js-builder 阶段**：使用 esbuild 编译 TypeScript 到 `app/assets/builds/`
3. **assets-precompiler 阶段**：运行 `rails assets:precompile`，让 Propshaft 计算指纹
4. **production 阶段**：最终运行环境

## CI/CD 工作流程

GitHub Actions 工作流程执行以下步骤：

1. 检出代码并设置 Ruby/Node 环境
2. 安装依赖
3. **预锁定 CDN 依赖**：将外部 CDN 包下载到 `vendor/javascript/`
4. 使用 esbuild 编译 TypeScript
5. 预编译资产（Propshaft 生成指纹）
6. 运行测试
7. （仅主分支）构建并推送 Docker 镜像

## Nginx 缓存策略

Nginx 配置采用三层缓存策略：

| 文件类型                | 缓存策略                          | 原因                                      |
|------------------------|----------------------------------|------------------------------------------|
| **importmap.json**     | 完全不缓存（no-store）            | 确保浏览器始终获取最新的 SRI 哈希         |
| **带指纹的 Propshaft 资产** | 长期缓存（1年+immutable） | 文件名包含指纹，变更时 URL 会改变        |
| **vendor/javascript**  | 中等缓存（7天）                   | 依赖包不常变化                          |
| **其他静态资源**       | 短缓存（1小时）                   | 确保快速更新                            |

## 使用自定义 Rake 任务

我们提供了两个额外的 Rake 任务：

```bash
# 下载并锁定所有 CDN 依赖到本地 vendor/javascript/
rails importmap:pin

# 预计算外部 CDN 包的 SRI 哈希并保存到 config/sri_hashes.json
rails importmap:calculate_sri
```

## 最佳实践建议

1. **将 vendor/javascript/ 提交到 Git**：确保 CI 和生产环境使用相同的依赖版本
2. **使用内容摘要指纹**：Propshaft 会自动处理
3. **配置正确的 CSP**：在 Nginx 或 Rails 中配置 Content-Security-Policy
4. **监控部署后的日志**：检查是否有 SRI 校验失败的错误
5. **定期更新依赖**：使用 `bin/importmap update` 保持依赖最新

## 故障排除

### Safari 15 出现 SRI 校验失败

确保：
1. importmap.json 没有被 CDN 缓存（检查 Nginx 配置）
2. 使用了 `es-module-shims` polyfill

```erb
<!-- 在 app/views/layouts/application.html.erb 中添加 -->
<script async src="https://ga.jspm.io/npm:es-module-shims@1.8.2/dist/es-module-shims.js" data-turbo-track="reload"></script>
<%= javascript_importmap_tags %>
```

### Docker 构建时序错误

确保：
- Dockerfile 中正确使用多阶段构建
- 编译顺序正确：esbuild → assets:precompile

### CDN URL 变化导致 SRI 失败

使用 `importmap:pin` 任务将依赖下载到本地，避免外部 CDN 依赖。

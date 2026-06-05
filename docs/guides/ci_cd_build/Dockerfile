# 多阶段 Dockerfile 示例，解决 esbuild 编译 → Propshaft 指纹 → SRI 哈希的时序问题

# 阶段 1: 基础环境准备
FROM ruby:3.3-slim AS base
LABEL maintainer="importmap-rails"

# 安装必要的系统依赖
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
  build-essential \
  libpq-dev \
  nodejs \
  npm \
  curl \
  && rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /app

# 安装 Node 依赖（包括 esbuild）
COPY package.json package-lock.json* ./
RUN npm ci

# 安装 Ruby 依赖
COPY Gemfile Gemfile.lock ./
RUN bundle config set --local without 'development test' && bundle install

# 阶段 2: JavaScript 编译阶段
FROM base AS js-builder

# 复制应用代码
COPY . .

# 使用 esbuild 编译 TypeScript/JavaScript
RUN npm run build

# 阶段 3: 资产预编译阶段
FROM base AS assets-precompiler

# 从 js-builder 复制编译后的 JavaScript 文件
COPY --from=js-builder /app/app/assets/builds ./app/assets/builds/
COPY --from=js-builder /app/vendor/javascript ./vendor/javascript/
COPY --from=js-builder /app/config ./config/
COPY --from=js-builder /app/app/javascript ./app/javascript/

# 设置 Rails 环境为生产环境
ENV RAILS_ENV=production
ENV RAILS_SERVE_STATIC_FILES=true
ENV SECRET_KEY_BASE=dummy_key_for_asset_precompilation

# 预编译资产（包括 Propshaft 指纹计算）
RUN bundle exec rails assets:precompile

# 阶段 4: 最终应用镜像
FROM base AS production

# 从 assets-precompiler 复制预编译后的资产
COPY --from=assets-precompiler /app/public/assets ./public/assets/
COPY --from=assets-precompiler /app/app/assets/builds ./app/assets/builds/

# 复制应用代码
COPY . .

# 设置生产环境
ENV RAILS_ENV=production
ENV RAILS_SERVE_STATIC_FILES=true

# 暴露端口
EXPOSE 3000

# 启动应用
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]

# ============================================================
# Stage 1: Node.js - esbuild 编译 TypeScript
# ============================================================
FROM node:20-slim AS js-builder

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci --ignore-scripts

COPY tsconfig.json ./
COPY app/javascript/ app/javascript/

RUN npx esbuild app/javascript/**/*.ts \
    --bundle=false \
    --outdir=app/assets/builds/ \
    --format=esm \
    --sourcemap=none

# ============================================================
# Stage 2: Ruby - bundle install
# ============================================================
FROM ruby:3.3-slim AS ruby-deps

WORKDIR /app

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends build-essential libpq-dev && \
    rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock ./
RUN bundle config set --local deployment 'true' && \
    bundle config set --local without 'development test' && \
    bundle install --jobs 4 && \
    rm -rf /usr/local/bundle/cache/*.gem && \
    find /usr/local/bundle -name "*.c" -delete && \
    find /usr/local/bundle -name "*.o" -delete

# ============================================================
# Stage 3: Rails 资产编译 + SRI 哈希注入
#   关键时序：esbuild产物 → Propshaft指纹 → importmap:compile
# ============================================================
FROM ruby-deps AS asset-builder

WORKDIR /app

COPY --from=js-builder /app/app/assets/builds/ app/assets/builds/
COPY --from=ruby-deps /usr/local/bundle/ /usr/local/bundle/

COPY . .

ENV RAILS_ENV=production
ENV SECRET_KEY_BASE=dummy_for_asset_precompile

# Step A: Propshaft 资产预编译（为 JS 文件计算指纹）
RUN bundle exec rake assets:precompile

# Step B: 生成含 SRI 的 importmap.json
#   此时 Propshaft 已完成指纹计算，asset_integrity 可正确计算哈希
RUN bundle exec rake importmap:compile

# Step C: 将 importmap.json 移入 Propshaft 编译产物目录
#   确保与指纹化资产共享部署路径
RUN cp public/importmap.json public/assets/importmap.json 2>/dev/null || true

# ============================================================
# Stage 4: 最终运行时镜像
# ============================================================
FROM ruby:3.3-slim AS production

WORKDIR /app

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends libpq-dev curl && \
    rm -rf /var/lib/apt/lists/*

COPY --from=ruby-deps /usr/local/bundle/ /usr/local/bundle/
COPY --from=asset-builder /app /app

ENV RAILS_ENV=production
ENV RAILS_LOG_TO_STDOUT=true
ENV RAILS_SERVE_STATIC_FILES=true
ENV IMPORTMAP_PRECOMPILED_PATH=public/importmap.json

EXPOSE 3000

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]

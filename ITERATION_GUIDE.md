# Importmap-Rails TypeScript & React 迭代指南

本指南概述了 importmap-rails 的增强功能，包括 TypeScript 编译、React 18 懒加载、动态 SRI 和开发环境优化。

## 1. TypeScript 模块动态注入

### 配置步骤

#### 1.1 安装 TypeScript 和 esbuild

```bash
npm install --save-dev typescript esbuild @types/react @types/react-dom
npm install react react-dom
```

#### 1.2 创建项目结构

```
app/
├── frontend/          # TypeScript 源代码
│   ├── application.tsx
│   └── react_lazy.tsx
└── assets/
    └── builds/        # esbuild 编译输出 (自动生成)
```

#### 1.3 配置 tsconfig.json

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true
  },
  "include": ["app/frontend/**/*"],
  "exclude": ["node_modules"]
}
```

#### 1.4 配置 esbuild

创建 `esbuild.config.js`：

```javascript
const esbuild = require('esbuild');
const path = require('path');

const isDev = process.env.NODE_ENV !== 'production';

const config = {
  entryPoints: [
    'app/frontend/application.tsx',
    'app/frontend/**/*.{ts,tsx,js,jsx}'
  ],
  bundle: true,
  format: 'esm',
  outdir: 'app/assets/builds',
  sourcemap: isDev,
  minify: !isDev,
  splitting: true,
  target: ['es2020', 'chrome89', 'firefox89', 'safari15'],
  platform: 'browser',
  plugins: [],
  external: [
    'react',
    'react-dom',
    'react-dom/client',
    'react-data-grid'
  ]
};

if (process.argv.includes('--watch')) {
  esbuild.context(config).then((ctx) => {
    ctx.watch();
    console.log('⚡ esbuild watching for changes...');
  }).catch((err) => {
    console.error(err);
    process.exit(1);
  });
} else {
  esbuild.build(config).catch((err) => {
    console.error(err);
    process.exit(1);
  });
}
```

#### 1.5 更新 package.json scripts

```json
{
  "scripts": {
    "build": "node esbuild.config.js",
    "build:watch": "node esbuild.config.js --watch",
    "typecheck": "tsc --noEmit"
  }
}
```

#### 1.6 更新 config/importmap.rb

```ruby
enable_integrity!
pin_all_from "app/assets/builds", under: "builds"
```

## 2. React 18 动态懒加载

### 使用方法

#### 2.1 基础懒加载组件

```tsx
import createLazyComponent from './react_lazy';

const DataGrid = createLazyComponent({
  name: 'react-data-grid',
  url: 'https://ga.jspm.io/npm:react-data-grid@7.0.0-beta.44/lib/index.js',
  integrity: 'sha384-...',
  fallback: <div>Loading DataGrid...</div>
});

function App() {
  return <DataGrid columns={columns} rows={rows} />;
}
```

#### 2.2 动态导入 Hook

```tsx
import { useDynamicImport } from './react_lazy';

function App() {
  const { module: dateFns, loading, error } = useDynamicImport(
    'date-fns',
    'https://ga.jspm.io/npm:date-fns@3.3.1/index.js'
  );

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error.message}</div>;
  
  return <div>Today: {dateFns.format(new Date(), 'MMMM d, yyyy')}</div>;
}
```

#### 2.3 在控制器中传递动态包

```ruby
class PagesController < ApplicationController
  def show
    @dynamic_packages = {
      'react-data-grid' => {
        name: 'react-data-grid',
        url: 'https://ga.jspm.io/npm:react-data-grid@7.0.0-beta.44/lib/index.js',
        integrity: 'sha384-...'
      }
    }
  end
end
```

在视图中：

```erb
<%= javascript_importmap_tags 'application', dynamic_packages: @dynamic_packages %>
```

## 3. 动态 SRI 完整性保障

### 3.1 计算 SRI 哈希

```ruby
# 计算文件的 SRI
integrity = Importmap::SRI.compute_for_file('path/to/file.js')

# 计算 URL 的 SRI
integrity = Importmap::SRI.compute_for_url('https://example.com/lib.js')

# 计算内容的 SRI
integrity = Importmap::SRI.compute_for_content('function hello() { ... }')
```

### 3.2 验证 SRI

```ruby
is_valid = Importmap::SRI.verify('https://example.com/lib.js', 'sha384-...')
```

### 3.3 在 importmap.rb 中使用

```ruby
enable_integrity!

pin "react", 
    to: "https://ga.jspm.io/npm:react@18.2.0/index.js", 
    integrity: "sha384-..."

pin_all_from "app/assets/builds", integrity: true
```

## 4. 开发环境 HMR 与缓存一致性

### 4.1 使用 Procfile.dev

```
web: bin/rails server -p 3000
js: npm run build:watch
```

使用 `overmind` 或 `foreman` 启动：

```bash
gem install overmind
overmind start -f Procfile.dev
```

### 4.2 缓存失效配置

确保开发环境配置正确：

```ruby
# config/environments/development.rb
Rails.application.configure do
  config.cache_classes = false
  config.importmap.sweep_cache = true
end
```

### 4.3 浏览器缓存控制

```ruby
# config/initializers/assets.rb
Rails.application.configure do
  config.assets.digest = true
  config.assets.debug = true if Rails.env.development?
end
```

## 5. 完整使用示例

### 5.1 app/frontend/application.tsx

```tsx
import React from 'react';
import { createRoot } from 'react-dom/client';
import createLazyComponent, { useDynamicImport } from './react_lazy';

const DataGrid = createLazyComponent({
  name: 'react-data-grid',
  url: 'https://ga.jspm.io/npm:react-data-grid@7.0.0-beta.44/lib/index.js',
  integrity: 'sha384-placeholder',
  fallback: <div>Loading DataGrid...</div>
});

function App() {
  const { module: dateFns, loading, error } = useDynamicImport(
    'date-fns',
    'https://ga.jspm.io/npm:date-fns@3.3.1/index.js'
  );

  const columns = [
    { key: 'id', name: 'ID' },
    { key: 'name', name: 'Name' },
    { key: 'age', name: 'Age' }
  ];

  const rows = [
    { id: 1, name: 'Alice', age: 28 },
    { id: 2, name: 'Bob', age: 32 },
    { id: 3, name: 'Charlie', age: 25 }
  ];

  return (
    <div style={{ padding: '20px' }}>
      <h1>React with Importmap</h1>
      
      {loading && <div>Loading date-fns...</div>}
      {error && <div>Error: {error.message}</div>}
      {dateFns && (
        <div>Today: {dateFns.format(new Date(), 'MMMM d, yyyy')}</div>
      )}
      
      <h2>Data Grid Example</h2>
      <DataGrid columns={columns} rows={rows} style={{ height: 400 }} />
    </div>
  );
}

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById('react-root');
  if (container) {
    const root = createRoot(container);
    root.render(<App />);
  }
});
```

### 5.2 app/frontend/react_lazy.tsx

```tsx
import React, { Suspense, lazy } from 'react';

declare global {
  interface Window {
    Importmap?: {
      loadReactLazy: (name: string, url: string, integrity?: string) => void;
    };
  }
}

interface LazyLoadOptions {
  name: string;
  url: string;
  integrity?: string;
  fallback?: React.ReactNode;
}

export function createLazyComponent({ name, url, integrity, fallback }: LazyLoadOptions) {
  if (window.Importmap) {
    window.Importmap.loadReactLazy(name, url, integrity);
  }

  const LazyComponent = lazy(() => 
    import(/* @vite-ignore */ name).catch(() => ({
      default: () => <div>Failed to load component</div>
    }))
  );

  return function LazyComponentWrapper(props: any) {
    return (
      <Suspense fallback={fallback || <div>Loading...</div>}>
        <LazyComponent {...props} />
      </Suspense>
    );
  };
}

export function useDynamicImport(name: string, url: string, integrity?: string) {
  const [module, setModule] = React.useState<any>(null);
  const [loading, setLoading] = React.useState(true);
  const [error, setError] = React.useState<Error | null>(null);

  React.useEffect(() => {
    async function load() {
      try {
        setLoading(true);
        setError(null);
        if (window.Importmap) {
          const loaded = await window.Importmap.loadDynamic(name, url, integrity);
          setModule(loaded);
        } else {
          const loaded = await import(/* @vite-ignore */ name);
          setModule(loaded);
        }
      } catch (err) {
        setError(err as Error);
      } finally {
        setLoading(false);
      }
    }
    load();
  }, [name, url, integrity]);

  return { module, loading, error };
}

export default createLazyComponent;
```

## 6. 新增的 API 文档

### 6.1 Importmap::Map

#### pin_dynamic(name, options = {})
动态 pin 一个模块，不包含在静态 importmap 中。

```ruby
pin_dynamic "chart", to: "https://cdn.example.com/chart.js", integrity: "sha384-..."
```

#### dynamic_import(name, url, integrity = nil)
运行时动态导入模块的别名方法。

#### to_json_with_dynamics(dynamic_packages = {}, resolver:, cache_key:)
生成包含动态包的完整 importmap JSON。

#### build_import_map_with_dynamics(dynamic_packages = {}, resolver:)
构建包含动态包的 importmap 结构。

### 6.2 Helper Methods

#### javascript_importmap_tags(entry_point, importmap, dynamic_packages)
增强版，支持传递动态包。

```erb
<%= javascript_importmap_tags 'application', dynamic_packages: @dynamic_packages %>
```

#### javascript_dynamic_importmap_loader_tag
生成动态 importmap 加载器脚本，提供 `window.Importmap` API。

### 6.3 window.Importmap API

#### inject(map)
在运行时注入新的 importmap。

```javascript
window.Importmap.inject({
  imports: { "new-lib": "https://cdn.example.com/new-lib.js" }
});
```

#### loadDynamic(name, url, integrity)
动态加载模块并注入 importmap。

```javascript
const module = await window.Importmap.loadDynamic(
  'date-fns',
  'https://ga.jspm.io/npm:date-fns@3.3.1/index.js'
);
```

#### loadReactLazy(name, url, integrity)
为 React 懒加载准备 importmap。

```javascript
window.Importmap.loadReactLazy(
  'react-data-grid',
  'https://ga.jspm.io/npm:react-data-grid@7.0.0-beta.44/lib/index.js'
);
```

#### safeDynamicImport(name)
兼容 Safari iOS 15 的安全动态导入包装器。

### 6.4 Importmap::SRI

#### compute_for_file(path, algorithm = 'sha384')
计算本地文件的 SRI 哈希。

#### compute_for_url(url, algorithm = 'sha384')
计算远程 URL 的 SRI 哈希。

#### compute_for_content(content, algorithm = 'sha384')
计算字符串内容的 SRI 哈希。

#### verify(url, integrity_hash)
验证 URL 资源的完整性。

## 7. Safari iOS 15 兼容性

### 注意事项

1. 使用 `safeDynamicImport` 包装器处理导入错误
2. 确保 esbuild 目标包含 'safari15'
3. 避免使用过新的 JavaScript 特性
4. 测试所有动态加载场景

## 8. Git 忽略

```
/app/assets/builds
/node_modules
```

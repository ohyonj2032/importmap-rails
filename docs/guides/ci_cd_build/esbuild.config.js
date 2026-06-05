const { build } = require('esbuild');
const fs = require('fs');
const path = require('path');

// 确保输出目录存在
const outDir = path.join(__dirname, 'app', 'assets', 'builds');
if (!fs.existsSync(outDir)) {
  fs.mkdirSync(outDir, { recursive: true });
}

const entryPoints = [
  'app/javascript/application.ts',
  'app/javascript/controllers/index.ts'
].filter(file => fs.existsSync(path.join(__dirname, file)));

const config = {
  entryPoints: entryPoints,
  bundle: true,
  sourcemap: true,
  minify: process.env.NODE_ENV === 'production',
  target: ['es2020'],
  outdir: outDir,
  logLevel: 'info',
  format: 'esm',
  platform: 'browser'
};

async function main() {
  if (process.argv.includes('--watch')) {
    const context = await build({
      ...config,
      sourcemap: 'linked'
    });
    await context.watch();
    console.log('Watching for changes...');
  } else {
    await build(config);
  }
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});

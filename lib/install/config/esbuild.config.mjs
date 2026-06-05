import esbuild from "esbuild";
import path from "path";
import fs from "fs";

const TS_SOURCE_DIR = process.env.TS_SOURCE_DIR || "app/javascript";
const BUILD_DIR = process.env.BUILD_DIR || "app/assets/builds";
const isWatch = process.argv.includes("--watch");

fs.mkdirSync(BUILD_DIR, { recursive: true });

function findEntryPoints(sourceDir) {
  const entries = [];
  function walk(dir) {
    for (const file of fs.readdirSync(dir)) {
      const fullPath = path.join(dir, file);
      const stat = fs.statSync(fullPath);
      if (stat.isDirectory()) {
        walk(fullPath);
      } else if (/\.(ts|tsx)$/.test(file) && !/\.d\.ts$/.test(file) && !/\.test\./.test(file) && !/\.spec\./.test(file)) {
        entries.push(fullPath);
      }
    }
  }
  walk(sourceDir);
  return entries;
}

const entryPoints = findEntryPoints(TS_SOURCE_DIR);

if (entryPoints.length === 0) {
  console.log("No TypeScript entry points found.");
  process.exit(0);
}

const buildOptions = {
  entryPoints,
  bundle: false,
  format: "esm",
  outdir: BUILD_DIR,
  sourcemap: isWatch ? "inline" : true,
  target: ["es2020"],
  logLevel: "info",
  metafile: true,
  outbase: TS_SOURCE_DIR,
};

if (isWatch) {
  const ctx = await esbuild.context({
    ...buildOptions,
    plugins: [
      {
        name: "propshaft-cache-bust",
        setup(build) {
          build.onEnd((result) => {
            if (result.errors.length === 0) {
              const touchFile = path.join(BUILD_DIR, ".esbuild-last-build");
              fs.writeFileSync(touchFile, new Date().toISOString());
              console.log(`[esbuild] Build complete at ${new Date().toLocaleTimeString()}`);
            }
          });
        },
      },
    ],
  });

  await ctx.watch();
  console.log(`[esbuild] Watching ${TS_SOURCE_DIR} for changes...`);
  console.log(`[esbuild] Output: ${BUILD_DIR}`);

  process.on("SIGTERM", async () => {
    await ctx.dispose();
    process.exit(0);
  });
  process.on("SIGINT", async () => {
    await ctx.dispose();
    process.exit(0);
  });
} else {
  const result = await esbuild.build(buildOptions);
  console.log(`[esbuild] Build complete. ${entryPoints.length} entry points compiled.`);
}

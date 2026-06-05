import esbuild from "esbuild";
import path from "path";
import fs from "fs";
import http from "http";

const TS_SOURCE_DIR = process.env.TS_SOURCE_DIR || "app/javascript";
const BUILD_DIR = process.env.BUILD_DIR || "app/assets/builds";
const HMR_PORT = parseInt(process.env.HMR_PORT || "3099", 10);
const DEBOUNCE_MS = parseInt(process.env.DEBOUNCE_MS || "100", 10);

const connectedClients = new Set();
let buildVersion = 0;
let debounceTimer = null;

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
  console.log("[esbuild-hmr] No TypeScript entry points found.");
  process.exit(0);
}

const hmrServer = http.createServer((req, res) => {
  if (req.headers.accept && req.headers.accept.includes("text/event-stream")) {
    res.writeHead(200, {
      "Content-Type": "text/event-stream",
      "Cache-Control": "no-cache, no-store, must-revalidate",
      Connection: "keep-alive",
      "Access-Control-Allow-Origin": "*",
    });

    connectedClients.add(res);

    res.write(`data: ${JSON.stringify({ type: "connected", version: buildVersion })}\n\n`);

    req.on("close", () => {
      connectedClients.delete(res);
    });
  } else {
    res.writeHead(404);
    res.end();
  }
});

hmrServer.listen(HMR_PORT, () => {
  console.log(`[esbuild-hmr] SSE server listening on port ${HMR_PORT}`);
});

function notifyClients(changedFiles) {
  const message = JSON.stringify({
    type: "update",
    version: buildVersion,
    files: changedFiles,
    timestamp: Date.now(),
  });

  for (const client of connectedClients) {
    try {
      client.write(`data: ${message}\n\n`);
    } catch {
      connectedClients.delete(client);
    }
  }
}

const ctx = await esbuild.context({
  entryPoints,
  bundle: false,
  format: "esm",
  outdir: BUILD_DIR,
  sourcemap: "inline",
  target: ["es2020"],
  logLevel: "info",
  metafile: true,
  outbase: TS_SOURCE_DIR,
  plugins: [
    {
      name: "hmr-notify",
      setup(build) {
        build.onEnd((result) => {
          if (result.errors.length === 0) {
            buildVersion++;

            const changedFiles = result.metafile
              ? Object.keys(result.metafile.inputs).map((f) => {
                  const outPath = f.replace(/\.tsx?$/, ".js");
                  return outPath;
                })
              : [];

            const touchFile = path.join(BUILD_DIR, ".esbuild-last-build");
            fs.writeFileSync(touchFile, new Date().toISOString());

            if (debounceTimer) clearTimeout(debounceTimer);
            debounceTimer = setTimeout(() => {
              notifyClients(changedFiles);
            }, DEBOUNCE_MS);
          }
        });
      },
    },
  ],
});

await ctx.watch();
console.log(`[esbuild-hmr] Watching ${TS_SOURCE_DIR} for changes...`);
console.log(`[esbuild-hmr] Output: ${BUILD_DIR}`);
console.log(`[esbuild-hmr] HMR SSE endpoint: http://localhost:${HMR_PORT}`);

process.on("SIGTERM", async () => {
  hmrServer.close();
  await ctx.dispose();
  process.exit(0);
});
process.on("SIGINT", async () => {
  hmrServer.close();
  await ctx.dispose();
  process.exit(0);
});

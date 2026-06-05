import * as esbuild from "esbuild"
import { readdirSync } from "node:fs"
import path from "node:path"

const root = process.cwd()
const sourceDir = path.join(root, "app/frontend")
const outdir = path.join(root, "app/assets/builds")
const entryPoints = collectEntryPoints(sourceDir)
const watch = process.argv.includes("--watch")
const production = process.env.NODE_ENV === "production"

if (entryPoints.length === 0) {
  throw new Error(`No TypeScript entry points found in ${sourceDir}`)
}

const config = {
  entryPoints,
  outdir,
  outbase: sourceDir,
  platform: "browser",
  format: "esm",
  bundle: false,
  sourcemap: production ? false : "linked",
  target: ["es2022", "safari15"],
  jsx: "automatic",
  logLevel: "info",
  legalComments: "none",
  loader: {
    ".ts": "ts",
    ".tsx": "tsx"
  }
}

if (watch) {
  const context = await esbuild.context(config)
  await context.watch()
  console.log("Watching TypeScript sources...")
} else {
  await esbuild.build(config)
}

function collectEntryPoints(directory) {
  return readdirSync(directory, { withFileTypes: true }).flatMap((entry) => {
    const fullPath = path.join(directory, entry.name)

    if (entry.isDirectory()) {
      return collectEntryPoints(fullPath)
    }

    if (entry.isFile() && [".ts", ".tsx"].includes(path.extname(entry.name))) {
      return [fullPath]
    }

    return []
  })
}
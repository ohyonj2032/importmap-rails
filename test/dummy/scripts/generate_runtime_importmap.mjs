import { mkdirSync, writeFileSync } from "node:fs"
import path from "node:path"

const [target = "react-data-grid@7.0.0-beta.30", manifestName = target.replace(/[@/]/g, "-")] = process.argv.slice(2)
const response = await fetch("https://api.jspm.io/generate", {
  method: "POST",
  headers: { "content-type": "application/json" },
  body: JSON.stringify({
    install: [target],
    env: ["browser", "production", "module"],
    integrity: true,
    inputMap: {
      imports: {
        react: "https://ga.jspm.io/npm:react@18.3.1/index.js",
        "react-dom": "https://ga.jspm.io/npm:react-dom@18.3.1/index.js",
        "react-dom/client": "https://ga.jspm.io/npm:react-dom@18.3.1/client.js",
        "react/jsx-runtime": "https://ga.jspm.io/npm:react@18.3.1/jsx-runtime.js"
      }
    }
  })
})

if (!response.ok) {
  throw new Error(`JSPM generate failed with ${response.status}`)
}

const payload = await response.json()

if (!payload.map) {
  throw new Error("JSPM generate response did not include an import map")
}

const outputDir = path.join(process.cwd(), "config", "runtime_importmaps")
const outputPath = path.join(outputDir, `${manifestName}.json`)

mkdirSync(outputDir, { recursive: true })
writeFileSync(outputPath, `${JSON.stringify(payload.map, null, 2)}\n`)
console.log(`Wrote ${outputPath}`)
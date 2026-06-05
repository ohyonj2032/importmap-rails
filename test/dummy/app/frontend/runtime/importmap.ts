type RuntimeImportMap = {
  imports?: Record<string, string>
  scopes?: Record<string, Record<string, string>>
  integrity?: Record<string, string>
}

type ImportShim = ((specifier: string) => Promise<unknown>) & {
  addImportMap?: (importMap: RuntimeImportMap) => void
}

const runtimeImportMaps = new Map<string, Promise<void>>()

export async function ensureRuntimeImportmap(name: string) {
  if (!runtimeImportMaps.has(name)) {
    runtimeImportMaps.set(name, fetchRuntimeImportmap(name).then((importMap) => appendImportMap(importMap)))
  }

  await runtimeImportMaps.get(name)
}

export async function loadRuntimeModule(specifier: string, manifestName = specifier) {
  await ensureRuntimeImportmap(manifestName)

  const loader = importShimLoader()

  if (loader) {
    return loader(specifier)
  }

  return import(specifier)
}

async function fetchRuntimeImportmap(name: string): Promise<RuntimeImportMap> {
  const response = await fetch(`/runtime_importmaps/${encodeURIComponent(name)}`, {
    headers: { Accept: "application/json" },
    cache: "no-store",
    credentials: "same-origin"
  })

  if (!response.ok) {
    throw new Error(`Unable to load runtime import map for ${name}`)
  }

  return response.json() as Promise<RuntimeImportMap>
}

function appendImportMap(importMap: RuntimeImportMap) {
  const loader = importShimLoader()

  if (typeof loader?.addImportMap === "function") {
    loader.addImportMap(importMap)
    return
  }

  const script = document.createElement("script")
  script.type = "importmap-shim"
  script.textContent = JSON.stringify(importMap)
  document.head.append(script)
}

function importShimLoader() {
  return (globalThis as typeof globalThis & { importShim?: ImportShim }).importShim
}
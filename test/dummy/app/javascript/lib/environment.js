const ENV = document.documentElement.dataset.environment || "production"

const isDevelopment = ENV === "development"
const isProduction = ENV === "production"
const isTest = ENV === "test"

function debug(...args) {
  if (isDevelopment) {
    console.log("[App Debug]", ...args)
  }
}

function warn(...args) {
  if (!isTest) {
    console.warn("[App Warning]", ...args)
  }
}

function error(...args) {
  console.error("[App Error]", ...args)
}

function measurePerformance(label, fn) {
  if (!isDevelopment) return fn()

  const start = performance.now()
  const result = fn()
  const duration = performance.now() - start

  debug(`[Performance] ${label}: ${duration.toFixed(2)}ms`)
  return result
}

async function measurePerformanceAsync(label, fn) {
  if (!isDevelopment) return fn()

  const start = performance.now()
  const result = await fn()
  const duration = performance.now() - start

  debug(`[Performance] ${label}: ${duration.toFixed(2)}ms`)
  return result
}

export {
  ENV,
  isDevelopment,
  isProduction,
  isTest,
  debug,
  warn,
  error,
  measurePerformance,
  measurePerformanceAsync
}

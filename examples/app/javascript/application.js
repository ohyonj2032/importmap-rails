// Entry point for the JavaScript application
// This file is imported via the importmap

// =============================================================================
// Import core dependencies
// =============================================================================
import "@hotwired/turbo-rails"
import { Application } from "@hotwired/stimulus"
import { definitionsFromContext } from "@hotwired/stimulus-loading"

// =============================================================================
// Initialize Stimulus application
// =============================================================================
const application = Application.start()
const context = require.context("./controllers", true, /\.js$/)
application.load(definitionsFromContext(context))

// Configure Stimulus development experience
application.debug = false
window.Stimulus = application

// =============================================================================
// Import and initialize Action Cable
// =============================================================================
import { createConsumer } from "@rails/actioncable"
window.App = window.App || {}
window.App.cable = createConsumer()

// =============================================================================
// Import utility helpers (on demand)
// =============================================================================
export const loadUtility = async (name) => {
  try {
    const module = await import(`utils/${name}`)
    return module
  } catch (error) {
    console.error(`Failed to load utility ${name}:`, error)
    return null
  }
}

// =============================================================================
// Content Security Policy (CSP) helpers
// =============================================================================
const cspHelpers = {
  nonce: document.querySelector('meta[name="csp-nonce"]')?.getAttribute('content'),
  
  addScriptWithNonce(src) {
    const script = document.createElement('script')
    script.src = src
    if (this.nonce) {
      script.setAttribute('nonce', this.nonce)
    }
    document.head.appendChild(script)
    return script
  },

  addInlineScriptWithNonce(code) {
    const script = document.createElement('script')
    if (this.nonce) {
      script.setAttribute('nonce', this.nonce)
    }
    script.textContent = code
    document.head.appendChild(script)
    return script
  }
}

window.CSPHelpers = cspHelpers

// =============================================================================
// Dependency resolver with lazy loading
// =============================================================================
class DependencyResolver {
  constructor() {
    this.cache = new Map()
  }

  async load(name, options = {}) {
    if (this.cache.has(name)) {
      return this.cache.get(name)
    }

    try {
      const module = await import(name)
      this.cache.set(name, module)
      
      if (options.onLoad) {
        options.onLoad(module)
      }
      
      return module
    } catch (error) {
      console.error(`Failed to resolve dependency ${name}:`, error)
      throw error
    }
  }

  clearCache() {
    this.cache.clear()
  }
}

window.DependencyResolver = new DependencyResolver()

// =============================================================================
// Environment detection and configuration
// =============================================================================
const Environment = {
  isDevelopment: window.location.hostname === 'localhost' || 
                 window.location.hostname === '127.0.0.1',
  isProduction: !window.location.hostname.includes('localhost') && 
                !window.location.hostname.includes('127.0.0.1'),
  
  config: {
    development: {
      logging: true,
      cacheStrategy: 'network-first',
      devtools: true
    },
    production: {
      logging: false,
      cacheStrategy: 'cache-first',
      devtools: false
    }
  },

  get current() {
    return this.isDevelopment ? 'development' : 'production'
  },

  get config() {
    return this.isDevelopment ? this.config.development : this.config.production
  }
}

window.Environment = Environment

// =============================================================================
// Cross-browser compatibility helpers
// =============================================================================
const BrowserCompat = {
  supportsImportMaps: 'importScripts' in self || 
                      'HTMLScriptElement' in window && 
                      'supports' in HTMLScriptElement &&
                      HTMLScriptElement.supports('importmap'),

  supportsModulepreload: 'link' in document.createElement('link') && 
                         'relList' in document.createElement('link') &&
                         document.createElement('link').relList.supports('modulepreload'),

  init() {
    if (!this.supportsImportMaps) {
      this.loadShim()
    }
  },

  loadShim() {
    const script = document.createElement('script')
    script.src = 'https://ga.jspm.io/npm:es-module-shims@1.8.2/dist/es-module-shims.js'
    script.async = true
    script.setAttribute('data-turbo-track', 'reload')
    document.head.appendChild(script)
  }
}

BrowserCompat.init()

// =============================================================================
// Application initialization
// =============================================================================
document.addEventListener('turbo:load', () => {
  if (Environment.config.logging) {
    console.log('Turbo loaded successfully')
  }
})

document.addEventListener('DOMContentLoaded', () => {
  if (Environment.config.logging) {
    console.log('Application initialized in', Environment.current, 'mode')
    console.log('Stimulus controllers loaded:', application.controllers)
  }
  
  // Initialize any page-specific modules based on data attribute
  const pageModule = document.body.dataset.pageModule
  if (pageModule) {
    import(`./${pageModule}`).catch(error => {
      console.warn(`Page module ${pageModule} not found:`, error)
    })
  }
})

// =============================================================================
// Error handling and reporting
// =============================================================================
window.onerror = (message, source, lineno, colno, error) => {
  if (Environment.config.logging) {
    console.error('Global error:', { message, source, lineno, colno, error })
  }
  return false
}

window.addEventListener('unhandledrejection', (event) => {
  if (Environment.config.logging) {
    console.error('Unhandled promise rejection:', event.reason)
  }
})

// =============================================================================
// Export main application
// =============================================================================
export { application }
export default application

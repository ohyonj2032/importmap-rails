import React from "react"
import { createRoot } from "react-dom/client"
import { App } from "./components/app.js"
import { startDevelopmentReloading } from "./runtime/dev_reload.js"

export function boot() {
  const element = document.getElementById("app")

  if (!element) {
    return
  }

  startDevelopmentReloading()
  createRoot(element).render(<App />)
}
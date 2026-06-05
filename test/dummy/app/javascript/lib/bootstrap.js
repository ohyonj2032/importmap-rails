import React from "react"
import { createRoot } from "react-dom/client"
import AppShell from "@components/app_shell"
import { resolveLegacySpecifier } from "@legacy/module_compat"

const mountId = "react-importmap-root"
let root

function readMountState() {
  const element = document.getElementById(mountId)

  return {
    element,
    environment: element?.dataset.environment || "development",
    entrypoint: resolveLegacySpecifier(element?.dataset.entrypoint || "application")
  }
}

export function startApplication() {
  const { element, environment, entrypoint } = readMountState()

  if (!element) {
    return
  }

  if (!root) {
    root = createRoot(element)
  }

  root.render(React.createElement(AppShell, { environment, entrypoint }))
}

export function stopApplication() {
  if (!root) {
    return
  }

  root.unmount()
  root = null
}

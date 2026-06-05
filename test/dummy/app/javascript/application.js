import { startApplication, stopApplication } from "@app/bootstrap"

const mount = () => startApplication()
const unmount = () => stopApplication()

document.addEventListener("turbo:before-render", unmount)
document.addEventListener("turbo:before-cache", unmount)
document.addEventListener("turbo:load", mount)

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", mount, { once: true })
} else {
  mount()
}

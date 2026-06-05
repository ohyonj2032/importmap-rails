import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["count", "button"]
  static values = { initial: { type: Number, default: 0 } }

  connect() {
    this.count = this.initialValue
    this.updateDisplay()
    console.log('Counter controller connected')
  }

  increment() {
    this.count++
    this.updateDisplay()
    this.dispatch('incremented', { detail: { count: this.count } })
  }

  decrement() {
    this.count--
    this.updateDisplay()
    this.dispatch('decremented', { detail: { count: this.count } })
  }

  reset() {
    this.count = this.initialValue
    this.updateDisplay()
    this.dispatch('reset', { detail: { count: this.count } })
  }

  updateDisplay() {
    if (this.hasCountTarget) {
      this.countTarget.textContent = this.count
    }
  }

  disconnect() {
    console.log('Counter controller disconnected')
  }
}

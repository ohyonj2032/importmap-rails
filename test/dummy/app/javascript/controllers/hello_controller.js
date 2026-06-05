import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["name", "output", "greeting"]

  static classes = ["highlight", "active"]

  static values = {
    greeting: { type: String, default: "Hello" },
    count: { type: Number, default: 0 },
    enabled: { type: Boolean, default: true }
  }

  connect() {
    this.element.dataset.stimulus = "hello-connected"
    this.renderGreeting()
  }

  disconnect() {
    delete this.element.dataset.stimulus
  }

  greet() {
    if (!this.enabledValue) return

    this.countValue++
    this.renderGreeting()

    this.dispatch("greeted", {
      detail: { count: this.countValue, greeting: this.greetingValue },
      prefix: true
    })
  }

  renderGreeting() {
    if (this.hasOutputTarget) {
      const name = this.hasNameTarget ? this.nameTarget.value.trim() : "World"
      this.outputTarget.textContent = `${this.greetingValue}, ${name}! (Count: ${this.countValue})`
    }

    if (this.hasGreetingTarget) {
      this.greetingTarget.textContent = this.greetingValue
    }
  }

  greetingValueChanged() {
    this.renderGreeting()
  }

  enabledValueChanged() {
    if (this.hasOutputTarget) {
      this.outputTarget.style.opacity = this.enabledValue ? "1" : "0.5"
    }
  }

  reset() {
    this.countValue = 0
    this.greetingValue = "Hello"
    this.renderGreeting()
  }
}

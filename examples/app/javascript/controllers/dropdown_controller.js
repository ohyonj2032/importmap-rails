import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]
  static values = { open: Boolean }

  connect() {
    this.open = this.openValue
    this.updateMenu()
    document.addEventListener('click', this.handleOutsideClick.bind(this))
  }

  toggle() {
    this.open = !this.open
    this.updateMenu()
    this.dispatch(this.open ? 'opened' : 'closed')
  }

  openMenu() {
    this.open = true
    this.updateMenu()
    this.dispatch('opened')
  }

  closeMenu() {
    this.open = false
    this.updateMenu()
    this.dispatch('closed')
  }

  updateMenu() {
    if (this.hasMenuTarget) {
      if (this.open) {
        this.menuTarget.classList.remove('hidden')
      } else {
        this.menuTarget.classList.add('hidden')
      }
    }
  }

  handleOutsideClick(event) {
    if (!this.element.contains(event.target) && this.open) {
      this.closeMenu()
    }
  }

  disconnect() {
    document.removeEventListener('click', this.handleOutsideClick.bind(this))
  }
}

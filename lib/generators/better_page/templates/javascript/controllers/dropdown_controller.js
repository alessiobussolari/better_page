import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dropdown"
export default class extends Controller {
  static targets = ["menu"]

  connect() {
    this.boundHide = this.hide.bind(this)
    this.boundUpdatePosition = this.updatePosition.bind(this)
    document.addEventListener("click", this.boundHide)
    window.addEventListener("scroll", this.boundUpdatePosition, true)
    window.addEventListener("resize", this.boundUpdatePosition)
  }

  disconnect() {
    document.removeEventListener("click", this.boundHide)
    window.removeEventListener("scroll", this.boundUpdatePosition, true)
    window.removeEventListener("resize", this.boundUpdatePosition)
  }

  toggle(event) {
    event.stopPropagation()
    const isHidden = this.menuTarget.classList.contains("hidden")

    if (isHidden) {
      this.menuTarget.classList.remove("hidden")
      this.menuTarget.style.position = "fixed"
      this.updatePosition()
    } else {
      this.menuTarget.classList.add("hidden")
    }
  }

  updatePosition() {
    if (this.menuTarget.classList.contains("hidden")) return

    const button = this.element.querySelector("button")
    const rect = button.getBoundingClientRect()
    const menuRect = this.menuTarget.getBoundingClientRect()

    // Posiziona sotto il bottone, allineato a destra
    let top = rect.bottom + 8
    let left = rect.right - menuRect.width

    // Controlla se esce dalla viewport
    if (left < 0) left = rect.left
    if (top + menuRect.height > window.innerHeight) {
      top = rect.top - menuRect.height - 8
    }

    this.menuTarget.style.top = `${top}px`
    this.menuTarget.style.left = `${left}px`
  }

  hide(event) {
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.add("hidden")
    }
  }
}

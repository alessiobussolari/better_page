import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="modal"
export default class extends Controller {
  static targets = ["container", "panel", "backdrop"]
  static values = {
    open: { type: Boolean, default: false },
    confirmClose: { type: Boolean, default: false }
  }

  connect() {
    this.boundKeydown = this.keydown.bind(this)
    document.addEventListener("keydown", this.boundKeydown)
  }

  disconnect() {
    document.removeEventListener("keydown", this.boundKeydown)
    document.body.classList.remove("overflow-hidden")
  }

  open() {
    this.openValue = true
    this.containerTarget.classList.remove("hidden")
    document.body.classList.add("overflow-hidden")

    requestAnimationFrame(() => {
      this.backdropTarget.classList.remove("opacity-0")
      this.panelTarget.classList.remove("opacity-0", "translate-y-4", "sm:translate-y-0", "sm:scale-95")
      this.panelTarget.classList.add("opacity-100", "translate-y-0", "sm:scale-100")
    })
  }

  close() {
    this.openValue = false
    this.backdropTarget.classList.add("opacity-0")
    this.panelTarget.classList.remove("opacity-100", "translate-y-0", "sm:scale-100")
    this.panelTarget.classList.add("opacity-0", "translate-y-4", "sm:translate-y-0", "sm:scale-95")

    setTimeout(() => {
      this.containerTarget.classList.add("hidden")
      document.body.classList.remove("overflow-hidden")
    }, 300)
  }

  toggle() {
    this.openValue ? this.close() : this.open()
  }

  requestClose() {
    if (this.confirmCloseValue) {
      if (confirm("Sei sicuro di voler chiudere? I dati non salvati andranno persi.")) {
        this.close()
      }
    } else {
      this.close()
    }
  }

  keydown(event) {
    if (event.key === "Escape" && this.openValue) {
      this.requestClose()
    }
  }

  backdropClick(event) {
    if (event.target === this.backdropTarget) {
      this.requestClose()
    }
  }
}

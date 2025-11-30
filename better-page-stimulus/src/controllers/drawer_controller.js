import { Controller } from "@hotwired/stimulus"

/**
 * Drawer Controller
 *
 * A Stimulus controller for slide-out drawer panels.
 * Connects to data-controller="drawer"
 *
 * Usage:
 *   <div data-controller="drawer" data-drawer-direction-value="right">
 *     <button data-action="click->drawer#open">Open Drawer</button>
 *
 *     <div data-drawer-target="container" class="hidden">
 *       <div data-drawer-target="backdrop" data-action="click->drawer#backdropClick"></div>
 *       <div data-drawer-target="panel">
 *         <button data-action="click->drawer#close">Close</button>
 *         <!-- content -->
 *       </div>
 *     </div>
 *   </div>
 */
export default class extends Controller {
  static targets = ["container", "panel", "backdrop"]
  static values = {
    direction: { type: String, default: "right" },
    open: { type: Boolean, default: false }
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

    // Trigger animation on next frame
    requestAnimationFrame(() => {
      this.panelTarget.classList.remove(this.hiddenClass)
      this.backdropTarget.classList.remove("opacity-0")
    })
  }

  close() {
    this.openValue = false
    this.panelTarget.classList.add(this.hiddenClass)
    this.backdropTarget.classList.add("opacity-0")

    // Wait for animation to complete
    setTimeout(() => {
      this.containerTarget.classList.add("hidden")
      document.body.classList.remove("overflow-hidden")
    }, 300)
  }

  toggle() {
    this.openValue ? this.close() : this.open()
  }

  keydown(event) {
    if (event.key === "Escape" && this.openValue) {
      this.close()
    }
  }

  backdropClick(event) {
    if (event.target === this.backdropTarget) {
      this.close()
    }
  }

  get hiddenClass() {
    const classes = {
      right: "translate-x-full",
      left: "-translate-x-full",
      top: "-translate-y-full",
      bottom: "translate-y-full"
    }
    return classes[this.directionValue] || "translate-x-full"
  }
}

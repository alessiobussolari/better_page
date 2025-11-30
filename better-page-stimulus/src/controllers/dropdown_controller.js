import { Controller } from "@hotwired/stimulus"

/**
 * Dropdown Controller
 *
 * A Stimulus controller for dropdown menus.
 * Connects to data-controller="dropdown"
 *
 * Usage:
 *   <div data-controller="dropdown">
 *     <button data-action="click->dropdown#toggle">Menu</button>
 *     <div data-dropdown-target="menu" class="hidden">
 *       <!-- dropdown content -->
 *     </div>
 *   </div>
 */
export default class extends Controller {
  static targets = ["menu"]

  connect() {
    this.boundHide = this.hide.bind(this)
    document.addEventListener("click", this.boundHide)
  }

  disconnect() {
    document.removeEventListener("click", this.boundHide)
  }

  toggle(event) {
    event.stopPropagation()
    this.menuTarget.classList.toggle("hidden")
  }

  hide(event) {
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.add("hidden")
    }
  }
}

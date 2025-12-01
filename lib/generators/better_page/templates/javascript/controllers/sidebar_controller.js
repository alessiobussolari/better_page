import { Controller } from "@hotwired/stimulus"

/**
 * Sidebar Controller
 *
 * A Stimulus controller for collapsible sidebar navigation.
 * Connects to data-controller="sidebar"
 *
 * Features:
 * - Toggle entire sidebar collapse/expand
 * - Toggle individual menu groups
 * - Persist collapse state in localStorage
 *
 * Usage:
 *   <aside data-controller="sidebar"
 *          data-sidebar-collapsed-value="false"
 *          data-sidebar-persist-value="true"
 *          data-sidebar-storage-key-value="main-sidebar-collapsed">
 *     <button data-action="click->sidebar#toggle">Toggle</button>
 *     <div data-sidebar-target="group">
 *       <button data-action="click->sidebar#toggleGroup" data-group-id="nav">
 *         <span data-sidebar-target="groupLabel">Navigation</span>
 *         <svg data-sidebar-target="groupIcon">...</svg>
 *       </button>
 *       <div data-sidebar-target="groupContent" data-group-id="nav">
 *         <!-- group items -->
 *       </div>
 *     </div>
 *   </aside>
 */
export default class extends Controller {
  static targets = [
    "brand",
    "brandText",
    "toggleIcon",
    "group",
    "groupToggle",
    "groupLabel",
    "groupIcon",
    "groupContent",
    "item",
    "itemLabel"
  ]

  static values = {
    collapsed: Boolean,
    persist: Boolean,
    storageKey: String
  }

  connect() {
    // Restore saved state if persistence is enabled
    if (this.persistValue && this.storageKeyValue) {
      const saved = localStorage.getItem(this.storageKeyValue)
      if (saved !== null) {
        this.collapsedValue = saved === "true"
      }
    }
    this.updateUI()
  }

  /**
   * Toggle the entire sidebar collapse state
   */
  toggle() {
    this.collapsedValue = !this.collapsedValue

    // Save state if persistence is enabled
    if (this.persistValue && this.storageKeyValue) {
      localStorage.setItem(this.storageKeyValue, this.collapsedValue.toString())
    }

    this.updateUI()
  }

  /**
   * Toggle a specific menu group
   * @param {Event} event - Click event from the group toggle button
   */
  toggleGroup(event) {
    const button = event.currentTarget
    const groupId = button.dataset.groupId

    // Find the content container for this group
    const content = this.groupContentTargets.find(
      (el) => el.dataset.groupId === groupId
    )

    // Find the icon within the button
    const icon = button.querySelector('[data-sidebar-target="groupIcon"]')

    // Toggle aria-expanded
    const isExpanded = button.getAttribute("aria-expanded") === "true"
    button.setAttribute("aria-expanded", (!isExpanded).toString())

    // Toggle content visibility
    if (content) {
      content.classList.toggle("hidden")
    }

    // Toggle icon rotation
    if (icon) {
      icon.classList.toggle("-rotate-90")
      icon.classList.toggle("rotate-0")
    }
  }

  /**
   * Update the UI based on current collapsed state
   */
  updateUI() {
    const collapsed = this.collapsedValue

    // Update width classes
    this.element.classList.toggle("w-64", !collapsed)
    this.element.classList.toggle("w-16", collapsed)

    // Update toggle icon rotation
    if (this.hasToggleIconTarget) {
      this.toggleIconTarget.classList.toggle("rotate-180", collapsed)
    }

    // Collect all text elements to hide/show
    const textTargets = [
      ...(this.hasBrandTextTarget ? this.brandTextTargets : []),
      ...(this.hasGroupLabelTarget ? this.groupLabelTargets : []),
      ...(this.hasItemLabelTarget ? this.itemLabelTargets : [])
    ]

    // Toggle visibility of text elements
    textTargets.forEach((el) => {
      el.classList.toggle("opacity-0", collapsed)
      el.classList.toggle("w-0", collapsed)
      el.classList.toggle("overflow-hidden", collapsed)
    })

    // Hide badges when collapsed
    if (collapsed) {
      this.element.querySelectorAll("[class*='badge'], [class*='rounded-full']").forEach((badge) => {
        if (badge.classList.contains("bg-blue-100") || badge.classList.contains("bg-red-500")) {
          badge.classList.add("hidden")
        }
      })
    } else {
      this.element.querySelectorAll("[class*='badge'], [class*='rounded-full']").forEach((badge) => {
        if (badge.classList.contains("bg-blue-100") || badge.classList.contains("bg-red-500")) {
          badge.classList.remove("hidden")
        }
      })
    }
  }
}

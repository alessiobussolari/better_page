import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="tabs"
export default class extends Controller {
  static targets = ["tab", "panel"]
  static values = {
    default: String,
    style: { type: String, default: "underline" },
    activeClass: String,
    inactiveClass: String
  }

  connect() {
    const defaultId = this.defaultValue || this.tabTargets[0]?.dataset.tabId
    if (defaultId) {
      this.selectTab(defaultId, false)
    }
  }

  select(event) {
    const tabId = event.currentTarget.dataset.tabId
    this.selectTab(tabId)
  }

  selectTab(tabId, animate = true) {
    // Update tabs
    this.tabTargets.forEach(tab => {
      const isActive = tab.dataset.tabId === tabId
      tab.setAttribute("aria-selected", isActive)
      tab.setAttribute("tabindex", isActive ? "0" : "-1")

      // Update classes
      const activeClasses = this.activeClassValue.split(" ").filter(c => c)
      const inactiveClasses = this.inactiveClassValue.split(" ").filter(c => c)

      if (isActive) {
        tab.classList.remove(...inactiveClasses)
        tab.classList.add(...activeClasses)
      } else {
        tab.classList.remove(...activeClasses)
        tab.classList.add(...inactiveClasses)
      }
    })

    // Update panels
    this.panelTargets.forEach(panel => {
      const isActive = panel.dataset.tabId === tabId
      panel.classList.toggle("hidden", !isActive)
    })

    // Dispatch custom event
    this.dispatch("changed", { detail: { tabId } })
  }

  keydown(event) {
    const currentTab = event.currentTarget
    const currentIndex = this.tabTargets.indexOf(currentTab)
    let newIndex

    switch (event.key) {
      case "ArrowLeft":
        event.preventDefault()
        newIndex = currentIndex - 1
        if (newIndex < 0) newIndex = this.tabTargets.length - 1
        break
      case "ArrowRight":
        event.preventDefault()
        newIndex = currentIndex + 1
        if (newIndex >= this.tabTargets.length) newIndex = 0
        break
      case "Home":
        event.preventDefault()
        newIndex = 0
        break
      case "End":
        event.preventDefault()
        newIndex = this.tabTargets.length - 1
        break
      default:
        return
    }

    const newTab = this.tabTargets[newIndex]
    if (newTab) {
      newTab.focus()
      this.selectTab(newTab.dataset.tabId)
    }
  }
}

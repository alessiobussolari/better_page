import { Controller } from "@hotwired/stimulus"

/**
 * AppNav Controller
 *
 * A Stimulus controller for the application navigation bar.
 * Connects to data-controller="app-nav"
 *
 * Features:
 * - Toggle mobile navigation menu
 * - Toggle notification panel
 *
 * Usage:
 *   <nav data-controller="app-nav">
 *     <button data-action="click->app-nav#toggleMobile">
 *       <svg data-app-nav-target="menuIcon">...</svg>
 *       <svg data-app-nav-target="closeIcon" class="hidden">...</svg>
 *     </button>
 *     <div data-app-nav-target="mobileMenu" class="hidden">
 *       <!-- mobile menu content -->
 *     </div>
 *     <button data-action="click->app-nav#toggleNotification">
 *       Notifications
 *     </button>
 *     <div data-app-nav-target="notificationPanel" class="hidden">
 *       <!-- notification content -->
 *     </div>
 *   </nav>
 */
export default class extends Controller {
  static targets = ["mobileMenu", "menuIcon", "closeIcon", "notificationPanel"]

  /**
   * Toggle the mobile navigation menu visibility
   * Swaps between hamburger and close icons
   */
  toggleMobile() {
    if (this.hasMobileMenuTarget) {
      this.mobileMenuTarget.classList.toggle("hidden")
    }
    if (this.hasMenuIconTarget) {
      this.menuIconTarget.classList.toggle("hidden")
    }
    if (this.hasCloseIconTarget) {
      this.closeIconTarget.classList.toggle("hidden")
    }
  }

  /**
   * Toggle the notification panel visibility
   */
  toggleNotification() {
    if (this.hasNotificationPanelTarget) {
      this.notificationPanelTarget.classList.toggle("hidden")
    }
  }
}

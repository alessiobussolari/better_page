/**
 * BetterPage Stimulus Controllers
 *
 * This package provides Stimulus controllers for BetterPage Rails gem components.
 *
 * Usage with Rails importmap:
 *   # config/importmap.rb
 *   pin "better-page-stimulus", to: "https://unpkg.com/better-page-stimulus/src/index.js"
 *
 *   // app/javascript/controllers/index.js
 *   import { registerBetterPageControllers } from "better-page-stimulus"
 *   registerBetterPageControllers(application)
 *
 * Usage with npm/yarn:
 *   npm install better-page-stimulus
 *
 *   import { DropdownController, TableController, registerBetterPageControllers } from "better-page-stimulus"
 *   application.register("dropdown", DropdownController)
 *   application.register("table", TableController)
 *   // or
 *   registerBetterPageControllers(application)
 */

import DropdownController from "./controllers/dropdown_controller.js"
import TableController from "./controllers/table_controller.js"
import DrawerController from "./controllers/drawer_controller.js"
import SidebarController from "./controllers/sidebar_controller.js"
import AppNavController from "./controllers/app_nav_controller.js"

// Export individual controllers
export { DropdownController, TableController, DrawerController, SidebarController, AppNavController }

/**
 * Register all BetterPage controllers with a Stimulus application
 * @param {Application} application - The Stimulus application instance
 */
export function registerBetterPageControllers(application) {
  application.register("dropdown", DropdownController)
  application.register("table", TableController)
  application.register("drawer", DrawerController)
  application.register("sidebar", SidebarController)
  application.register("app-nav", AppNavController)
}

// Default export for convenience
export default {
  DropdownController,
  TableController,
  DrawerController,
  SidebarController,
  AppNavController,
  registerBetterPageControllers
}

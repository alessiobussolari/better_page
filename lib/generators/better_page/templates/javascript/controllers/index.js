// BetterPage Stimulus Controllers
// This file exports all controllers for easy registration

import DropdownController from "./dropdown_controller"
import TableController from "./table_controller"
import DrawerController from "./drawer_controller"
import ModalController from "./modal_controller"
import TabsController from "./tabs_controller"
import SidebarController from "./sidebar_controller"
import AppNavController from "./app_nav_controller"

// Export individual controllers
export { DropdownController, TableController, DrawerController, ModalController, TabsController, SidebarController, AppNavController }

// Helper function to register all controllers at once
export function registerBetterPageControllers(application) {
  application.register("dropdown", DropdownController)
  application.register("table", TableController)
  application.register("drawer", DrawerController)
  application.register("modal", ModalController)
  application.register("tabs", TabsController)
  application.register("sidebar", SidebarController)
  application.register("app-nav", AppNavController)
}

// Default export for convenience
export default {
  DropdownController,
  TableController,
  DrawerController,
  ModalController,
  TabsController,
  SidebarController,
  AppNavController,
  registerBetterPageControllers
}

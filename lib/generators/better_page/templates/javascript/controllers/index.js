// BetterPage Stimulus Controllers
// This file exports all controllers for easy registration

import DropdownController from "./dropdown_controller"
import TableController from "./table_controller"
import DrawerController from "./drawer_controller"

// Export individual controllers
export { DropdownController, TableController, DrawerController }

// Helper function to register all controllers at once
export function registerBetterPageControllers(application) {
  application.register("dropdown", DropdownController)
  application.register("table", TableController)
  application.register("drawer", DrawerController)
}

// Default export for convenience
export default {
  DropdownController,
  TableController,
  DrawerController,
  registerBetterPageControllers
}

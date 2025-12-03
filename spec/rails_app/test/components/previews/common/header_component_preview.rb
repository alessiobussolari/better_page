# frozen_string_literal: true

module Common
  class HeaderComponentPreview < ViewComponent::Preview
    layout "component_preview"

    # Header Component
    # ----------------
    # Displays a page header with optional breadcrumbs, metadata, and actions.
    #
    # **Action Styles:**
    # - `:primary` - Main action (blue)
    # - `:secondary` - Secondary action (gray)
    # - `:danger` - Destructive action (red)
    #
    # @label Playground
    # @param title text "Page title"
    # @param show_breadcrumbs toggle "Show navigation breadcrumbs"
    # @param show_metadata toggle "Show metadata info"
    # @param show_actions toggle "Show action buttons"
    def playground(
      title: "Products",
      show_breadcrumbs: false,
      show_metadata: false,
      show_actions: false
    )
      breadcrumbs = show_breadcrumbs ? [
        { label: "Home", path: "/" },
        { label: "Admin", path: "/admin" },
        { label: title }
      ] : []

      metadata = show_metadata ? [
        { value: "128 items" },
        { value: "Last updated: Today" }
      ] : []

      actions = show_actions ? [
        { label: "Export", path: "#", style: :secondary },
        { label: "New Item", path: "#", style: :primary }
      ] : []

      render BetterPage::Common::HeaderComponent.new(
        title: title,
        breadcrumbs: breadcrumbs,
        metadata: metadata,
        actions: actions
      )
    end
  end
end

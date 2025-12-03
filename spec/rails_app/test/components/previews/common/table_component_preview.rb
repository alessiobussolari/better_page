# frozen_string_literal: true

module Common
  class TableComponentPreview < ViewComponent::Preview
    layout "component_preview"

    # Table Component
    # ---------------
    # Displays data in a tabular format with optional features.
    #
    # **Column Formats:**
    # - `:currency` - Format as money ($99.00)
    # - `:boolean` - Display as checkmark/cross
    # - `:date` - Format date only
    # - `:datetime` - Format date and time
    # - `:percentage` - Format with %
    #
    # **Action Display:**
    # - `:inline` - Show buttons in row
    # - `:dropdown` - Show in 3-dot menu
    #
    # **Action Styles:**
    # - `:primary` - Blue button
    # - `:danger` - Red button (for destructive actions)
    #
    # @label Playground
    # @param selectable toggle "Show row checkboxes"
    # @param show_actions toggle "Show row actions"
    # @param actions_display [Symbol] select { choices: [inline, dropdown] } "Actions display style"
    # @param show_row_links toggle "Make rows clickable"
    # @param show_empty_state toggle "Show empty state"
    def playground(
      selectable: false,
      show_actions: false,
      actions_display: :inline,
      show_row_links: false,
      show_empty_state: false
    )
      columns = [
        { key: :name, label: "Product" },
        { key: :price, label: "Price", format: :currency },
        { key: :stock, label: "Stock" },
        { key: :active, label: "Status", format: :boolean }
      ]

      if show_empty_state
        empty_state = {
          title: "No products found",
          description: "Get started by creating a new product.",
          action: { label: "Add Product", path: "#new" }
        }

        return render BetterPage::Common::TableComponent.new(
          items: [],
          columns: columns,
          empty_state: empty_state
        )
      end

      items = [
        { id: 1, name: "iPhone 15", price: 999.00, stock: 50, active: true },
        { id: 2, name: "MacBook Pro", price: 2499.00, stock: 25, active: true },
        { id: 3, name: "AirPods Pro", price: 249.00, stock: 100, active: false },
        { id: 4, name: "iPad Air", price: 599.00, stock: 75, active: true }
      ]

      row_actions = if show_actions
        ->(item) {
          [
            { label: "Edit", path: "#edit-#{item[:id]}", style: :primary },
            { label: "Delete", path: "#delete-#{item[:id]}", style: :danger, confirm: "Are you sure?" }
          ]
        }
      end

      row_link = show_row_links ? ->(item) { "#product-#{item[:id]}" } : nil

      render BetterPage::Common::TableComponent.new(
        items: items,
        columns: columns,
        selectable: selectable,
        row_actions: row_actions,
        actions_display: actions_display.to_sym,
        row_link: row_link
      )
    end
  end
end

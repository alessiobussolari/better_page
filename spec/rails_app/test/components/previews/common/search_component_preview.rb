# frozen_string_literal: true

module Common
  class SearchComponentPreview < ViewComponent::Preview
    layout "component_preview"

    # Search Component
    # ----------------
    # Displays a search input with optional filters and results count.
    #
    # **Filter Types:**
    # - `:select` - Dropdown selection filter
    #
    # @label Playground
    # @param current_search text "Current search term"
    # @param show_results_count toggle "Show results count"
    # @param show_filters toggle "Show filter dropdowns"
    # @param has_active_filters toggle "Filters have selected values"
    def playground(
      current_search: "",
      show_results_count: false,
      show_filters: false,
      has_active_filters: false
    )
      results_count = show_results_count && current_search.present? ? 24 : nil

      filters = if show_filters
        [
          {
            name: :category,
            label: "Category",
            type: :select,
            options: [
              { value: "", label: "All Categories" },
              { value: "phones", label: "Phones" },
              { value: "laptops", label: "Laptops" },
              { value: "tablets", label: "Tablets" }
            ],
            current_value: has_active_filters ? "phones" : nil
          },
          {
            name: :status,
            label: "Status",
            type: :select,
            options: [
              { value: "", label: "All Statuses" },
              { value: "active", label: "Active" },
              { value: "draft", label: "Draft" },
              { value: "archived", label: "Archived" }
            ],
            current_value: has_active_filters ? "active" : nil
          }
        ]
      end

      render BetterPage::Common::SearchComponent.new(
        placeholder: "Search products...",
        current_search: current_search.presence,
        results_count: results_count,
        filters: filters
      )
    end
  end
end

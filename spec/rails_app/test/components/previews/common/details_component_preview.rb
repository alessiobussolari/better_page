# frozen_string_literal: true

module Common
  class DetailsComponentPreview < ViewComponent::Preview
    layout "component_preview"

    # Details Component
    # -----------------
    # Displays information in a configurable grid layout.
    #
    # **Field Types:**
    # - `:string` (default) - Plain text
    # - `:email` - Clickable mailto: link
    # - `:phone` - Clickable tel: link
    # - `:url` - Clickable external link
    #
    # **Layout Options:**
    # - 1 column - Single column vertical layout
    # - 2 columns - Default two-column grid
    # - 3 columns - Three-column overview style
    # - 4 columns - Compact four-column layout
    #
    # @label Playground
    # @param title text "Section title"
    # @param description text "Section description"
    # @param columns [Integer] select { choices: [1, 2, 3, 4] } "Grid columns"
    # @param enabled toggle "Render component"
    # @param show_all_types toggle "Show all field types (email, phone, url)"
    def playground(
      title: "User Information",
      description: "Personal details and contact information.",
      columns: 2,
      enabled: true,
      show_all_types: false
    )
      items = if show_all_types
        [
          { label: "Name", value: "John Doe" },
          { label: "Email", value: "john@example.com", type: :email },
          { label: "Phone", value: "+1 (555) 123-4567", type: :phone },
          { label: "Website", value: "https://example.com", type: :url },
          { label: "Notes", value: "Additional notes here" }
        ]
      else
        [
          { label: "Full Name", value: "John Doe" },
          { label: "Email", value: "john@example.com", type: :email },
          { label: "Location", value: "New York, USA" },
          { label: "Department", value: "Engineering" },
          { label: "Role", value: "Senior Developer" },
          { label: "Status", value: "Active" }
        ]
      end

      render BetterPage::Common::DetailsComponent.new(
        title: title.presence,
        description: description.presence,
        items: items,
        columns: columns.to_i,
        enabled: enabled
      )
    end
  end
end

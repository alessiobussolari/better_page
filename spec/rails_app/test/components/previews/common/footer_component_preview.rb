# frozen_string_literal: true

module Common
  class FooterComponentPreview < ViewComponent::Preview
    layout "component_preview"

    # Footer Component
    # ----------------
    # Displays action buttons and/or status text at the bottom of a section.
    #
    # **Action Styles:**
    # - `:primary` - Main action (blue)
    # - `:secondary` - Secondary action (gray)
    # - `:danger` - Destructive action (red)
    #
    # @label Playground
    # @param show_actions toggle "Show action buttons"
    # @param show_text toggle "Show status text"
    # @param action_style [Symbol] select { choices: [standard, form, full] } "Action button preset"
    def playground(show_actions: true, show_text: false, action_style: :standard)
      actions = if show_actions
        case action_style.to_sym
        when :standard
          [
            { label: "Cancel", path: "#", style: :secondary },
            { label: "Save", path: "#", style: :primary }
          ]
        when :form
          [
            { label: "Reset", path: "#", style: :secondary },
            { label: "Submit", path: "#", style: :primary, method: :post }
          ]
        when :full
          [
            { label: "Discard", path: "#", style: :danger },
            { label: "Save Draft", path: "#", style: :secondary },
            { label: "Publish", path: "#", style: :primary }
          ]
        end
      end

      text = show_text ? "Last saved: 5 minutes ago" : nil

      render BetterPage::Common::FooterComponent.new(actions: actions, text: text)
    end
  end
end

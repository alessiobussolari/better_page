# frozen_string_literal: true

module Common
  class AlertsComponentPreview < ViewComponent::Preview
    layout "component_preview"

    # Alerts Component
    # ----------------
    # Displays notification messages with different severity levels.
    #
    # **Alert Types:**
    # - `:info` - Informational messages (blue)
    # - `:success` - Success confirmations (green)
    # - `:warning` - Warning notices (yellow)
    # - `:error` - Error messages (red)
    #
    # @label Playground
    # @param type [Symbol] select { choices: [all, info, success, warning, error] } "Alert type to display"
    # @param show_multiple toggle "Show multiple alerts at once"
    def playground(type: :all, show_multiple: false)
      alerts = case type.to_sym
      when :all
        [
          { type: :info, message: "This is an informational message." },
          { type: :success, message: "Operation completed successfully!" },
          { type: :warning, message: "Please review before proceeding." },
          { type: :error, message: "An error occurred. Please try again." }
        ]
      when :info
        base = [{ type: :info, message: "Did you know? You can customize your dashboard settings." }]
        show_multiple ? base + [{ type: :info, message: "New features are available. Check the changelog." }] : base
      when :success
        base = [{ type: :success, message: "Your changes have been saved successfully." }]
        show_multiple ? base + [{ type: :success, message: "Profile updated!" }] : base
      when :warning
        base = [{ type: :warning, message: "Your session will expire in 5 minutes." }]
        show_multiple ? base + [{ type: :warning, message: "Some fields are incomplete." }] : base
      when :error
        base = [{ type: :error, message: "Failed to save changes. Please check your input." }]
        show_multiple ? base + [{ type: :error, message: "Connection lost. Retrying..." }] : base
      end

      render BetterPage::Common::AlertsComponent.new(alerts: alerts)
    end
  end
end

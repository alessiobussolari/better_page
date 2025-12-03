# frozen_string_literal: true

module Common
  class FlashComponentPreview < ViewComponent::Preview
    layout "component_preview"

    # Flash Component
    # ---------------
    # Displays flash notification messages with auto-dismiss capability.
    #
    # **Flash Types:**
    # - `notice` / `success` - Success messages (green)
    # - `alert` / `error` - Error messages (red)
    # - `warning` - Warning messages (yellow)
    # - `info` - Informational messages (blue)
    #
    # @label Playground
    # @param type [Symbol] select { choices: [all, notice, alert, warning, info] } "Flash message type"
    # @param auto_dismiss toggle "Auto-dismiss after delay"
    def playground(type: :all, auto_dismiss: true)
      flash = case type.to_sym
      when :all
        {
          notice: "Your profile has been updated successfully.",
          alert: "Please verify your email address.",
          warning: "Your subscription will expire in 3 days.",
          info: "New features are available. Check the changelog!"
        }
      when :notice
        { notice: "Changes saved successfully!" }
      when :alert
        { alert: "Authentication failed. Please try again." }
      when :warning
        { warning: "Your subscription will expire in 3 days." }
      when :info
        { info: "New features are available. Check the changelog!" }
      end

      render BetterPage::Common::FlashComponent.new(flash: flash, auto_dismiss: auto_dismiss)
    end
  end
end

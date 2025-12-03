# frozen_string_literal: true

module Form
  class ErrorsComponentPreview < ViewComponent::Preview
    layout "component_preview"

    # @label Default
    def default
      render_with_template
    end

    # @label Multiple Errors
    def multiple_errors
      render_with_template
    end
  end
end

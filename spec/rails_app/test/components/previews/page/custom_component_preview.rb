# frozen_string_literal: true

module Page
  class CustomComponentPreview < ViewComponent::Preview
    layout "component_preview"

    # @label Default
    def default
      render_with_template
    end

    # @label Dashboard
    def dashboard
      render_with_template
    end
  end
end

# frozen_string_literal: true

module Form
  class InputComponentPreview < ViewComponent::Preview
    layout "component_preview"

    # @label Default
    def default
      render_with_template
    end

    # @label All Types
    def all_types
      render_with_template
    end

    # @label With Validation
    def with_validation
      render_with_template
    end

    # @label Disabled
    def disabled
      render_with_template
    end
  end
end

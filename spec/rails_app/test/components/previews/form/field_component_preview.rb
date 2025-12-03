# frozen_string_literal: true

module Form
  class FieldComponentPreview < ViewComponent::Preview
    layout "component_preview"

    # @label Default
    def default
      render_with_template
    end

    # @label With Hint
    def with_hint
      render_with_template
    end

    # @label Required
    def required
      render_with_template
    end
  end
end

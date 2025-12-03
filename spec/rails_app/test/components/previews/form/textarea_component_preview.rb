# frozen_string_literal: true

module Form
  class TextareaComponentPreview < ViewComponent::Preview
    layout "component_preview"

    # @label Default
    def default
      render_with_template
    end

    # @label With Placeholder
    def with_placeholder
      render_with_template
    end

    # @label With Error
    def with_error
      render_with_template
    end
  end
end

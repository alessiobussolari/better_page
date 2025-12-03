# frozen_string_literal: true

module Form
  class SelectComponentPreview < ViewComponent::Preview
    layout "component_preview"

    # @label Default
    def default
      render_with_template
    end

    # @label With Prompt
    def with_prompt
      render_with_template
    end

    # @label Multiple
    def multiple
      render_with_template
    end

    # @label With Error
    def with_error
      render_with_template
    end
  end
end

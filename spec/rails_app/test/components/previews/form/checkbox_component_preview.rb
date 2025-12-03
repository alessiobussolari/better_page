# frozen_string_literal: true

module Form
  class CheckboxComponentPreview < ViewComponent::Preview
    layout "component_preview"

    # @label Default
    def default
      render_with_template
    end

    # @label Multiple Checkboxes
    def multiple
      render_with_template
    end

    # @label With Descriptions
    def with_descriptions
      render_with_template
    end
  end
end

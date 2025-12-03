# frozen_string_literal: true

module Form
  class RadioComponentPreview < ViewComponent::Preview
    layout "component_preview"

    # @label Default
    def default
      render_with_template
    end

    # @label With Descriptions
    def with_descriptions
      render_with_template
    end

    # @label Inline
    def inline
      render_with_template
    end
  end
end

# frozen_string_literal: true

module Form
  class PanelComponentPreview < ViewComponent::Preview
    layout "component_preview"

    # @label Default
    def default
      render_with_template
    end

    # @label With Description
    def with_description
      render_with_template
    end

    # @label Multiple Panels
    def multiple_panels
      render_with_template
    end
  end
end

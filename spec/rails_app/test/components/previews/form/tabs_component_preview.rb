# frozen_string_literal: true

module Form
  class TabsComponentPreview < ViewComponent::Preview
    layout "component_preview"

    # @label Default
    def default
      render_with_template
    end

    # @label Multiple Tabs
    def multiple_tabs
      render_with_template
    end
  end
end

# frozen_string_literal: true

module Pages
  class FullLayoutPreview < ViewComponent::Preview
    layout "component_preview"

    # @label Default
    def default
      render_with_template
    end
  end
end

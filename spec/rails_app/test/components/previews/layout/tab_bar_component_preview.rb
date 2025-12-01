# frozen_string_literal: true

module Layout
  class TabBarComponentPreview < ViewComponent::Preview
    layout "component_preview"

    # @label Default
    def default
      render_with_template
    end

    # @label With badges
    def with_badges
      render_with_template
    end

    # @label With dots
    def with_dots
      render_with_template
    end
  end
end

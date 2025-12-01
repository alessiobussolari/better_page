# frozen_string_literal: true

module Layout
  class SidebarComponentPreview < ViewComponent::Preview
    layout "component_preview"

    # @label Default
    def default
      render_with_template
    end

    # @label Collapsed
    def collapsed
      render_with_template
    end

    # @label With groups
    def with_groups
      render_with_template
    end

    # @label With footer
    def with_footer
      render_with_template
    end
  end
end

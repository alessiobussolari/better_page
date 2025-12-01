# frozen_string_literal: true

module Common
  class TabsComponentPreview < ViewComponent::Preview
    layout "component_preview"

    # @label Default
    def default
      render_with_template
    end

    # @label With icons
    def with_icons
      render_with_template
    end

    # @label With links
    def with_links
      render_with_template
    end

    # @label Many tabs
    def many_tabs
      render_with_template
    end

    # @label Default tab selected
    def default_selected
      render_with_template
    end
  end
end

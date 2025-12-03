# frozen_string_literal: true

module Layout
  class TopbarComponentPreview < ViewComponent::Preview
    layout "component_preview"

    # @label Default
    def default
      render_with_template
    end

    # @label With notifications
    def with_notifications
      render_with_template
    end

    # @label With user menu
    def with_user_menu
      render_with_template
    end

    # @label Complete example
    def complete
      render_with_template
    end

    # @label With breadcrumbs
    def with_breadcrumbs
      render_with_template
    end

    # @label With context info
    def with_context_info
      render_with_template
    end
  end
end

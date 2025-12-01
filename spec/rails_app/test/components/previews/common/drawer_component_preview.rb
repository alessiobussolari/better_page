# frozen_string_literal: true

module Common
  class DrawerComponentPreview < ViewComponent::Preview
    layout "component_preview"

    # @label Right (default)
    def default
      render_with_template
    end

    # @label Left
    def left
      render_with_template
    end

    # @label Top
    def top
      render_with_template
    end

    # @label Bottom
    def bottom
      render_with_template
    end

    # @label Large size
    def large
      render_with_template
    end

    # @label With footer actions
    def with_footer_actions
      render_with_template
    end

    # @label With form
    def with_form
      render_with_template
    end

    # @label With Turbo Frame
    def with_turbo_frame
      render_with_template
    end

    # @label With confirm close
    def with_confirm_close
      render_with_template
    end

    # @label Without header
    def without_header
      render_with_template
    end

    # @label All directions
    def all_directions
      render_with_template
    end
  end
end

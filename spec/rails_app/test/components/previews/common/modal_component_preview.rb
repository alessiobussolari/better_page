# frozen_string_literal: true

module Common
  class ModalComponentPreview < ViewComponent::Preview
    layout "component_preview"

    # @label Default
    def default
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

    # @label Confirm dialog
    def confirm_dialog
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
  end
end

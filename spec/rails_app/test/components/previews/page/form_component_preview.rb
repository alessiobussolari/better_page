# frozen_string_literal: true

module Page
  class FormComponentPreview < ViewComponent::Preview
    layout "component_preview"

    # @label Default
    def default
      render_with_template
    end

    # @label Edit Form
    def edit_form
      render_with_template
    end
  end
end

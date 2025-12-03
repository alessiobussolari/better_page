# frozen_string_literal: true

module Common
  class ModalComponentPreview < ViewComponent::Preview
    layout "component_preview"

    # Modal Component
    # ---------------
    # A dialog overlay that appears centered on the screen.
    #
    # **Sizes:**
    # - Default - Standard modal width
    # - `:lg` - Larger modal width
    #
    # **Close Behavior:**
    # - Click backdrop
    # - Press Escape key
    # - Click X button
    # - Optional confirm dialog on close
    #
    # @label Playground
    # @param size [Symbol] select { choices: [default, lg] } "Modal size"
    # @param show_header toggle "Show header with title"
    # @param show_footer toggle "Show footer with actions"
    # @param confirm_close toggle "Confirm before closing"
    # @param is_confirm_dialog toggle "Style as confirmation dialog"
    def playground(
      size: :default,
      show_header: true,
      show_footer: false,
      confirm_close: false,
      is_confirm_dialog: false
    )
      modal_id = "modal-playground"

      if is_confirm_dialog
        render_confirm_dialog(modal_id)
      else
        render BetterPage::Common::ModalComponent.new(
          id: modal_id,
          title: show_header ? "Modal Title" : nil,
          size: size.to_sym == :lg ? :large : :normal,
          confirm_close: confirm_close
        ) do |modal|
          modal.with_trigger do
            trigger_button("Open Modal")
          end

          if show_footer
            modal.with_actions do
              footer_actions
            end
          end

          modal_content
        end
      end
    end

    private

    def render_confirm_dialog(modal_id)
      render BetterPage::Common::ModalComponent.new(
        id: modal_id,
        title: "Confirm Action",
        size: :normal
      ) do |modal|
        modal.with_trigger do
          trigger_button("Delete Item", danger: true)
        end

        modal.with_actions do
          confirm_actions
        end

        <<~HTML.html_safe
          <p class="text-gray-600">Are you sure you want to delete this item? This action cannot be undone.</p>
        HTML
      end
    end

    def trigger_button(text, danger: false)
      bg_class = danger ? "bg-red-600 hover:bg-red-500" : "bg-indigo-600 hover:bg-indigo-500"
      <<~HTML.html_safe
        <button type="button" data-action="click->modal#open" class="rounded-md #{bg_class} px-3.5 py-2.5 text-sm font-semibold text-white shadow-sm">#{text}</button>
      HTML
    end

    def footer_actions
      <<~HTML.html_safe
        <button data-action="click->modal#close" class="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50">Cancel</button>
        <button class="px-4 py-2 text-sm font-medium text-white bg-indigo-600 border border-transparent rounded-md hover:bg-indigo-700">Save</button>
      HTML
    end

    def confirm_actions
      <<~HTML.html_safe
        <button data-action="click->modal#close" class="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50">Cancel</button>
        <button class="px-4 py-2 text-sm font-medium text-white bg-red-600 border border-transparent rounded-md hover:bg-red-700">Delete</button>
      HTML
    end

    def modal_content
      <<~HTML.html_safe
        <p class="text-gray-700">This is the default modal with a title and close button.</p>
        <p class="mt-2 text-gray-500">Click outside or press ESC to close.</p>
      HTML
    end
  end
end

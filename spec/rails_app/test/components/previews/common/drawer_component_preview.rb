# frozen_string_literal: true

module Common
  class DrawerComponentPreview < ViewComponent::Preview
    layout "component_preview"

    # Drawer Component
    # ----------------
    # A slide-in panel that appears from any edge of the screen.
    #
    # **Directions:**
    # - `:right` (default) - Slides from right edge
    # - `:left` - Slides from left edge
    # - `:top` - Slides from top edge
    # - `:bottom` - Slides from bottom edge
    #
    # **Sizes:**
    # - Default - Standard width/height
    # - `:lg` - Larger panel size
    #
    # **Close Behavior:**
    # - Click backdrop
    # - Press Escape key
    # - Click X button
    # - Optional confirm dialog on close
    #
    # @label Playground
    # @param direction [Symbol] select { choices: [right, left, top, bottom] } "Slide direction"
    # @param size [Symbol] select { choices: [default, lg] } "Panel size"
    # @param show_header toggle "Show header with title"
    # @param show_footer toggle "Show footer with actions"
    # @param confirm_close toggle "Confirm before closing"
    def playground(
      direction: :right,
      size: :default,
      show_header: true,
      show_footer: false,
      confirm_close: false
    )
      drawer_id = "drawer-playground"

      render BetterPage::Common::DrawerComponent.new(
        id: drawer_id,
        title: show_header ? "Drawer Title" : nil,
        direction: direction.to_sym,
        size: size.to_sym == :lg ? :large : :normal,
        actions_position: show_footer ? :footer : :header,
        confirm_close: confirm_close
      ) do |drawer|
        drawer.with_trigger do
          trigger_button(direction)
        end

        if show_footer
          drawer.with_actions do
            footer_actions
          end
        end

        drawer_content
      end
    end

    private

    def trigger_button(direction)
      <<~HTML.html_safe
        <button
          data-action="click->drawer#open"
          class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500">
          Open Drawer (#{direction.to_s.capitalize})
        </button>
      HTML
    end

    def footer_actions
      <<~HTML.html_safe
        <button data-action="click->drawer#close" class="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50">Cancel</button>
        <button class="px-4 py-2 text-sm font-medium text-white bg-blue-600 border border-transparent rounded-md hover:bg-blue-700">Save</button>
      HTML
    end

    def drawer_content
      <<~HTML.html_safe
        <p class="text-gray-700">This is a drawer component that slides in from the selected direction.</p>
        <p class="mt-4 text-gray-600">You can close it by:</p>
        <ul class="mt-2 list-disc list-inside text-gray-600">
          <li>Clicking the X button</li>
          <li>Clicking the backdrop</li>
          <li>Pressing the Escape key</li>
        </ul>
      HTML
    end
  end
end

# frozen_string_literal: true

module Common
  class DualComponentPreview < ViewComponent::Preview
    layout "component_preview"

    # Dual Component
    # --------------
    # A two-column layout component with configurable ratios.
    #
    # **Ratio Options:**
    # - `1:2` - Left panel 1/3, right panel 2/3 (default)
    # - `1:1` - Equal split
    # - `2:1` - Left panel 2/3, right panel 1/3
    # - `1:3` - Left panel 1/4, right panel 3/4 (sidebar style)
    #
    # On mobile devices, panels stack vertically.
    #
    # @label Playground
    # @param ratio select { choices: ["1:2", "1:1", "2:1", "1:3"] } "Panel ratio"
    def playground(ratio: "1:2")
      ratio_descriptions = {
        "1:2" => ["1/3 width", "2/3 width"],
        "1:1" => ["1/2 width", "1/2 width"],
        "2:1" => ["2/3 width", "1/3 width"],
        "1:3" => ["1/4 width", "3/4 width"]
      }

      left_desc, right_desc = ratio_descriptions[ratio.to_s] || ["1/3 width", "2/3 width"]

      render BetterPage::Common::DualComponent.new(ratio: ratio.to_s) do |dual|
        dual.with_left_panel do
          panel_content("Left Panel", left_desc, "Navigation item")
        end

        dual.with_right_panel do
          panel_content("Right Panel", right_desc, "Content item")
        end
      end
    end

    private

    def panel_content(title, description, item_prefix)
      <<~HTML.html_safe
        <div class="bg-white p-6 rounded-lg shadow">
          <h3 class="text-lg font-semibold text-gray-900">#{title} (#{description})</h3>
          <p class="mt-2 text-gray-600">This panel takes #{description} on large screens.</p>
          <ul class="mt-4 space-y-2 text-sm text-gray-500">
            <li>#{item_prefix} 1</li>
            <li>#{item_prefix} 2</li>
            <li>#{item_prefix} 3</li>
          </ul>
        </div>
      HTML
    end
  end
end

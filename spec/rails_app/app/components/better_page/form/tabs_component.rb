# frozen_string_literal: true

module BetterPage
  module Form
    class TabsComponent < BetterPage::ApplicationViewComponent
        def initialize(form:, panels:, **options)
          @form = form
          @panels = panels || []
          @options = options
        end

        attr_reader :form, :panels, :options

        def tabs_data
          panels.map.with_index do |panel, index|
            {
              id: "tab-#{index}",
              title: panel[:title],
              icon: panel[:icon],
              panel: panel,
              active: index.zero?,
              index: index
            }
          end
        end

        def panel_with_index(panel, index)
          panel.merge(
            panel_index: index,
            is_last: index == panels.length - 1
          )
        end
    end
  end
end

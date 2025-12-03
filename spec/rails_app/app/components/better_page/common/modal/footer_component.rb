# frozen_string_literal: true

module BetterPage
  module Common
    module Modal
      class FooterComponent < BetterPage::ApplicationViewComponent
        ACTION_STYLES = {
          primary: "bg-blue-600 text-white hover:bg-blue-700 focus:ring-blue-500",
          secondary: "bg-white text-gray-700 border-gray-300 hover:bg-gray-50 focus:ring-blue-500",
          danger: "bg-red-600 text-white hover:bg-red-700 focus:ring-red-500",
          success: "bg-green-600 text-white hover:bg-green-700 focus:ring-green-500"
        }.freeze

        def initialize(actions: [], has_form: false, **options)
          @actions = actions
          @has_form = has_form
          @options = options
        end

        attr_reader :actions, :has_form, :options

        def render?
          actions.present?
        end

        def button_classes(style)
          base = "inline-flex justify-center rounded-md border px-4 py-2 text-sm font-medium shadow-sm focus:outline-none focus:ring-2 focus:ring-offset-2"
          style_class = ACTION_STYLES[style.to_sym] || ACTION_STYLES[:secondary]
          "#{base} #{style_class}"
        end

        def action_type(action)
          action[:action] || :button
        end
      end
    end
  end
end

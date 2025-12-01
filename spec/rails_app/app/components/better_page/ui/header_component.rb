# frozen_string_literal: true

module BetterPage
  module Ui
    class HeaderComponent < BetterPage::ApplicationViewComponent
      def initialize(title:, breadcrumbs: [], actions: [], metadata: [])
        @title = title
        @breadcrumbs = breadcrumbs
        @actions = actions
        @metadata = metadata
      end

      attr_reader :title, :breadcrumbs, :actions, :metadata

      def breadcrumbs? = breadcrumbs.any?
      def actions? = actions.any?
      def metadata? = metadata.any?

      def action_classes(style)
        base = "inline-flex items-center rounded-md px-3 py-2 text-sm font-semibold shadow-sm ring-1 ring-inset transition-colors focus:outline-none focus:ring-2 focus:ring-offset-2"

        case style&.to_sym
        when :primary
          "#{base} bg-blue-600 text-white ring-blue-600 hover:bg-blue-700 focus:ring-blue-500"
        when :secondary
          "#{base} bg-white text-gray-900 ring-gray-300 hover:bg-gray-50 focus:ring-blue-500"
        when :danger
          "#{base} bg-red-600 text-white ring-red-600 hover:bg-red-700 focus:ring-red-500"
        when :success
          "#{base} bg-green-600 text-white ring-green-600 hover:bg-green-700 focus:ring-green-500"
        when :warning
          "#{base} bg-yellow-600 text-white ring-yellow-600 hover:bg-yellow-700 focus:ring-yellow-500"
        else
          "#{base} bg-white text-gray-900 ring-gray-300 hover:bg-gray-50 focus:ring-blue-500"
        end
      end
    end
  end
end

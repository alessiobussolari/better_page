# frozen_string_literal: true

module BetterPage
  module Ui
    class HeaderComponent < ViewComponent::Base
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
        base = "inline-flex items-center px-4 py-2 border text-sm font-medium rounded-md focus:outline-none focus:ring-2 focus:ring-offset-2"

        case style&.to_sym
        when :primary
          "#{base} border-transparent text-white bg-indigo-600 hover:bg-indigo-700 focus:ring-indigo-500"
        when :secondary
          "#{base} border-gray-300 text-gray-700 bg-white hover:bg-gray-50 focus:ring-indigo-500"
        when :danger
          "#{base} border-transparent text-white bg-red-600 hover:bg-red-700 focus:ring-red-500"
        else
          "#{base} border-gray-300 text-gray-700 bg-white hover:bg-gray-50 focus:ring-indigo-500"
        end
      end
    end
  end
end

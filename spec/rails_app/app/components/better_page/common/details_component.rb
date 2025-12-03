# frozen_string_literal: true

module BetterPage
  module Common
    class DetailsComponent < BetterPage::ApplicationViewComponent
      def initialize(items: [], title: nil, description: nil, columns: 2, enabled: true, **options)
        @items = items || []
        @title = title
        @description = description
        @columns = columns
        @enabled = enabled
        @options = options
      end

      attr_reader :items, :title, :description, :columns, :enabled, :options

      def render?
        enabled && items.any?
      end

      def grid_classes
        case columns
        when 1
          "grid-cols-1"
        when 3
          "grid-cols-1 sm:grid-cols-2 lg:grid-cols-3"
        when 4
          "grid-cols-1 sm:grid-cols-2 lg:grid-cols-4"
        else
          "grid-cols-1 sm:grid-cols-2"
        end
      end
    end
  end
end

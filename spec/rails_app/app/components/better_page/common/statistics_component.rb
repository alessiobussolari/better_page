# frozen_string_literal: true

module BetterPage
  module Common
    class StatisticsComponent < BetterPage::ApplicationViewComponent
      def initialize(statistics: [], columns: 4, **options)
        @statistics = statistics || []
        @columns = columns
        @options = options
      end

      attr_reader :statistics, :columns, :options

      def render?
        statistics.present?
      end

      def grid_classes
        case columns
        when 1 then "grid-cols-1"
        when 2 then "grid-cols-1 sm:grid-cols-2"
        when 3 then "grid-cols-1 sm:grid-cols-2 lg:grid-cols-3"
        when 4 then "grid-cols-1 sm:grid-cols-2 lg:grid-cols-4"
        else "grid-cols-1 sm:grid-cols-2 lg:grid-cols-4"
        end
      end

      def trend_classes(stat)
        trend = stat[:trend] || stat[:change_type]
        case trend.to_s
        when "up", "positive", "increase"
          "bg-green-100 text-green-800"
        when "down", "negative", "decrease"
          "bg-red-100 text-red-800"
        else
          "bg-gray-100 text-gray-800"
        end
      end

      def trend_icon(stat)
        trend = stat[:trend] || stat[:change_type]
        case trend.to_s
        when "up", "positive", "increase"
          "↑"
        when "down", "negative", "decrease"
          "↓"
        else
          ""
        end
      end
    end
  end
end

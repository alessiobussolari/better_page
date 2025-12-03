# frozen_string_literal: true

module Common
  class StatisticsComponentPreview < ViewComponent::Preview
    layout "component_preview"

    # Statistics Component
    # --------------------
    # Displays metrics and KPIs in a configurable grid.
    #
    # **Trend Indicators:**
    # - `:up` / `:positive` - Green upward arrow
    # - `:down` / `:negative` - Red downward arrow
    # - `:neutral` - Gray indicator
    #
    # **Statistic Options:**
    # - `label` - Metric name
    # - `value` - Metric value
    # - `unit` - Optional unit suffix (%, GB, etc.)
    # - `change` - Change from previous period
    # - `trend` - Trend direction indicator
    # - `description` - Additional context
    # - `icon` - Optional SVG icon
    #
    # @label Playground
    # @param columns [Integer] select { choices: [1, 2, 3, 4] } "Grid columns"
    # @param show_trends toggle "Show trend indicators"
    # @param show_descriptions toggle "Show descriptions"
    # @param show_units toggle "Show units (%, GB, etc.)"
    def playground(columns: 4, show_trends: true, show_descriptions: false, show_units: false)
      statistics = if show_units
        [
          { label: "CPU Usage", value: "45", unit: "%", change: show_trends ? "+5%" : nil, trend: show_trends ? :up : nil },
          { label: "Memory", value: "2.4", unit: "GB", change: show_trends ? "-0.2 GB" : nil, trend: show_trends ? :down : nil },
          { label: "Storage", value: "128", unit: "GB", description: show_descriptions ? "256 GB total" : nil },
          { label: "Bandwidth", value: "1.2", unit: "TB/mo", change: show_trends ? "+0.3 TB" : nil, trend: show_trends ? :up : nil }
        ]
      else
        [
          {
            label: "Total Revenue",
            value: "$125,430",
            change: show_trends ? "+15%" : nil,
            trend: show_trends ? :up : nil,
            description: show_descriptions ? "Compared to last month" : nil
          },
          {
            label: "New Customers",
            value: "243",
            change: show_trends ? "+18%" : nil,
            trend: show_trends ? :up : nil,
            description: show_descriptions ? "From 206 last month" : nil
          },
          {
            label: "Orders",
            value: "1,429",
            change: show_trends ? "+8%" : nil,
            trend: show_trends ? :up : nil,
            description: show_descriptions ? "Avg. $87.80 per order" : nil
          },
          {
            label: "Refunds",
            value: "12",
            change: show_trends ? "-0.8%" : nil,
            trend: show_trends ? :down : nil,
            description: show_descriptions ? "Target: < 1%" : nil
          }
        ]
      end

      # Adjust statistics count based on columns
      statistics = statistics.first(columns.to_i) if columns.to_i < 4

      render BetterPage::Common::StatisticsComponent.new(
        statistics: statistics,
        columns: columns.to_i
      )
    end
  end
end

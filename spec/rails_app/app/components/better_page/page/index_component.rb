# frozen_string_literal: true

module BetterPage
  module Page
    class IndexComponent < BetterPage::ApplicationViewComponent
        def initialize(header:, alerts: nil, statistics: nil, details: nil,
                       calendar: nil, tabs: nil, search: nil, split_view: nil, table: nil,
                       pagination: nil, footer: nil, **options)
          @header = header
          @alerts = alerts
          @statistics = statistics
          @details = details
          @calendar = calendar
          @tabs = tabs
          @search = search
          @split_view = split_view
          @table = table
          @pagination = pagination
          @footer = footer
          @options = options
        end

        attr_reader :header, :alerts, :statistics, :details, :calendar,
                    :tabs, :search, :split_view, :table, :pagination, :footer, :options

        def should_render_header?
          header.present?
        end

        def should_render_alerts?
          alerts.present?
        end

        def should_render_statistics?
          statistics.present?
        end

        def should_render_details?
          details.present? && details[:enabled] != false
        end

        def should_render_calendar?
          calendar.present? && calendar[:enabled] != false
        end

        def should_render_tabs?
          tabs.present? && tabs[:enabled] != false
        end

        def should_render_search?
          search.present? && search[:enabled] != false
        end

        def should_render_split_view?
          split_view.present? && split_view[:enabled] != false
        end

        def should_render_table?
          table.present? && table[:enabled] != false
        end

        def should_render_pagination?
          pagination.present? && pagination[:enabled] != false
        end

        def should_render_footer?
          footer.present? && footer[:enabled] != false
        end
    end
  end
end

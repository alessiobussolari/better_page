# frozen_string_literal: true

module BetterPage
  module Page
    class ShowComponent < BetterPage::ApplicationViewComponent
        def initialize(show_header:, show_alerts: [], show_statistics: [], show_details: nil, show_footer: nil, **options)
          @show_header = show_header
          @show_alerts = show_alerts || []
          @show_statistics = show_statistics || []
          @show_details = show_details
          @show_footer = show_footer
          @options = options
        end

        attr_reader :show_header, :show_alerts, :show_statistics, :show_details, :show_footer, :options

        def should_render_header?
          show_header.present?
        end

        def should_render_alerts?
          show_alerts.present? && show_alerts.any?
        end

        def should_render_statistics?
          show_statistics.present? && show_statistics.any?
        end

        def should_render_details?
          show_details.present? && show_details[:enabled]
        end

        def should_render_footer?
          show_footer.present? && show_footer[:enabled]
        end
    end
  end
end

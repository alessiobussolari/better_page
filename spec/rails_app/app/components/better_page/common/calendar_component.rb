# frozen_string_literal: true

module BetterPage
  module Common
    class CalendarComponent < BetterPage::ApplicationViewComponent
        VIEWS = %i[month week day].freeze

        def initialize(enabled: true, view: :month, current_date: nil, events: [],
                       previous_path: nil, next_path: nil, today_path: nil, **options)
          @enabled = enabled
          @view = view.to_sym
          @current_date = current_date || Date.current
          @events = events || []
          @previous_path = previous_path
          @next_path = next_path
          @today_path = today_path
          @options = options
        end

        attr_reader :enabled, :view, :current_date, :events, :previous_path,
                    :next_path, :today_path, :options

        def render?
          enabled
        end

        def month_view?
          view == :month
        end

        def week_view?
          view == :week
        end

        def day_view?
          view == :day
        end

        def formatted_title
          case view
          when :month
            current_date.strftime("%B %Y")
          when :week
            start_of_week = current_date.beginning_of_week
            end_of_week = current_date.end_of_week
            "#{start_of_week.strftime('%b %d')} - #{end_of_week.strftime('%b %d, %Y')}"
          when :day
            current_date.strftime("%A, %B %d, %Y")
          end
        end
      end
  end
end

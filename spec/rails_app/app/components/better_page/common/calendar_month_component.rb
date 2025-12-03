# frozen_string_literal: true

module BetterPage
  module Common
    class CalendarMonthComponent < BetterPage::ApplicationViewComponent
        DAYS_OF_WEEK = %w[Sun Mon Tue Wed Thu Fri Sat].freeze

        def initialize(current_date:, events: [], **options)
          @current_date = current_date
          @events = events || []
          @options = options
        end

        attr_reader :current_date, :events, :options

        def days_in_month
          start_date = current_date.beginning_of_month.beginning_of_week
          end_date = current_date.end_of_month.end_of_week

          (start_date..end_date).map do |date|
            {
              date: date,
              day: date.day,
              is_current_month: date.month == current_date.month,
              is_today: date == Date.current,
              events: events_for_date(date)
            }
          end
        end

        def events_for_date(date)
          events.select do |event|
            event_date = event[:date] || event[:start_date]
            event_date&.to_date == date
          end
        end
      end
  end
end

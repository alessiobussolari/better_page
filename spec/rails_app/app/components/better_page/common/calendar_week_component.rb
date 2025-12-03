# frozen_string_literal: true

module BetterPage
  module Common
    class CalendarWeekComponent < BetterPage::ApplicationViewComponent
        HOURS = (0..23).to_a.freeze

        def initialize(current_date:, events: [], start_hour: 8, end_hour: 20, **options)
          @current_date = current_date
          @events = events || []
          @start_hour = start_hour
          @end_hour = end_hour
          @options = options
        end

        attr_reader :current_date, :events, :start_hour, :end_hour, :options

        def days_of_week
          start_of_week = current_date.beginning_of_week
          (0..6).map do |i|
            date = start_of_week + i.days
            {
              date: date,
              name: date.strftime("%a"),
              day: date.day,
              is_today: date == Date.current,
              events: events_for_date(date)
            }
          end
        end

        def visible_hours
          (start_hour..end_hour).to_a
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

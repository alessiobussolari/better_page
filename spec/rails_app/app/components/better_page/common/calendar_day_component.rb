# frozen_string_literal: true

module BetterPage
  module Common
    class CalendarDayComponent < BetterPage::ApplicationViewComponent
      def initialize(current_date:, events: [], **options)
        @current_date = current_date
        @events = events || []
        @options = options
      end

      attr_reader :current_date, :events, :options

      def visible_hours
        (8..20).to_a
      end

      def events_for_hour(hour)
        events.select do |e|
          event_time = e[:start_time] || e[:time]
          next false unless event_time
          event_hour = event_time.respond_to?(:hour) ? event_time.hour : event_time.to_s.split(':').first.to_i
          event_hour == hour
        end
      end
    end
  end
end

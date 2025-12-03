# frozen_string_literal: true

module Common
  class CalendarComponentPreview < ViewComponent::Preview
    layout "component_preview"

    # Calendar Component
    # ------------------
    # Displays a calendar with events in different view modes.
    #
    # **View Types:**
    # - `:month` - Monthly calendar grid with event indicators
    # - `:week` - Weekly view with time slots
    # - `:day` - Daily schedule with event durations
    #
    # **Event Colors:**
    # - `:blue`, `:red`, `:green`, `:purple`, `:yellow`, `:gray`
    #
    # @label Playground
    # @param view [Symbol] select { choices: [month, week, day] } "Calendar view type"
    # @param show_events toggle "Display sample events"
    def playground(view: :month, show_events: true)
      events = if show_events
        case view.to_sym
        when :month
          [
            { date: Date.current, title: "Team Meeting", color: :blue },
            { date: Date.current + 2.days, title: "Project Deadline", color: :red },
            { date: Date.current + 5.days, title: "Client Call", color: :green },
            { date: Date.current + 7.days, title: "Review Session", color: :purple }
          ]
        when :week
          [
            { date: Date.current, time: "09:00", title: "Standup", color: :blue },
            { date: Date.current, time: "14:00", title: "Design Review", color: :purple },
            { date: Date.current + 1.day, time: "10:00", title: "Client Meeting", color: :green },
            { date: Date.current + 2.days, time: "15:00", title: "Sprint Planning", color: :yellow }
          ]
        when :day
          [
            { time: "09:00", title: "Morning Standup", duration: 30, color: :blue },
            { time: "10:00", title: "Code Review", duration: 60, color: :purple },
            { time: "12:00", title: "Lunch Break", duration: 60, color: :gray },
            { time: "14:00", title: "Client Presentation", duration: 90, color: :green },
            { time: "16:00", title: "Team Retrospective", duration: 60, color: :yellow }
          ]
        end
      else
        []
      end

      render BetterPage::Common::CalendarComponent.new(
        view: view.to_sym,
        current_date: Date.current,
        events: events,
        previous_path: "#prev",
        next_path: "#next",
        today_path: "#today"
      )
    end
  end
end

# frozen_string_literal: true

module BetterPage
  module Common
    class AlertsComponent < BetterPage::ApplicationViewComponent
        ALERT_STYLES = {
          info: { bg: "bg-blue-50", border: "border-blue-400", text: "text-blue-800", icon: "information-circle" },
          success: { bg: "bg-green-50", border: "border-green-400", text: "text-green-800", icon: "check-circle" },
          warning: { bg: "bg-yellow-50", border: "border-yellow-400", text: "text-yellow-800", icon: "exclamation-triangle" },
          error: { bg: "bg-red-50", border: "border-red-400", text: "text-red-800", icon: "exclamation-circle" }
        }.freeze

        def initialize(alerts: [], **options)
          @alerts = alerts || []
          @options = options
        end

        attr_reader :alerts, :options

        def render?
          alerts.present?
        end

        def alert_classes(type)
          config = ALERT_STYLES[type.to_sym] || ALERT_STYLES[:info]
          "#{config[:bg]} #{config[:border]} #{config[:text]} border-l-4 p-4 mb-4"
        end

        def alert_icon(type)
          config = ALERT_STYLES[type.to_sym] || ALERT_STYLES[:info]
          config[:icon]
        end
      end
  end
end

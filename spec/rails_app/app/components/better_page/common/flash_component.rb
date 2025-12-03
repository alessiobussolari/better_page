# frozen_string_literal: true

module BetterPage
  module Common
    class FlashComponent < BetterPage::ApplicationViewComponent
      FLASH_TYPES = {
        notice: {
          bg: "bg-green-50",
          border: "border-green-400",
          text: "text-green-800",
          icon: "check-circle"
        },
        success: {
          bg: "bg-green-50",
          border: "border-green-400",
          text: "text-green-800",
          icon: "check-circle"
        },
        alert: {
          bg: "bg-red-50",
          border: "border-red-400",
          text: "text-red-800",
          icon: "exclamation-circle"
        },
        error: {
          bg: "bg-red-50",
          border: "border-red-400",
          text: "text-red-800",
          icon: "exclamation-circle"
        },
        warning: {
          bg: "bg-yellow-50",
          border: "border-yellow-400",
          text: "text-yellow-800",
          icon: "exclamation-triangle"
        },
        info: {
          bg: "bg-blue-50",
          border: "border-blue-400",
          text: "text-blue-800",
          icon: "information-circle"
        }
      }.freeze

      def initialize(flash: {}, auto_dismiss: true, dismiss_after: 5000, **options)
        @flash = flash
        @auto_dismiss = auto_dismiss
        @dismiss_after = dismiss_after
        @options = options
      end

      attr_reader :flash, :auto_dismiss, :dismiss_after, :options

      def render?
        flash.present? && flash.any? { |_, message| message.present? }
      end

      def flash_config(type)
        FLASH_TYPES[type.to_sym] || FLASH_TYPES[:info]
      end

      def flash_classes(type)
        config = flash_config(type)
        "#{config[:bg]} #{config[:border]} #{config[:text]} border-l-4 p-4 mb-4"
      end

      def icon_name(type)
        flash_config(type)[:icon]
      end
    end
  end
end

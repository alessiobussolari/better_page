# frozen_string_literal: true

module BetterPage
  module Layout
    class TabBarComponent < BetterPage::ApplicationViewComponent
      renders_many :tabs, "TabBarItem"

      # Stile tab bar interna (sempre con sfondo bianco)
      TAB_BAR_CLASSES = "rounded-xl bg-white/95 backdrop-blur-sm shadow"

      def initialize(id: "mobile-nav", hide_on_desktop: true)
        @id = id
        @hide_on_desktop = hide_on_desktop
      end

      attr_reader :id, :hide_on_desktop

      def hide_on_desktop? = hide_on_desktop

      # Contenitore esterno trasparente con padding
      def wrapper_classes
        base = "fixed bottom-0 left-0 right-0 z-50 p-2"
        hide_on_desktop? ? "#{base} md:hidden" : base
      end

      # Tab bar interna con sfondo bianco
      def tab_bar_classes
        "w-full #{TAB_BAR_CLASSES}"
      end

      class TabBarItem < BetterPage::ApplicationViewComponent
        def initialize(id:, label:, href: "#", icon: nil, active_icon: nil, active: false, badge: nil, dot: false)
          @id = id
          @label = label
          @href = href
          @icon = icon
          @active_icon = active_icon || icon
          @active = active
          @badge = badge
          @dot = dot
        end

        attr_reader :id, :label, :href, :icon, :active_icon, :active, :badge, :dot

        def icon? = icon.present?
        def active? = active
        def badge? = badge.present?
        def dot? = dot

        def current_icon
          active? ? active_icon : icon
        end

        def item_classes
          base = "flex flex-col items-center justify-center flex-1 py-2 px-1 transition-colors"
          if active?
            "#{base} text-blue-600"
          else
            "#{base} text-gray-500 hover:text-gray-700"
          end
        end

        def label_classes
          base = "text-xs mt-1 font-medium"
          active? ? "#{base} text-blue-600" : "#{base} text-gray-500"
        end

        def call
          content
        end
      end
    end
  end
end

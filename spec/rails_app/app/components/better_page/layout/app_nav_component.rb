# frozen_string_literal: true

module BetterPage
  module Layout
    class AppNavComponent < BetterPage::ApplicationViewComponent
      renders_one :brand
      renders_many :notifications, "NotificationItem"
      renders_one :user_menu, "UserMenu"

      # Stile nav interna (sempre con sfondo bianco)
      NAV_CLASSES = "rounded-xl bg-white/95 backdrop-blur-sm shadow"

      def initialize(id: "main-nav", sticky: true)
        @id = id
        @sticky = sticky
      end

      attr_reader :id, :sticky

      def sticky? = sticky

      # Contenitore esterno trasparente con padding
      def wrapper_classes
        base = "w-full p-2 overflow-visible"
        sticky? ? "#{base} sticky top-0 z-40" : base
      end

      # Nav interna con sfondo bianco
      def nav_classes
        "w-full #{NAV_CLASSES}"
      end

      class NotificationItem < BetterPage::ApplicationViewComponent
        def initialize(id:, icon: nil, badge: nil, href: "#")
          @id = id
          @icon = icon
          @badge = badge
          @href = href
        end

        attr_reader :id, :icon, :badge, :href

        def icon? = icon.present?
        def badge? = badge.present?

        def call
          content
        end
      end

      class UserMenu < BetterPage::ApplicationViewComponent
        renders_many :menu_items, "MenuItem"

        def initialize(name: nil, email: nil, avatar: nil)
          @name = name
          @email = email
          @avatar = avatar
        end

        attr_reader :name, :email, :avatar

        def name? = name.present?
        def email? = email.present?
        def avatar? = avatar.present?

        def initials
          return "" unless name?

          name.split.map { |n| n[0] }.join.upcase[0..1]
        end

        def call
          content
        end

        class MenuItem < BetterPage::ApplicationViewComponent
          def initialize(id:, label:, href: "#", icon: nil, destructive: false)
            @id = id
            @label = label
            @href = href
            @icon = icon
            @destructive = destructive
          end

          attr_reader :id, :label, :href, :icon, :destructive

          def icon? = icon.present?
          def destructive? = destructive

          def item_classes
            base = "flex items-center gap-2 w-full px-4 py-2 text-sm transition-colors"
            if destructive?
              "#{base} text-red-600 hover:bg-red-50"
            else
              "#{base} text-gray-700 hover:bg-gray-100"
            end
          end

          def call
            content
          end
        end
      end
    end
  end
end

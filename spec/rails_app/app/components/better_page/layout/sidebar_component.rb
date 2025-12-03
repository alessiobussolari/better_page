# frozen_string_literal: true

module BetterPage
  module Layout
    class SidebarComponent < BetterPage::ApplicationViewComponent
      renders_one :header
      renders_one :footer
      renders_many :items, "SidebarItem"
      renders_many :groups, "SidebarGroup"

      # Stile sidebar interna (sempre con sfondo bianco)
      SIDEBAR_CLASSES = "rounded-xl bg-white shadow"

      def initialize(id: "main-sidebar", collapsed: false, persist_state: true,
                     brand: nil, brand_icon: nil, collapsible: true)
        @id = id
        @collapsed = collapsed
        @persist_state = persist_state
        @brand = brand
        @brand_icon = brand_icon
        @collapsible = collapsible
      end

      attr_reader :id, :collapsed, :persist_state, :brand, :brand_icon, :collapsible

      def collapsed? = collapsed
      def persist_state? = persist_state
      def brand? = brand.present?
      def brand_icon? = brand_icon.present?
      def collapsible? = collapsible

      # Contenitore esterno trasparente con padding
      def wrapper_classes
        "hidden md:block p-2 h-full"
      end

      # Sidebar interna con sfondo bianco
      def sidebar_classes
        "flex flex-col h-full transition-all duration-300 #{SIDEBAR_CLASSES}"
      end

      def width_classes
        collapsed? ? "w-16" : "w-64"
      end

      # Raggruppa gli items per group_id
      def items_for_group(group_id)
        items.select { |item| item.group_id == group_id }
      end

      # Items senza gruppo
      def standalone_items
        items.select { |item| item.group_id.nil? }
      end

      class SidebarItem < BetterPage::ApplicationViewComponent
        def initialize(id:, label:, href: "#", icon: nil, active: false, badge: nil, group_id: nil)
          @id = id
          @label = label
          @href = href
          @icon = icon
          @active = active
          @badge = badge
          @group_id = group_id
        end

        attr_reader :id, :label, :href, :icon, :active, :badge, :group_id

        def icon? = icon.present? || content?
        def active? = active
        def badge? = badge.present?

        def item_classes
          base = "flex items-center gap-3 px-3 py-2 rounded-lg text-sm font-medium transition-colors"
          if active?
            "#{base} bg-blue-50 text-blue-700"
          else
            "#{base} text-gray-700 hover:bg-gray-100"
          end
        end

        # Renderizza icona FontAwesome
        def render_icon
          return nil unless icon.present?

          tag.i(class: icon)
        end

        def call
          content
        end
      end

      # SidebarGroup definisce solo l'intestazione del gruppo
      # Gli items vengono associati tramite group_id
      class SidebarGroup < BetterPage::ApplicationViewComponent
        def initialize(id:, label:, icon: nil, expanded: true)
          @id = id
          @label = label
          @icon = icon
          @expanded = expanded
        end

        attr_reader :id, :label, :icon, :expanded

        def icon? = icon.present?
        def expanded? = expanded

        def call
          content
        end
      end
    end
  end
end

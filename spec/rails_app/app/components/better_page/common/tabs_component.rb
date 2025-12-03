# frozen_string_literal: true

module BetterPage
  module Common
    class TabsComponent < BetterPage::ApplicationViewComponent
      renders_many :tabs, "TabItem"

      STYLE_CONFIG = {
        nav: "border-b border-gray-200",
        tab_base: "-mb-px inline-flex items-center gap-2 px-4 py-2 text-sm font-medium transition-colors",
        active: "border-b-2 border-blue-600 text-blue-600",
        inactive: "border-b-2 border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700"
      }.freeze

      def initialize(id:, default_tab: nil)
        @id = id
        @default_tab = default_tab
      end

      attr_reader :id, :default_tab

      def default_tab_id
        content_tabs = tabs.reject(&:link?)
        @default_tab || content_tabs.first&.id
      end

      def default_index
        content_tabs = tabs.reject(&:link?)
        return 0 if @default_tab.nil? || content_tabs.empty?

        content_tabs.find_index { |tab| tab.id == @default_tab } || 0
      end

      def content_tabs
        tabs.reject(&:link?)
      end

      def nav_classes
        "flex #{STYLE_CONFIG[:nav]}"
      end

      def tab_base_classes
        STYLE_CONFIG[:tab_base]
      end

      def active_classes
        STYLE_CONFIG[:active]
      end

      def inactive_classes
        STYLE_CONFIG[:inactive]
      end

      # Nested TabItem component
      class TabItem < BetterPage::ApplicationViewComponent
        def initialize(id:, label:, icon: nil, href: nil, active: false)
          @id = id
          @label = label
          @icon = icon
          @href = href
          @active = active
        end

        attr_reader :id, :label, :icon, :href, :active

        def icon? = icon.present?
        def link? = href.present?
        def active? = active

        def call
          content
        end
      end
    end
  end
end

# frozen_string_literal: true

module BetterPage
  module Layout
    class AppLayoutComponent < BetterPage::ApplicationViewComponent
      renders_one :sidebar, SidebarComponent
      renders_one :topbar, TopbarComponent
      renders_one :dock, DockComponent

      def initialize(id: "app-layout", sidebar_collapsed: false)
        @id = id
        @sidebar_collapsed = sidebar_collapsed
      end

      attr_reader :id, :sidebar_collapsed

      def sidebar_collapsed? = sidebar_collapsed
      def sidebar? = sidebar.present?
      def topbar? = topbar.present?
      def dock? = dock.present?

      # Classi per il content che si adattano alla sidebar
      def content_classes
        base = "flex-1 min-h-screen transition-all duration-300"
        if sidebar?
          sidebar_collapsed? ? "#{base} md:ml-20" : "#{base} md:ml-68"
        else
          base
        end
      end

      # Padding bottom per il dock mobile
      def main_classes
        base = "p-2"
        dock? ? "#{base} pb-20 md:pb-2" : base
      end
    end
  end
end

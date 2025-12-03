# frozen_string_literal: true

module BetterPage
  module Common
    class ModalComponent < BetterPage::ApplicationViewComponent
      renders_one :trigger
      renders_one :actions

      SIZES = {
        normal: "max-w-md",
        large: "max-w-2xl"
      }.freeze

      def initialize(id:, title: nil, size: :normal, closable: true, actions_position: :footer, confirm_close: false)
        @id = id
        @title = title
        @size = size.to_sym
        @closable = closable
        @actions_position = actions_position.to_sym
        @confirm_close = confirm_close
      end

      attr_reader :id, :title, :size, :closable, :actions_position, :confirm_close

      def closable?
        @closable
      end

      def title?
        title.present?
      end

      def show_header?
        title? || closable?
      end

      def header_actions?
        actions? && actions_position == :header
      end

      def footer_actions?
        actions? && actions_position == :footer
      end

      def size_class
        SIZES.fetch(size, SIZES[:normal])
      end

      def panel_classes
        "relative transform overflow-hidden rounded-lg bg-white text-left shadow-xl transition-all sm:my-8 sm:w-full #{size_class}"
      end
    end
  end
end

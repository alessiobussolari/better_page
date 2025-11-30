# frozen_string_literal: true

module BetterPage
  module Ui
    class DrawerComponent < ViewComponent::Base
      renders_one :trigger
      renders_one :actions

      def initialize(id:, size: :normal, direction: :right, title: nil,
                     closable: true, actions_position: :header, confirm_close: false)
        @id = id
        @size = size.to_sym
        @direction = direction.to_sym
        @title = title
        @closable = closable
        @actions_position = actions_position&.to_sym
        @confirm_close = confirm_close
      end

      attr_reader :id, :size, :direction, :title, :closable, :actions_position, :confirm_close

      def closable? = closable
      def title? = title.present?

      def header_actions?
        actions_position == :header && actions?
      end

      def footer_actions?
        actions_position == :footer && actions?
      end

      def show_header?
        title? || closable? || header_actions?
      end

      def panel_position_class
        case direction
        when :right then "pointer-events-none fixed inset-y-0 right-0 pl-10 max-w-full flex"
        when :left then "pointer-events-none fixed inset-y-0 left-0 pr-10 max-w-full flex"
        when :top then "pointer-events-none fixed inset-x-0 top-0 pb-10 max-h-full flex"
        when :bottom then "pointer-events-none fixed inset-x-0 bottom-0 pt-10 max-h-full flex"
        end
      end

      def panel_size_class
        horizontal = [:left, :right].include?(direction)
        case size
        when :large
          horizontal ? "max-w-2xl w-screen" : "max-h-[80vh]"
        else # normal
          horizontal ? "max-w-md w-screen" : "max-h-[50vh]"
        end
      end

      def panel_classes
        base = "pointer-events-auto bg-white shadow-xl"
        case direction
        when :left, :right then "#{base} w-full h-full"
        when :top, :bottom then "#{base} w-full"
        end
      end

      def initial_transform_class
        case direction
        when :right then "translate-x-full"
        when :left then "-translate-x-full"
        when :top then "-translate-y-full"
        when :bottom then "translate-y-full"
        end
      end
    end
  end
end

# frozen_string_literal: true

module BetterPage
  module Ui
    class TableComponent < BetterPage::ApplicationViewComponent
      def initialize(items:, columns:, row_actions: nil, empty_state: nil,
                     selectable: false, row_link: nil, actions_display: :inline)
        @items = items
        @columns = columns
        @row_actions = row_actions
        @empty_state = empty_state
        @selectable = selectable
        @row_link = row_link
        @actions_display = actions_display&.to_sym || :inline
      end

      attr_reader :items, :columns, :row_actions, :empty_state, :selectable,
                  :row_link, :actions_display

      def items? = items.any?
      def row_actions? = row_actions.present?
      def empty_state? = empty_state.present?
      def selectable? = selectable
      def row_link? = row_link.present?
      def dropdown_actions? = actions_display == :dropdown
      def inline_actions? = actions_display == :inline

      def link_for(item)
        return nil unless row_link
        row_link.respond_to?(:call) ? row_link.call(item) : row_link
      end

      def format_value(item, column)
        value = item.respond_to?(column[:key]) ? item.send(column[:key]) : item[column[:key]]

        case column[:format]&.to_sym
        when :currency
          number_to_currency(value)
        when :date
          value&.strftime("%B %d, %Y")
        when :datetime
          value&.strftime("%B %d, %Y %H:%M")
        when :boolean
          value ? "Yes" : "No"
        when :percentage
          "#{value}%"
        else
          value
        end
      end

      def actions_for(item)
        return [] unless row_actions

        if row_actions.respond_to?(:call)
          row_actions.call(item)
        else
          row_actions
        end
      end

      def action_link_class(style)
        case style&.to_sym
        when :danger
          "text-red-600 hover:text-red-900"
        when :primary
          "text-indigo-600 hover:text-indigo-900"
        else
          "text-gray-600 hover:text-gray-900"
        end
      end

      def action_dropdown_class(style)
        base = "block w-full text-left px-4 py-2 text-sm hover:bg-gray-100"
        color = case style&.to_sym
                when :danger then "text-red-600"
                when :primary then "text-indigo-600"
                else "text-gray-700"
                end
        "#{base} #{color}"
      end

      def item_id(item)
        item.respond_to?(:id) ? item.id : item[:id]
      end
    end
  end
end

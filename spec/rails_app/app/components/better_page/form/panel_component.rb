# frozen_string_literal: true

module BetterPage
  module Form
    class PanelComponent < BetterPage::ApplicationViewComponent
        def initialize(form:, fields:, title: nil, icon: nil, color: nil, panel_index: 0, is_last: false, **options)
          @form = form
          @fields = fields || []
          @title = title
          @icon = icon
          @color = color || "blue"
          @panel_index = panel_index
          @is_last = is_last
          @options = options
        end

        attr_reader :form, :fields, :title, :icon, :color, :panel_index, :is_last, :options

        alias panel_title title
        alias panel_icon icon
        alias panel_color color
        alias panel_fields fields

        def has_title?
          title.present?
        end

        def has_fields?
          fields.present? && fields.any?
        end

        def is_last_panel?
          is_last
        end
    end
  end
end

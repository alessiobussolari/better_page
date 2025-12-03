# frozen_string_literal: true

module BetterPage
  module Form
    class RadioComponent < BetterPage::ApplicationViewComponent
        def initialize(form:, field_name:, options_list:, selected: nil, disabled: false,
                       required: false, error: nil, inline: false, html_data: {}, html_options: {}, **opts)
          @form = form
          @field_name = field_name
          @options_list = options_list
          @selected = selected
          @disabled = disabled
          @required = required
          @error = error
          @inline = inline
          @html_data = html_data
          @html_options = html_options
          @opts = opts
        end

        attr_reader :form, :field_name, :options_list, :selected, :disabled, :required,
                    :error, :inline, :html_data, :html_options, :opts

        def radio_options(value)
          options = {
            disabled: disabled,
            required: required,
            checked: selected.to_s == value.to_s,
            class: radio_classes
          }

          html_data.each do |key, val|
            options[:"data-#{key}"] = val
          end

          options.merge(html_options)
        end

        def radio_classes
          base = "h-4 w-4 border-gray-300 text-blue-600 focus:ring-blue-500"
          error_classes = error.present? ? "border-red-300" : ""
          disabled_classes = disabled ? "bg-gray-100 cursor-not-allowed" : ""
          [ base, error_classes, disabled_classes ].reject(&:blank?).join(" ")
        end

        def label_classes
          base = "ml-2 text-sm text-gray-700"
          disabled_classes = disabled ? "text-gray-400" : ""
          [ base, disabled_classes ].reject(&:blank?).join(" ")
        end

        def wrapper_classes
          inline ? "flex items-center space-x-6" : "space-y-2"
        end

        def html_field_id(value)
          "#{form.object_name}_#{field_name}_#{value}"
        end
    end
  end
end

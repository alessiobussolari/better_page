# frozen_string_literal: true

module BetterPage
  module Form
    class SelectComponent < BetterPage::ApplicationViewComponent
        def initialize(form:, field_name:, options_list:, selected: nil, include_blank: false,
                       disabled: false, required: false, error: nil, multiple: false,
                       prompt: nil, html_data: {}, html_options: {}, **opts)
          @form = form
          @field_name = field_name
          @options_list = options_list
          @selected = selected
          @include_blank = include_blank
          @disabled = disabled
          @required = required
          @error = error
          @multiple = multiple
          @prompt = prompt
          @html_data = html_data
          @html_options = html_options
          @opts = opts
        end

        attr_reader :form, :field_name, :options_list, :selected, :include_blank,
                    :disabled, :required, :error, :multiple, :prompt,
                    :html_data, :html_options, :opts

        def select_options
          options = {
            disabled: disabled,
            required: required,
            multiple: multiple,
            class: select_classes
          }

          html_data.each do |key, val|
            options[:"data-#{key}"] = val
          end

          options.merge(html_options)
        end

        def select_html_options
          {
            include_blank: include_blank,
            prompt: prompt,
            selected: selected
          }
        end

        def select_classes
          base = "w-full px-3 py-2 border rounded-lg focus:ring-2 focus:border-transparent bg-white"
          error_classes = error.present? ? "border-red-300 focus:ring-red-500" : "border-gray-300 focus:ring-blue-500"
          disabled_classes = disabled ? "bg-gray-50 text-gray-500 cursor-not-allowed" : ""
          [base, error_classes, disabled_classes].reject(&:blank?).join(" ")
        end

        def html_field_id
          "#{form.object_name}_#{field_name}"
        end
    end
  end
end

# frozen_string_literal: true

module BetterPage
  module Form
    class TextareaComponent < BetterPage::ApplicationViewComponent
        def initialize(form:, field_name:, value: nil, placeholder: nil, rows: 4,
                       required: false, disabled: false, readonly: false, autofocus: false,
                       error: nil, maxlength: nil, html_data: {}, html_options: {}, **options)
          @form = form
          @field_name = field_name
          @value = value
          @placeholder = placeholder
          @rows = rows
          @required = required
          @disabled = disabled
          @readonly = readonly
          @autofocus = autofocus
          @error = error
          @maxlength = maxlength
          @html_data = html_data
          @html_options = html_options
          @options = options
        end

        attr_reader :form, :field_name, :value, :placeholder, :rows,
                    :required, :disabled, :readonly, :autofocus, :error,
                    :maxlength, :html_data, :html_options, :options

        def textarea_options
          opts = {
            value: value,
            placeholder: placeholder,
            rows: rows,
            required: required,
            disabled: disabled,
            readonly: readonly,
            autofocus: autofocus,
            class: textarea_classes
          }

          opts[:maxlength] = maxlength if maxlength

          html_data.each do |key, val|
            opts[:"data-#{key}"] = val
          end

          opts.merge(html_options)
        end

        def textarea_classes
          base = "w-full px-3 py-2 border rounded-lg focus:ring-2 focus:border-transparent resize-y"
          error_classes = error.present? ? "border-red-300 focus:ring-red-500" : "border-gray-300 focus:ring-blue-500"
          disabled_classes = disabled ? "bg-gray-50 text-gray-500" : ""
          [base, error_classes, disabled_classes].reject(&:blank?).join(" ")
        end

        def html_field_id
          "#{form.object_name}_#{field_name}"
        end
    end
  end
end

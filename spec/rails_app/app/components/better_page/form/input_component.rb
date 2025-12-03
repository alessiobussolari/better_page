# frozen_string_literal: true

module BetterPage
  module Form
    class InputComponent < BetterPage::ApplicationViewComponent
        FIELD_TYPES = %i[
          text email password url tel number date datetime time
          month week range color search
        ].freeze

        def initialize(form:, field_name:, field_type: :text, value: nil, placeholder: nil,
                       required: false, disabled: false, readonly: false, autofocus: false,
                       error: nil, min: nil, max: nil, step: nil, pattern: nil,
                       html_data: {}, html_options: {}, **options)
          @form = form
          @field_name = field_name
          @field_type = field_type.to_sym
          @value = value
          @placeholder = placeholder
          @required = required
          @disabled = disabled
          @readonly = readonly
          @autofocus = autofocus
          @error = error
          @min = min
          @max = max
          @step = step
          @pattern = pattern
          @html_data = html_data
          @html_options = html_options
          @options = options
        end

        attr_reader :form, :field_name, :field_type, :value, :placeholder,
                    :required, :disabled, :readonly, :autofocus, :error,
                    :min, :max, :step, :pattern, :html_data, :html_options, :options

        def input_options
          opts = {
            value: value,
            placeholder: placeholder,
            required: required,
            disabled: disabled,
            readonly: readonly,
            autofocus: autofocus,
            class: input_classes
          }

          # Add type-specific attributes
          case field_type
          when :number, :range
            opts[:min] = min if min
            opts[:max] = max if max
            opts[:step] = step if step
          when :text, :password, :email, :url, :tel
            opts[:pattern] = pattern if pattern
          end

          # Add custom HTML data attributes
          html_data.each do |key, val|
            opts[:"data-#{key}"] = val
          end

          # Merge any additional HTML options
          opts.merge(html_options)
        end

        def input_classes
          base = "w-full px-3 py-2 border rounded-lg focus:ring-2 focus:border-transparent"
          error_classes = error.present? ? "border-red-300 focus:ring-red-500" : "border-gray-300 focus:ring-blue-500"
          disabled_classes = disabled ? "bg-gray-50 text-gray-500" : ""
          [ base, error_classes, disabled_classes ].reject(&:blank?).join(" ")
        end

        def html_field_id
          "#{form.object_name}_#{field_name}"
        end
    end
  end
end

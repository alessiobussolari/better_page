# frozen_string_literal: true

module BetterPage
  module Form
    class FieldComponent < BetterPage::ApplicationViewComponent
        FIELD_TYPES = %w[text email password url tel number date datetime time month week range color search textarea select checkbox radio file hidden custom].freeze

        def initialize(form:, type:, name:, label: nil, value: nil, placeholder: nil, required: false, disabled: false, error: nil, help: nil, full_width: false, autofocus: false, html_data: {}, **options)
          @form = form
          @type = type.to_s
          @name = name.to_sym
          @label = label
          @value = value
          @placeholder = placeholder
          @required = required
          @disabled = disabled
          @error = error
          @help = help
          @full_width = full_width || @type == "textarea"
          @autofocus = autofocus
          @html_data = html_data || {}
          @options = options
        end

        attr_reader :form, :type, :name, :label, :value, :placeholder, :required, :disabled, :error, :help, :full_width, :autofocus, :html_data, :options

        alias field_type type
        alias field_name name
        alias field_label label

        def html_field_id
          "#{form.object_name}_#{field_name}"
        end

        def field_value
          if form&.object&.respond_to?(field_name)
            form.object.public_send(field_name)
          else
            value
          end
        end

        def required?
          required
        end

        def disabled?
          disabled
        end

        def has_error?
          field_error.present?
        end

        def field_error
          explicit_error = error.presence
          form_error = nil

          form_error = form.object.errors[field_name]&.first if form&.object&.errors&.any?

          explicit_error || form_error
        end

        def has_help?
          help.present?
        end

        def show_label?
          label.present? && field_type != "checkbox"
        end

        def input_classes
          base_classes = "w-full px-3 py-2 border rounded-lg focus:ring-2 focus:border-transparent"

          base_classes += if has_error?
                            " border-red-300 focus:ring-red-500"
                          else
                            " border-gray-300 focus:ring-blue-500"
                          end

          base_classes += " bg-gray-50 text-gray-500" if disabled?
          base_classes
        end

        def textarea_classes
          base_classes = "w-full px-3 py-2 border rounded-lg focus:ring-2 focus:border-transparent resize-y min-h-[6rem]"

          base_classes += if has_error?
                            " border-red-300 focus:ring-red-500"
                          else
                            " border-gray-300 focus:ring-blue-500"
                          end

          base_classes += " bg-gray-50 text-gray-500" if disabled?
          base_classes
        end

        def select_classes
          input_classes
        end

        def checkbox_classes
          "h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
        end

        def radio_classes
          "h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300"
        end

        def file_classes
          "block w-full text-sm text-gray-900 border border-gray-300 rounded-lg cursor-pointer bg-gray-50 focus:outline-none"
        end

        # Options for input component
        def input_component_options
          {
            value: field_value,
            placeholder: placeholder,
            required: required?,
            disabled: disabled?,
            error: field_error,
            autofocus: autofocus,
            readonly: options[:readonly],
            min: options[:min],
            max: options[:max],
            step: options[:step],
            pattern: options[:pattern],
            html_data: html_data
          }
        end

        # Options for textarea component
        def textarea_component_options
          {
            value: field_value,
            placeholder: placeholder,
            required: required?,
            disabled: disabled?,
            error: field_error,
            autofocus: autofocus,
            readonly: options[:readonly],
            rows: options[:rows],
            maxlength: options[:maxlength],
            html_data: html_data
          }
        end

        # Options for select component
        def select_component_options
          {
            options: select_options_for_common,
            value: field_value,
            required: required?,
            disabled: disabled?,
            error: field_error,
            autofocus: autofocus,
            multiple: options[:multiple],
            prompt: options[:prompt],
            include_blank: options[:include_blank],
            html_data: html_data
          }
        end

        # Options for checkbox component
        def checkbox_component_options
          {
            checked: checked?,
            value: value,
            unchecked_value: options[:unchecked_value],
            required: required?,
            disabled: disabled?,
            error: field_error,
            autofocus: autofocus,
            label: label,
            label_position: options[:label_position] || :right,
            html_data: html_data
          }
        end

        # Options for radio component
        def radio_component_options
          {
            options: radio_options_for_common,
            selected_value: field_value,
            required: required?,
            disabled: disabled?,
            error: field_error,
            layout: options[:layout] || :vertical,
            html_data: html_data
          }
        end

        def select_options_for_common
          (options[:options] || []).map do |option|
            { label: option[:label], value: option[:value] }
          end
        end

        def radio_options_for_common
          (options[:options] || []).map do |option|
            { label: option[:label], value: option[:value] }
          end
        end

        def checked?
          if field_value.present?
            [true, "1", "true"].include?(field_value)
          else
            options[:checked] || false
          end
        end

        def text_field_options
          {
            value: field_value,
            placeholder: placeholder,
            class: input_classes,
            required: required?,
            disabled: disabled?,
            autofocus: autofocus,
            data: html_data
          }
        end

        def number_field_options
          opts = text_field_options
          opts[:min] = options[:min] if options[:min]
          opts[:max] = options[:max] if options[:max]
          opts[:step] = options[:step] if options[:step]
          opts
        end

        def file_field_options
          {
            class: file_classes,
            accept: options[:accept],
            multiple: options[:multiple],
            required: required?,
            disabled: disabled?,
            autofocus: autofocus
          }
        end

        def select_options_for_rails
          return [] unless options[:options]

          options[:options].map do |option|
            [option[:label], option[:value]]
          end
        end
    end
  end
end

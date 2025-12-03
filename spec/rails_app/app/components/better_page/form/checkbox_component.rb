# frozen_string_literal: true

module BetterPage
  module Form
    class CheckboxComponent < BetterPage::ApplicationViewComponent
        def initialize(form:, field_name:, label: nil, checked: false, disabled: false,
                       required: false, error: nil, html_data: {}, html_options: {}, **options)
          @form = form
          @field_name = field_name
          @label = label
          @checked = checked
          @disabled = disabled
          @required = required
          @error = error
          @html_data = html_data
          @html_options = html_options
          @options = options
        end

        attr_reader :form, :field_name, :label, :checked, :disabled, :required,
                    :error, :html_data, :html_options, :options

        def checkbox_options
          opts = {
            checked: checked,
            disabled: disabled,
            required: required,
            class: checkbox_classes
          }

          html_data.each do |key, val|
            opts[:"data-#{key}"] = val
          end

          opts.merge(html_options)
        end

        def checkbox_classes
          base = "h-4 w-4 rounded border-gray-300 text-blue-600 focus:ring-blue-500"
          error_classes = error.present? ? "border-red-300" : ""
          disabled_classes = disabled ? "bg-gray-100 cursor-not-allowed" : ""
          [ base, error_classes, disabled_classes ].reject(&:blank?).join(" ")
        end

        def label_classes
          base = "ml-2 text-sm text-gray-700"
          disabled_classes = disabled ? "text-gray-400" : ""
          [ base, disabled_classes ].reject(&:blank?).join(" ")
        end

        def html_field_id
          "#{form.object_name}_#{field_name}"
        end
    end
  end
end

# frozen_string_literal: true

module BetterPage
  module Form
    class ErrorsComponent < BetterPage::ApplicationViewComponent
        def initialize(form_object: nil, custom_errors: nil, **options)
          @form_object = form_object
          @custom_errors = custom_errors
          @options = options
        end

        attr_reader :form_object, :custom_errors, :options

        def has_form_errors?
          form_object.present? &&
            form_object.respond_to?(:errors) &&
            form_object.errors.any?
        end

        def has_custom_errors?
          custom_errors.present?
        end

        def form_errors_count
          return 0 unless has_form_errors?

          form_object.errors.count
        end

        def form_errors_title
          count = form_errors_count
          "#{count} #{count == 1 ? 'error' : 'errors'} in form:"
        end

        def custom_errors_title
          custom_errors[:title] || "Warning"
        end

        def should_render?
          has_form_errors? || has_custom_errors?
        end

        def render?
          should_render?
        end
    end
  end
end

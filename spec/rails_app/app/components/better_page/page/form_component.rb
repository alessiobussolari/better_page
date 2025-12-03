# frozen_string_literal: true

module BetterPage
  module Page
    class FormComponent < BetterPage::ApplicationViewComponent
        def initialize(form_object:, form_panels:, form_header: nil, form_alerts: [], form_errors: nil, form_actions: nil, form_footer: nil, use_tabs: false, **form_options)
          @form_object = form_object
          @form_panels = form_panels || []
          @form_header = form_header
          @form_alerts = form_alerts || []
          @form_errors = form_errors
          @form_actions = form_actions
          @form_footer = form_footer
          @use_tabs = use_tabs
          @form_options = form_options
        end

        attr_reader :form_object, :form_panels, :form_header, :form_alerts, :form_errors, :form_actions, :form_footer, :use_tabs, :form_options

        def has_header?
          form_header.present?
        end

        def has_alerts?
          form_alerts.present? && form_alerts.any?
        end

        def has_errors?
          form_errors.present?
        end

        def has_panels?
          form_panels.present? && form_panels.any?
        end

        def has_actions?
          form_actions.present?
        end

        def has_footer?
          form_footer.present?
        end

        def form_data_options
          form_options[:data] || {}
        end

        def form_html_options
          form_options.except(:data)
        end

        def should_render_errors?
          has_form_object_errors = form_object.present? &&
                                   form_object.respond_to?(:errors) &&
                                   form_object.errors.any?

          has_custom_errors = form_errors.present?

          has_form_object_errors || has_custom_errors
        end
    end
  end
end

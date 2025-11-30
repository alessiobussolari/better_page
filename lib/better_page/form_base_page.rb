# frozen_string_literal: true

module BetterPage
  # Base class for form pages (new/edit).
  # Uses registered components with schema validation.
  #
  # FORM ORGANIZATION RULES (MANDATORY):
  # =====================================
  #
  # RULE 1: INPUT TYPE SEPARATION
  # - CHECKBOX fields must be grouped in dedicated panels, never mixed with other inputs
  # - RADIO BUTTON fields must be grouped in dedicated panels, never mixed with other inputs
  # - Text, email, select, textarea, number, date can be mixed together
  #
  # CORRECT EXAMPLE:
  # [
  #   {
  #     title: 'Basic Information',
  #     fields: [
  #       { name: :name, type: :text, ... },      # OK
  #       { name: :email, type: :email, ... }     # OK
  #     ]
  #   },
  #   {
  #     title: 'Settings',                        # Separate panel
  #     fields: [
  #       { name: :is_primary, type: :checkbox, ... },  # OK
  #       { name: :is_active, type: :checkbox, ... }    # OK
  #     ]
  #   }
  # ]
  #
  # WRONG EXAMPLE:
  # [
  #   {
  #     title: 'Information',
  #     fields: [
  #       { name: :name, type: :text, ... },           # OK
  #       { name: :is_primary, type: :checkbox, ... }  # VIOLATION - checkbox with text
  #     ]
  #   }
  # ]
  #
  # Required components:
  # - header: Form header with title, description, breadcrumbs
  # - panels: Form panels with fields
  #
  # Optional components (with defaults):
  # - alerts, errors, footer
  #
  # @example
  #   class Admin::Users::FormPage < BetterPage::FormBasePage
  #     def header
  #       { title: @item.new_record? ? "New User" : "Edit User" }
  #     end
  #
  #     def panels
  #       [{ title: "Basic Info", fields: [...] }]
  #     end
  #   end
  #
  class FormBasePage < BasePage
    # Header component - required
    register_component :header, required: true do
      required(:title).filled(:string)
      optional(:description).filled(:string)
      optional(:breadcrumbs).array(:hash)
    end

    # Alerts component - optional
    register_component :alerts, default: []

    # Errors component - optional
    register_component :errors, default: nil

    # Panels component - required
    register_component :panels, required: true

    # Footer component - optional
    register_component :footer, default: {
      primary_action: { label: "Save", style: :primary },
      secondary_actions: [],
      info: nil
    }

    # Main method that builds the complete form page configuration
    # @return [Hash] complete form page configuration with :klass for rendering
    def form
      result = build_page
      validate_form_panels_rules(result[:panels]) if result[:panels]
      result
    end

    # Note: frame_form and stream_form are dynamically generated via method_missing in ComponentRegistry
    # Usage:
    #   page.frame_form(:panels)            # Single component for Turbo Frame
    #   page.stream_form                     # All stream components for Turbo Streams
    #   page.stream_form(:panels, :errors)   # Specific components for Turbo Streams

    # The ViewComponent class used to render this form page
    # @return [Class] BetterPage::FormViewComponent
    def view_component_class
      return BetterPage::FormViewComponent if defined?(BetterPage::FormViewComponent)

      raise NotImplementedError, "BetterPage::FormViewComponent not found. Run: rails g better_page:install"
    end

    # Components to include in stream updates by default
    # @return [Array<Symbol>]
    def stream_components
      %i[alerts errors panels]
    end

    protected

    # Validates that all panels follow the input separation rules
    # Logs warnings in development mode when rules are violated
    # @param panels [Array<Hash>] panels to validate
    # @return [void]
    def validate_form_panels_rules(panels)
      return unless defined?(Rails) && Rails.env.development?

      panels.each_with_index do |panel, index|
        next unless panel[:fields].is_a?(Array)

        checkbox_count = panel[:fields].count { |field| field[:type] == :checkbox }
        radio_count = panel[:fields].count { |field| field[:type] == :radio }
        other_count = panel[:fields].count { |field| %i[checkbox radio].exclude?(field[:type]) }

        # RULE 1: Checkboxes must be in separate panels
        if checkbox_count.positive? && other_count.positive?
          Rails.logger.warn "[BetterPage::FormBasePage] RULE VIOLATION in panel '#{panel[:title]}' (#{index}): " \
                            "checkboxes mixed with other inputs (checkboxes: #{checkbox_count}, others: #{other_count})"
        end

        # RULE 1: Radio buttons must be in separate panels
        if radio_count.positive? && other_count.positive?
          Rails.logger.warn "[BetterPage::FormBasePage] RULE VIOLATION in panel '#{panel[:title]}' (#{index}): " \
                            "radio buttons mixed with other inputs (radio: #{radio_count}, others: #{other_count})"
        end
      end
    end

    # Helper to build a form field
    # @param name [Symbol] field name
    # @param type [Symbol] field type (:text, :email, :select, :checkbox, etc.)
    # @param label [String] field label
    # @param options [Hash] additional options (required, placeholder, collection, etc.)
    # @return [Hash] formatted field
    def field_format(name:, type:, label:, **options)
      {
        name: name,
        type: type,
        label: label,
        **options
      }
    end

    # Helper to build a form panel
    # @param title [String] panel title
    # @param fields [Array<Hash>] panel fields
    # @param description [String, nil] panel description
    # @param icon [String, nil] panel icon
    # @return [Hash] formatted panel
    def panel_format(title:, fields:, description: nil, icon: nil)
      panel = {
        title: title,
        fields: fields
      }
      panel[:description] = description if description
      panel[:icon] = icon if icon
      panel
    end

    # Default breadcrumbs for forms
    # @return [Array<Hash>] empty breadcrumbs
    def default_breadcrumbs
      []
    end

    # Extract resource name from class name
    # @return [String] downcased resource name
    def resource_name
      self.class.name.split("::").last.gsub(/Page$/, "").downcase
    end
  end
end

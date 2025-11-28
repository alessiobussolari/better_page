# frozen_string_literal: true

module BetterPage
  # Base class for custom pages that don't fit index/show/form patterns.
  # Uses registered components with schema validation.
  #
  # Required components:
  # - content: Main custom content section
  #
  # Optional components (with defaults):
  # - header, footer
  #
  # @example
  #   class Admin::Dashboard::CustomPage < BetterPage::CustomBasePage
  #     def header
  #       { title: "Dashboard", breadcrumbs: [] }
  #     end
  #
  #     def content
  #       { widgets: [...], charts: [...] }
  #     end
  #   end
  #
  class CustomBasePage < BasePage
    # Header component - optional
    register_component :header, default: nil do
      optional(:title).filled(:string)
      optional(:breadcrumbs).array(:hash)
      optional(:metadata).array(:hash)
      optional(:actions).array(:hash)
    end

    # Content component - required
    register_component :content, required: true

    # Footer component - optional
    register_component :footer, default: nil

    # Main method that builds the complete custom page configuration
    # @return [Hash] complete custom page configuration
    def custom
      build_page
    end

    protected

    # Helper to build a widget section
    # @param title [String] widget title
    # @param type [Symbol] widget type
    # @param data [Hash, Array] widget data
    # @param options [Hash] additional options
    # @return [Hash] formatted widget
    def widget_format(title:, type:, data:, **options)
      {
        title: title,
        type: type,
        data: data,
        **options
      }
    end

    # Helper to build a chart configuration
    # @param title [String] chart title
    # @param type [Symbol] chart type (:line, :bar, :pie, etc.)
    # @param data [Hash] chart data with labels and datasets
    # @param options [Hash] additional chart options
    # @return [Hash] formatted chart
    def chart_format(title:, type:, data:, **options)
      {
        title: title,
        type: type,
        data: data,
        **options
      }
    end
  end
end

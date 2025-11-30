# frozen_string_literal: true

module BetterPage
  # Base class for show/detail pages.
  # Uses registered components with schema validation.
  #
  # Required components:
  # - header: Page header with title, breadcrumbs, metadata, actions
  #
  # Optional components (with defaults):
  # - alerts, statistics, overview, content_sections, footer
  #
  # @example
  #   class Admin::Users::ShowPage < BetterPage::ShowBasePage
  #     def header
  #       { title: @user.name, breadcrumbs: [], actions: [] }
  #     end
  #
  #     def content_sections
  #       [{ title: "Details", type: :info_grid, items: [...] }]
  #     end
  #   end
  #
  class ShowBasePage < BasePage
    # Header component - required
    register_component :header, required: true do
      required(:title).filled(:string)
      optional(:breadcrumbs).array(:hash)
      optional(:metadata).array(:hash)
      optional(:actions).array(:hash)
    end

    # Alerts component - optional
    register_component :alerts, default: []

    # Statistics cards - optional
    register_component :statistics, default: []

    # Overview section - optional
    register_component :overview, default: { enabled: false }

    # Content sections - optional
    register_component :content_sections, default: []

    # Footer section - optional
    register_component :footer, default: { enabled: false }

    # Main method that builds the complete show page configuration
    # @return [Hash] complete show page configuration with :klass for rendering
    def show
      build_page
    end

    # Note: frame_show and stream_show are dynamically generated via method_missing in ComponentRegistry
    # Usage:
    #   page.frame_show(:overview)                    # Single component for Turbo Frame
    #   page.stream_show                               # All stream components for Turbo Streams
    #   page.stream_show(:overview, :content_sections) # Specific components for Turbo Streams

    # The ViewComponent class used to render this show page
    # @return [Class] BetterPage::ShowViewComponent
    def view_component_class
      return BetterPage::ShowViewComponent if defined?(BetterPage::ShowViewComponent)

      raise NotImplementedError, "BetterPage::ShowViewComponent not found. Run: rails g better_page:install"
    end

    # Components to include in stream updates by default
    # @return [Array<Symbol>]
    def stream_components
      %i[alerts statistics overview content_sections]
    end

    protected

    # Helper to convert hash to info grid format
    # @param hash [Hash] key-value pairs to convert
    # @return [Array<Hash>] formatted info grid items
    def info_grid_content_format(hash)
      hash.map { |name, value| { name: name, value: value } }
    end

    # Helper to build content section
    # @param title [String] section title
    # @param icon [String] section icon
    # @param color [String] section color
    # @param type [Symbol] section type (:info_grid, :text_content, :custom)
    # @param content [Hash, Array, nil] section content
    # @return [Hash] formatted content section
    def content_section_format(title:, icon:, color:, type:, content: nil)
      section = {
        title: title,
        icon: icon,
        color: color,
        type: type
      }

      if type == :info_grid && content.is_a?(Array) && content.first.is_a?(Hash) && content.first.key?(:name)
        section[:items] = content
      elsif type == :info_grid && content.is_a?(Hash)
        section[:items] = info_grid_content_format(content)
      elsif type == :info_grid
        section[:items] = content
      else
        section[:content] = content
      end

      section
    end

    # Helper to build statistic card
    # @param label [String] statistic label
    # @param value [String, Numeric] statistic value
    # @param icon [String] statistic icon
    # @param color [String] statistic color
    # @return [Hash] formatted statistic
    def statistic_format(label:, value:, icon:, color:)
      {
        label: label,
        value: value,
        icon: icon,
        color: color
      }
    end

    # Helper to build header action
    # @param path [String] action path
    # @param label [String] action label
    # @param icon [String] action icon
    # @param style [String] action style
    # @param method [Symbol] HTTP method
    # @return [Hash] formatted action
    def action_format(path:, label:, icon:, style:, method: :get)
      {
        path: path,
        label: label,
        icon: icon,
        style: style,
        method: method
      }
    end
  end
end

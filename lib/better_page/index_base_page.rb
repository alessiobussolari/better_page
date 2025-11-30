# frozen_string_literal: true

module BetterPage
  # Base class for index/list pages.
  # Uses page_type to inherit components from global configuration.
  #
  # Available components (from configuration):
  # - header (required): Page header with title, breadcrumbs, metadata, actions
  # - table (required): Table with items, columns, actions, empty_state
  # - alerts, statistics, metrics, tabs, search, pagination
  # - overview, calendar, footer, modals, split_view
  #
  # @example
  #   class Admin::Users::IndexPage < IndexBasePage
  #     def header
  #       { title: "Users", breadcrumbs: [], actions: [] }
  #     end
  #
  #     def table
  #       { items: @users, columns: [...], empty_state: {...} }
  #     end
  #   end
  #
  class IndexBasePage < BasePage
    page_type :index

    # Main method that builds the complete index page configuration
    # @return [Hash] complete index page configuration with :klass for rendering
    def index
      build_page
    end

    # Note: frame_index and stream_index are dynamically generated via method_missing in ComponentRegistry
    # Usage:
    #   page.frame_index(:table)              # Single component for Turbo Frame
    #   page.stream_index                      # All stream components for Turbo Streams
    #   page.stream_index(:table, :pagination) # Specific components for Turbo Streams

    # The ViewComponent class used to render this index page
    # @return [Class] BetterPage::IndexViewComponent
    def view_component_class
      return BetterPage::IndexViewComponent if defined?(BetterPage::IndexViewComponent)

      raise NotImplementedError, "BetterPage::IndexViewComponent not found. Run: rails g better_page:install"
    end

    # Components to include in stream updates by default
    # @return [Array<Symbol>]
    def stream_components
      %i[alerts statistics table pagination]
    end

    protected

    # Helper for split view empty state
    # @param icon [String] icon name
    # @param title [String] title text
    # @param message [String] message text
    # @return [Hash] empty state configuration
    def split_view_empty_state_format(icon: "hand-pointer", title: "Select an item",
                                      message: "Click on an item from the list to see its details")
      {
        icon: icon,
        title: title,
        message: message
      }
    end
  end
end

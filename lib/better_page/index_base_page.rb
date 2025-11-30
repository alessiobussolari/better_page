# frozen_string_literal: true

module BetterPage
  # Base class for index/list pages.
  # Uses registered components with schema validation.
  #
  # Required components:
  # - header: Page header with title, breadcrumbs, metadata, actions
  # - table: Table with items, columns, actions, empty_state
  #
  # Optional components (with defaults):
  # - alerts, statistics, metrics, tabs, search, pagination
  # - overview, calendar, footer, modals, split_view
  #
  # @example
  #   class Admin::Users::IndexPage < BetterPage::IndexBasePage
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
    # Header component - required
    register_component :header, required: true do
      required(:title).filled(:string)
      optional(:breadcrumbs).array(:hash)
      optional(:metadata).array(:hash)
      optional(:actions).array(:hash)
    end

    # Table component - required
    register_component :table, required: true do
      required(:items).value(:array)
      optional(:columns).array(:hash)
      optional(:actions)
      optional(:empty_state).hash do
        optional(:icon).filled(:string)
        optional(:title).filled(:string)
        optional(:message).filled(:string)
        optional(:action).hash
      end
    end

    # Alerts component - optional
    register_component :alerts, default: []

    # Statistics cards - optional
    register_component :statistics, default: []

    # Metrics section - optional
    register_component :metrics, default: []

    # Tabs navigation - optional
    register_component :tabs, default: { enabled: false, current_tab: "all", tabs: [] } do
      optional(:enabled).filled(:bool)
      optional(:current_tab).filled(:string)
      optional(:tabs).array(:hash)
    end

    # Search section - optional
    register_component :search, default: { enabled: false, placeholder: "Search...", current_search: "", results_count: 0 } do
      optional(:enabled).filled(:bool)
      optional(:placeholder).filled(:string)
      optional(:current_search).maybe(:string)
      optional(:results_count).filled(:integer)
    end

    # Pagination - optional
    register_component :pagination, default: { enabled: false } do
      optional(:enabled).filled(:bool)
      optional(:page).filled(:integer)
      optional(:total_pages).filled(:integer)
      optional(:total_count).filled(:integer)
      optional(:per_page).filled(:integer)
    end

    # Overview cards - optional
    register_component :overview, default: { enabled: false }

    # Calendar view - optional
    register_component :calendar, default: { enabled: false, current_date: nil, view_type: "month", events: [], navigation: {} } do
      optional(:enabled).filled(:bool)
      optional(:current_date)
      optional(:view_type).filled(:string)
      optional(:events).array(:hash)
      optional(:navigation).hash
    end

    # Footer section - optional
    register_component :footer, default: { enabled: false }

    # Modals - optional
    register_component :modals, default: []

    # Split view - optional
    register_component :split_view, default: {
      enabled: false,
      selected_id: nil,
      items: [],
      list_title: "Items",
      detail_title: "Details",
      list_item_config: nil,
      detail_path: nil,
      empty_state: {
        icon: "inbox",
        title: "Select an item",
        message: "Click on an item from the list to see its details"
      }
    }

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

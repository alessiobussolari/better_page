# frozen_string_literal: true

module BetterPage
  # Registers all default components provided by the gem.
  # Called automatically during Rails initialization before user initializers.
  #
  # Components are organized by page type:
  # - Index: header, table, alerts, statistics, metrics, tabs, search, pagination, overview, calendar, footer, modals, split_view
  # - Show: header, alerts, statistics, overview, content_sections, footer
  # - Form: header, alerts, errors, panels, footer
  # - Custom: header, content, footer, alerts
  #
  module DefaultComponents
    class << self
      # Register all default components
      # @return [void]
      def register!
        BetterPage.configure do |config|
          register_shared_components(config)
          register_index_components(config)
          register_show_components(config)
          register_form_components(config)
          register_custom_components(config)

          map_components_to_page_types(config)
          set_required_components(config)
        end
      end

      # Get all default component names
      # @return [Array<Symbol>]
      def component_names
        %i[
          header table alerts statistics metrics tabs search pagination
          overview calendar footer modals split_view content_sections
          errors panels content
        ]
      end

      private

      def register_shared_components(config)
        # Header - used by all page types
        config.register_component :header do
          required(:title).filled(:string)
          optional(:breadcrumbs).array(:hash)
          optional(:metadata).array(:hash)
          optional(:actions).array(:hash)
          optional(:description).filled(:string)
        end

        # Alerts - used by all page types
        config.register_component :alerts, default: []

        # Footer - used by all page types
        config.register_component :footer, default: { enabled: false }

        # Statistics - used by index and show
        config.register_component :statistics, default: []

        # Overview - used by index and show
        config.register_component :overview, default: { enabled: false }
      end

      def register_index_components(config)
        # Table - primary component for index pages
        config.register_component :table do
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

        # Metrics section
        config.register_component :metrics, default: []

        # Tabs navigation
        config.register_component :tabs, default: { enabled: false, current_tab: "all", tabs: [] } do
          optional(:enabled).filled(:bool)
          optional(:current_tab).filled(:string)
          optional(:tabs).array(:hash)
        end

        # Search section
        config.register_component :search, default: {
          enabled: false,
          placeholder: "Search...",
          current_search: "",
          results_count: 0
        } do
          optional(:enabled).filled(:bool)
          optional(:placeholder).filled(:string)
          optional(:current_search).maybe(:string)
          optional(:results_count).filled(:integer)
        end

        # Pagination
        config.register_component :pagination, default: { enabled: false } do
          optional(:enabled).filled(:bool)
          optional(:page).filled(:integer)
          optional(:total_pages).filled(:integer)
          optional(:total_count).filled(:integer)
          optional(:per_page).filled(:integer)
        end

        # Calendar view
        config.register_component :calendar, default: {
          enabled: false,
          current_date: nil,
          view_type: "month",
          events: [],
          navigation: {}
        } do
          optional(:enabled).filled(:bool)
          optional(:current_date)
          optional(:view_type).filled(:string)
          optional(:events).array(:hash)
          optional(:navigation).hash
        end

        # Modals
        config.register_component :modals, default: []

        # Split view
        config.register_component :split_view, default: {
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
      end

      def register_show_components(config)
        # Content sections
        config.register_component :content_sections, default: []
      end

      def register_form_components(config)
        # Errors component
        config.register_component :errors, default: nil

        # Panels component
        config.register_component :panels
      end

      def register_custom_components(config)
        # Content component
        config.register_component :content
      end

      def map_components_to_page_types(config)
        # Index page components
        config.allow_components :index,
          :header, :table, :alerts, :statistics, :metrics,
          :tabs, :search, :pagination, :overview, :calendar,
          :footer, :modals, :split_view

        # Show page components
        config.allow_components :show,
          :header, :alerts, :statistics, :overview,
          :content_sections, :footer

        # Form page components
        config.allow_components :form,
          :header, :alerts, :errors, :panels, :footer

        # Custom page components
        config.allow_components :custom,
          :header, :content, :footer, :alerts
      end

      def set_required_components(config)
        # Index pages require header and table
        config.require_components :index, :header, :table

        # Show pages require header
        config.require_components :show, :header

        # Form pages require header and panels
        config.require_components :form, :header, :panels

        # Custom pages require content
        config.require_components :custom, :content
      end
    end
  end
end
